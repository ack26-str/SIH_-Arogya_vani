import httpx
from typing import Optional

from app.core.config import settings


class BhashiniService:
    """
    Integration with Bhashini for Indian languages ASR and TTS.

    Offline fallback behaviour (when keys are missing/placeholder):
    - ASR  → returns None  → backend uses the `fallback_text` sent by the Flutter client
    - TTS  → returns None  → Flutter uses flutter_tts for offline speech output
    This means the entire voice flow works end-to-end without Bhashini keys.
    """

    BASE_URL = "https://dhruva-api.bhashini.gov.in/services/inference/pipeline"
    _PLACEHOLDERS = {"your_actual_key_here", "your_key_here", "your_user_id_here", "", None}

    @classmethod
    def _is_configured(cls) -> bool:
        """True only when real (non-placeholder) credentials are present."""
        key = getattr(settings, "BHASHINI_API_KEY", None)
        uid = getattr(settings, "BHASHINI_USER_ID", None)
        return key not in cls._PLACEHOLDERS and uid not in cls._PLACEHOLDERS

    # ─── ASR ──────────────────────────────────────────────────────────────────

    @classmethod
    async def transcribe_audio(cls, audio_base64: str, language_code: str = "hi") -> Optional[str]:
        """
        Convert base64 WAV audio → text.
        Returns None when Bhashini is unavailable; caller should use fallback_text instead.
        """
        if not cls._is_configured():
            print("[Bhashini] ASR skipped — no API keys. Using client fallback_text.")
            return None

        headers = {
            "Content-Type": "application/json",
            "Authorization": settings.BHASHINI_API_KEY,
        }
        payload = {
            "pipelineTasks": [
                {
                    "taskType": "asr",
                    "config": {
                        "language": {"sourceLanguage": language_code},
                        "serviceId": "ai4bharat/conformer-hi-gpu--t4",
                        "audioFormat": "wav",
                    },
                }
            ],
            "inputData": {"audio": [{"audioContent": audio_base64}]},
        }
        try:
            async with httpx.AsyncClient() as client:
                resp = await client.post(cls.BASE_URL, headers=headers, json=payload, timeout=30.0)
                resp.raise_for_status()
                data = resp.json()
                pipeline = data.get("pipelineResponse", [])
                if pipeline:
                    out = pipeline[0].get("output", [])
                    if out and "source" in out[0]:
                        return out[0]["source"]
        except Exception as e:
            print(f"[Bhashini] ASR error: {e}. Using client fallback_text.")
        return None

    # ─── TTS ──────────────────────────────────────────────────────────────────

    @classmethod
    async def synthesize_speech(
        cls, text: str, language_code: str = "hi", gender: str = "female"
    ) -> Optional[str]:
        """
        Convert text → base64 WAV audio.
        Returns None when Bhashini is unavailable; Flutter uses flutter_tts offline.
        """
        if not cls._is_configured():
            print("[Bhashini] TTS skipped — no API keys. Flutter will use offline flutter_tts.")
            return None

        headers = {
            "Content-Type": "application/json",
            "Authorization": settings.BHASHINI_API_KEY,
        }
        payload = {
            "pipelineTasks": [
                {
                    "taskType": "tts",
                    "config": {
                        "language": {"sourceLanguage": language_code},
                        "serviceId": "ai4bharat/indic-tts-hi",
                        "gender": gender,
                    },
                }
            ],
            "inputData": {"input": [{"source": text}]},
        }
        try:
            async with httpx.AsyncClient() as client:
                resp = await client.post(cls.BASE_URL, headers=headers, json=payload, timeout=30.0)
                resp.raise_for_status()
                data = resp.json()
                pipeline = data.get("pipelineResponse", [])
                if pipeline:
                    out = pipeline[0].get("audio", [])
                    if out and "audioContent" in out[0]:
                        return out[0]["audioContent"]
        except Exception as e:
            print(f"[Bhashini] TTS error: {e}. Flutter will use offline fallback.")
        return None
