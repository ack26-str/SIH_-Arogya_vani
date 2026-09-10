from pydantic_settings import BaseSettings
from typing import Optional
from pathlib import Path


class Settings(BaseSettings):
    # Gemini API
    GEMINI_API_KEY: Optional[str] = None

    # Database — SQLite file on local disk (swap to Cloudflare D1 URL later)
    DATABASE_PATH: str = str(Path(__file__).resolve().parent.parent.parent / "aarogyavani.db")

    # Document uploads — local filesystem directory
    UPLOAD_DIR: str = str(Path(__file__).resolve().parent.parent.parent / "uploads")

    # Session encryption
    SESSION_SECRET_KEY: str = "aarogyavani-session-secret-change-in-production"

    # Bhashini API (Government of India multilingual ASR/TTS)
    BHASHINI_API_KEY: Optional[str] = None
    BHASHINI_USER_ID: Optional[str] = None
    BHASHINI_ULCA_API_KEY: Optional[str] = None

    class Config:
        env_file = ".env"


settings = Settings()
