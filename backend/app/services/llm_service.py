import json
from typing import Dict, Any, List

from google import genai
from google.genai import types
from pydantic import BaseModel, create_model

from app.core.config import settings
from app.services.intake_state_machine import IntakeState, TopicDirective

client = None
if settings.GEMINI_API_KEY:
    client = genai.Client(api_key=settings.GEMINI_API_KEY)


def extract_clinical_data(
    patient_text: str,
    current_state: IntakeState,
    conversation_history: List[Dict[str, str]]
) -> Dict[str, Any]:
    """
    Extracts structured clinical data from the patient's message.
    Returns a dictionary (delta) to be merged into the current IntakeState.
    """
    if not client:
        return {}

    history_text = "\n".join([f"{msg['role'].capitalize()}: {msg['text']}" for msg in conversation_history[-5:]])

    prompt = f"""
    You are an expert medical transcriptionist. 
    Your task is to extract ONLY new medical information from the latest PATIENT MESSAGE.
    
    CURRENT CLINICAL STATE:
    {json.dumps(current_state.to_dict(), indent=2)}
    
    RECENT CONVERSATION HISTORY:
    {history_text}
    
    LATEST PATIENT MESSAGE:
    "{patient_text}"
    
    INSTRUCTIONS:
    1. Extract new information mentioned in the latest message.
    2. Map the extracted info to the exact fields defined in the CURRENT CLINICAL STATE.
    3. Return ONLY a JSON object containing the newly extracted fields (the delta). 
    4. If the patient's message does not contain relevant clinical info, return an empty JSON object {{}}.
    5. Do NOT hallucinate or infer data not explicitly stated.
    6. Translate all extracted medical terms into English standard medical terminology.
    """

    MODELS_TO_TRY = ['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite']
    
    for model_name in MODELS_TO_TRY:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    max_output_tokens=300,
                    temperature=0.1,
                ),
            )
            if response.text:
                delta = json.loads(response.text)
                if isinstance(delta, dict):
                    return delta
            return {}
        except Exception as e:
            print(f"[{model_name}] Error extracting clinical data: {e}")
            continue
    return {}


def phrase_clinical_question(
    topic_directive: TopicDirective,
    conversation_history: List[Dict[str, str]],
    patient_language: str
) -> str:
    """
    Phrases the next clinical question naturally in the patient's language.
    Gemini does NOT decide what to ask; it only follows the topic_directive.
    """
    if not client:
        return f"System error. Next topic: {topic_directive.topic_guidance_text}"

    history_text = "\n".join([f"{msg['role'].capitalize()}: {msg['text']}" for msg in conversation_history[-4:]])

    prompt = f"""
    You are AarogyaVani, an empathetic, highly intelligent medical clinical intake assistant.
    
    RECENT CONVERSATION HISTORY:
    {history_text}
    
    YOUR DIRECTIVE FOR THE NEXT QUESTION:
    "{topic_directive.topic_guidance_text}"
    
    INSTRUCTIONS:
    1. Ask about the directive above.
    2. Phrase the question naturally, warmly, and empathetically.
    3. Keep it brief. Ask ONE clarifying question at a time.
    4. You MUST respond in this language: {patient_language}.
    5. Do not use medical jargon.
    """

    MODELS_TO_TRY = ['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite']

    for model_name in MODELS_TO_TRY:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=prompt,
                config=types.GenerateContentConfig(
                    max_output_tokens=150,
                    temperature=0.3,
                ),
            )
            if response.text and response.text.strip():
                return response.text.strip()
        except Exception as e:
            print(f"[{model_name}] Error phrasing question: {e}")
            continue

    return "I'm sorry, could you please tell me more about that?"


def process_unified_intake_turn(
    patient_text: str,
    current_state: IntakeState,
    next_topic_guidance: str,
    conversation_history: List[Dict[str, str]],
    patient_language: str
) -> tuple[Dict[str, Any], str]:
    """
    Optimized single-pass call:
    Extracts clinical delta AND phrases the next empathetic question in ONE roundtrip.
    Cuts latency by > 50%.
    """
    if not client:
        return {}, "Could you tell me more about your symptoms?"

    history_text = "\n".join([f"{msg['role'].capitalize()}: {msg['text']}" for msg in conversation_history[-4:]])

    prompt = f"""
    You are AarogyaVani, an empathetic, highly intelligent medical clinical intake assistant.

    CURRENT KNOWN CLINICAL STATE:
    {json.dumps(current_state.to_dict(), indent=2)}

    RECENT CONVERSATION HISTORY:
    {history_text}

    LATEST PATIENT MESSAGE:
    "{patient_text}"

    NEXT CLINICAL FOCUS:
    "{next_topic_guidance}"

    INSTRUCTIONS:
    1. Extract newly mentioned clinical facts (chief_complaint, site, onset, character, radiation, severity, associations, timing, triggers, drug_history, allergies, past_history) into the 'extracted' dictionary. Use standard English medical terminology.
    2. Formulate the single next warm, empathetic question to ask the patient about the NEXT CLINICAL FOCUS, written strictly in this language: {patient_language}. Keep it to 1-2 sentences.
    3. Return ONLY a valid JSON object matching:
    {{
      "extracted": {{ ... }},
      "reply_question": "..."
    }}
    """

    MODELS_TO_TRY = ['gemini-3.5-flash-lite', 'gemini-3.1-flash-lite']

    for model_name in MODELS_TO_TRY:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=prompt,
                config=types.GenerateContentConfig(
                    response_mime_type="application/json",
                    max_output_tokens=350,
                    temperature=0.2,
                ),
            )
            if response.text:
                data = json.loads(response.text)
                extracted = data.get("extracted", {})
                if not isinstance(extracted, dict):
                    extracted = {}
                question = data.get("reply_question", "").strip()
                if question:
                    return extracted, question
        except Exception as e:
            print(f"[{model_name}] Error in unified intake turn: {e}")
            continue

    return {}, "I'm sorry, could you please tell me more about that?"
