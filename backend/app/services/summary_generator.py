import json
import uuid
from datetime import datetime
from typing import Dict, Any

from google import genai
from google.genai import types

from app.core.config import settings
from app.core.database import DatabaseService
from app.services.intake_state_machine import IntakeState

client = None
if settings.GEMINI_API_KEY:
    client = genai.Client(api_key=settings.GEMINI_API_KEY)


async def generate_clinical_summary(conversation_id: str, patient_id: str, state: IntakeState) -> Dict[str, Any]:
    """
    Takes the completed IntakeState and generates a structured, professional 
    clinical summary (FHIR-aligned where possible) using Gemini.
    Saves it to the clinical_summaries table.
    """
    if not client:
        return {"error": "LLM not configured"}

    state_json = json.dumps(state.to_dict(), indent=2)

    prompt = f"""
    You are an expert medical transcriptionist.
    I will provide you with a structured JSON of a patient's clinical intake state.
    Your task is to generate a professional, structured Clinical Summary.
    
    INTAKE STATE:
    {state_json}
    
    INSTRUCTIONS:
    1. Organize the summary into standard medical sections: Chief Complaint, History of Present Illness (incorporating SOCRATES details), Past Medical History, Medications, Allergies, Family/Social History, and Review of Systems.
    2. If the department is AYUSH, include a separate section for 'Dashavidha Pariksha'.
    3. Output the result as a valid JSON object matching this structure:
       {{
         "chief_complaint": "...",
         "hpi_socrates": "...",
         "past_medical_history": "...",
         "medications_and_allergies": "...",
         "family_social_history": "...",
         "review_of_systems": "...",
         "ayush_assessment": "..." // Optional
       }}
    4. Write professionally in English.
    """

    try:
        response = client.models.generate_content(
            model='gemini-3.5-flash-lite',
            contents=prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
                temperature=0.1,
            ),
        )
        
        summary_json = response.text
        summary_id = f"sum_{uuid.uuid4().hex[:8]}"
        now = datetime.utcnow().isoformat()
        
        # Save to DB
        await DatabaseService.insert("clinical_summaries", {
            "id": summary_id,
            "conversation_id": conversation_id,
            "patient_id": patient_id,
            "summary_json": summary_json,
            "status": "draft",
            "created_at": now,
            "updated_at": now
        })
        
        return json.loads(summary_json)
        
    except Exception as e:
        print(f"Error generating clinical summary: {e}")
        return {"error": "Failed to generate summary", "raw_state": state.to_dict()}
