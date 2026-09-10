from fastapi import APIRouter, HTTPException
from fastapi.concurrency import run_in_threadpool
import uuid
from datetime import datetime
import json
import time
import asyncio

from app.core.database import DatabaseService
from app.models.schemas import (
    StartConversationRequest,
    StartConversationResponse,
    SendMessageRequest,
    SendMessageResponse,
    DepartmentConfig
)
from app.services.intake_state_machine import IntakeState, IntakeStateMachine
from app.services.llm_service import extract_clinical_data, phrase_clinical_question, process_unified_intake_turn
from app.services.bhashini_service import BhashiniService

router = APIRouter(
    prefix="/api/conversations",
    tags=["conversations"]
)

@router.post("/start", response_model=StartConversationResponse)
async def start_conversation(request: StartConversationRequest):
    """
    Start a new deterministic conversation based on the patient's department.
    """
    # Verify patient
    patient = await DatabaseService.fetch_one("SELECT id FROM patients WHERE id = ?", (request.patient_id,))
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    conv_id = f"conv_{uuid.uuid4().hex[:8]}"
    
    # Initialize state machine for this department
    bootstrap_state = IntakeState(current_phase=None, department=request.department_config)
    first_topic = IntakeStateMachine.get_next_topic(bootstrap_state)
    initial_state = IntakeState(
        current_phase=first_topic.phase,
        department=request.department_config
    )

    # We get the first topic to start
    topic = IntakeStateMachine.get_next_topic(initial_state)
    
    LOCALIZED_GREETINGS = {
        "en": "Hello! I am AarogyaVani. What brings you to the clinic today?",
        "hi": "नमस्ते! मैं आरोग्यवाणी हूँ। आज आप अस्पताल किस समस्या के लिए आए हैं?",
        "kn": "ನಮಸ್ಕಾರ! ನಾನು ಆರೋಗ್ಯವಾಣಿ. ಇಂದು ನೀವು ಕ್ಲಿನಿಕ್‌ಗೆ ಯಾವ ತೊಂದರೆಗಾಗಿ ಬಂದಿದ್ದೀರಿ?",
        "ta": "வணக்கம்! நான் ஆரோக்கியவாணி. இன்று நீங்கள் மருத்துவமனைக்கு என்ன காரணத்திற்காக வந்துள்ளீர்கள்?",
        "te": "నమస్కారం! నేను ఆరోగ్యవాణిని. ఈ రోజు మీరు క్లినిక్‌కి ఏ సమస్య కోసం వచ్చారు?",
        "ml": "നമസ്കാരം! ഞാൻ ആരോഗ്യവാണി. ഇന്ന് നിങ്ങൾ ക്ലിനിക്കിൽ എത്തിയത് എന്ത് ബുദ്ധിಮುട്ട് കാരണമാണ്?",
    }
    greeting = LOCALIZED_GREETINGS.get(request.language, "Hello! I am AarogyaVani. What brings you to the clinic today?")
    
    now = datetime.utcnow().isoformat()
    
    # Save conversation
    await DatabaseService.insert("conversations", {
        "id": conv_id,
        "patient_id": request.patient_id,
        "session_id": request.session_id,
        "department_config": request.department_config.value,
        "language": request.language,
        "status": "active",
        "intake_state_json": json.dumps(initial_state.to_dict()),
        "completeness_score": 0.0,
        "created_at": now,
        "updated_at": now
    })
    
    # Save the initial message
    msg_id = f"msg_{uuid.uuid4().hex[:8]}"
    await DatabaseService.insert("messages", {
        "id": msg_id,
        "conversation_id": conv_id,
        "role": "ai",
        "text": greeting,
        "language": request.language,
        "timestamp": now
    })

    return StartConversationResponse(
        conversation_id=conv_id,
        message=greeting,
        current_phase=initial_state.current_phase,
        completeness_score=0.0
    )


@router.post("/{conversation_id}/message", response_model=SendMessageResponse)
async def send_message(conversation_id: str, request: SendMessageRequest):
    """
    Handle a multi-turn conversation explicitly guided by the IntakeStateMachine.
    """
    # 1. Fetch conversation
    conv = await DatabaseService.fetch_one("SELECT * FROM conversations WHERE id = ?", (conversation_id,))
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    if conv["status"] != "active":
        raise HTTPException(status_code=400, detail="Conversation is closed")

    # 2. Parse current state
    state_dict = json.loads(conv["intake_state_json"] or "{}")
    # Ensure department is carried over
    if "department" not in state_dict:
        state_dict["department"] = conv["department_config"]
    state = IntakeState.from_dict(state_dict)
    
    # Handle Voice Input (ASR)
    # Priority order:
    #   1. Bhashini ASR transcription (when keys are configured)
    #   2. fallback_text from Flutter's device speech_to_text (offline)
    #   3. request.text (typed text)
    user_text = (request.text or getattr(request, 'fallback_text', '') or '').strip()
    if request.is_voice and request.audio_base64 and not user_text:
        try:
            bhashini_transcript = await asyncio.wait_for(
                BhashiniService.transcribe_audio(request.audio_base64, request.language),
                timeout=2.0
            )
            if bhashini_transcript:
                user_text = bhashini_transcript.strip()
        except Exception:
            pass
    elif getattr(request, 'fallback_text', None) and request.fallback_text.strip() and not user_text:
        user_text = request.fallback_text.strip()

    if not user_text.strip():
        # Don't 400 — return a soft prompt so Flutter shows a normal AI bubble
        # instead of a red "Connection error" card.
        return SendMessageResponse(
            reply_text="I'm sorry, I couldn't hear that clearly. Could you please repeat or type your message?",
            audio_url=None,
            current_phase=state.current_phase,
            completeness_score=IntakeStateMachine.compute_completeness(state),
            is_complete=False,
            updated_state=state.to_dict(),
        )

    # 3. Save patient's message
    now = datetime.utcnow().isoformat()
    await DatabaseService.insert("messages", {
        "id": f"msg_{uuid.uuid4().hex[:8]}",
        "conversation_id": conversation_id,
        "role": "patient",
        "text": user_text,
        "language": request.language,
        "timestamp": now,
        "is_voice": 1 if request.is_voice else 0
    })

    # 4. Fetch history for context
    messages = await DatabaseService.fetch_all(
        "SELECT role, text FROM messages WHERE conversation_id = ? ORDER BY timestamp ASC",
        (conversation_id,)
    )
    
    # 5. Determine Next Topic & Process Turn (Single-Pass Optimized LLM)
    next_topic = IntakeStateMachine.get_next_topic(state)
    
    t_llm_start = time.time()
    delta, reply_text = await run_in_threadpool(
        process_unified_intake_turn,
        patient_text=user_text,
        current_state=state,
        next_topic_guidance=next_topic.topic_guidance_text,
        conversation_history=messages,
        patient_language=request.language
    )
    t_llm_end = time.time()
    print(f"[TIMING] Single-pass unified intake turn took: {t_llm_end - t_llm_start:.2f}s")
    
    # 6. Apply delta to state (merge logic)
    for key, value in delta.items():
        if hasattr(state, key) and value:
            curr_val = getattr(state, key)
            if isinstance(curr_val, list) and isinstance(value, list):
                if key in ["drug_history", "allergy_history"]:
                    pass
                else:
                    curr_val.extend([v for v in value if v not in curr_val])
            elif not curr_val:
                setattr(state, key, value)
                
    # Re-serialize to clean up typed fields
    raw_state = state.to_dict()
    for key, value in delta.items():
        if key in raw_state and value:
            if isinstance(raw_state[key], list) and isinstance(value, list):
                if key not in ["drug_history", "allergy_history"]:
                    raw_state[key].extend([v for v in value if v not in raw_state[key]])
                else:
                    raw_state[key].extend(value)
            elif not raw_state[key]:
                raw_state[key] = value
    
    # Reconstruct state
    state = IntakeState.from_dict(raw_state)
    
    # Check if complete
    is_complete = state.is_complete
    if is_complete:
        await DatabaseService.update("conversations", conversation_id, {"status": "completed"})
        
    # Handle Voice Output (TTS)
    audio_url = None
    if request.is_voice:
        try:
            audio_base64 = await asyncio.wait_for(
                BhashiniService.synthesize_speech(reply_text, request.language, gender="female"),
                timeout=1.5
            )
            if audio_base64:
                audio_url = f"data:audio/wav;base64,{audio_base64}"
        except Exception:
            pass # Flutter immediately uses local device TTS fallback
            
    # 9. Save AI response
    now = datetime.utcnow().isoformat()
    await DatabaseService.insert("messages", {
        "id": f"msg_{uuid.uuid4().hex[:8]}",
        "conversation_id": conversation_id,
        "role": "ai",
        "text": reply_text,
        "language": request.language,
        "timestamp": now,
        "is_voice": 1 if request.is_voice else 0
    })
    
    # 10. Update conversation state in DB
    score = IntakeStateMachine.compute_completeness(state)
    await DatabaseService.update("conversations", conversation_id, {
        "intake_state_json": json.dumps(state.to_dict()),
        "completeness_score": score,
        "updated_at": now
    })

    return SendMessageResponse(
        reply_text=reply_text,
        audio_url=audio_url,
        current_phase=state.current_phase,
        completeness_score=score,
        is_complete=is_complete,
        updated_state=state.to_dict()
    )


@router.get("/{conversation_id}/state")
async def get_conversation_state(conversation_id: str):
    conv = await DatabaseService.fetch_one("SELECT intake_state_json FROM conversations WHERE id = ?", (conversation_id,))
    if not conv:
        raise HTTPException(status_code=404, detail="Conversation not found")
        
    return json.loads(conv["intake_state_json"] or "{}")

@router.get("/{conversation_id}/summary")
async def get_clinical_summary(conversation_id: str):
    """
    Fetches the generated FHIR-aligned clinical summary.
    """
    row = await DatabaseService.fetch_one("SELECT summary_json FROM clinical_summaries WHERE conversation_id = ?", (conversation_id,))
    if not row:
        # If not generated yet, just return the state for MVP
        conv = await DatabaseService.fetch_one("SELECT intake_state_json FROM conversations WHERE id = ?", (conversation_id,))
        if conv:
            return {"status": "draft", "summary": json.loads(conv["intake_state_json"] or "{}")}
        raise HTTPException(status_code=404, detail="Summary not found")
        
    return json.loads(row["summary_json"])
