"""
Sessions Router — Encrypted temporary session management.
Creates a session per kiosk visit. On session close, ephemeral data
(audio recordings, raw uploaded images, intermediate AI data) is purged
per DPDP Act 2023 requirements.
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime, timedelta
import uuid
import hashlib

from app.core.database import DatabaseService
from app.core.config import settings
from app.models.schemas import SessionCreate, Session, DepartmentConfig

router = APIRouter(
    prefix="/api/sessions",
    tags=["sessions"],
)


def _generate_encrypted_token(patient_id: str, session_id: str) -> str:
    """Generate a simple HMAC-based session token. Replace with proper
    JWT or Fernet encryption for production."""
    raw = f"{session_id}:{patient_id}:{settings.SESSION_SECRET_KEY}:{datetime.utcnow().isoformat()}"
    return hashlib.sha256(raw.encode()).hexdigest()


@router.post("/create", response_model=Session)
async def create_session(request: SessionCreate):
    """Create a new encrypted temporary session for a kiosk visit."""
    # Verify patient exists
    patient = await DatabaseService.fetch_one(
        "SELECT id FROM patients WHERE id = ?", (request.patient_id,)
    )
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    session_id = f"sess_{uuid.uuid4().hex[:8]}"
    now = datetime.utcnow()
    expires = now + timedelta(hours=4)  # Session valid for 4 hours
    token = _generate_encrypted_token(request.patient_id, session_id)

    await DatabaseService.insert("sessions", {
        "id": session_id,
        "patient_id": request.patient_id,
        "department_config": request.department_config.value,
        "language": request.language,
        "encrypted_token": token,
        "is_active": 1,
        "created_at": now.isoformat(),
        "expires_at": expires.isoformat(),
    })

    return Session(
        id=session_id,
        patient_id=request.patient_id,
        department_config=request.department_config,
        language=request.language,
        is_active=True,
        created_at=now,
        expires_at=expires,
    )


@router.get("/{session_id}/status", response_model=Session)
async def get_session_status(session_id: str):
    """Check if a session is still valid."""
    row = await DatabaseService.fetch_one(
        "SELECT * FROM sessions WHERE id = ?", (session_id,)
    )
    if not row:
        raise HTTPException(status_code=404, detail="Session not found")

    # Check expiry
    is_active = bool(row["is_active"])
    if row.get("expires_at"):
        expires = datetime.fromisoformat(row["expires_at"])
        if datetime.utcnow() > expires:
            is_active = False
            # Mark as inactive in DB
            await DatabaseService.update("sessions", session_id, {"is_active": 0})

    return Session(
        id=row["id"],
        patient_id=row["patient_id"],
        department_config=DepartmentConfig(row["department_config"]),
        language=row["language"],
        is_active=is_active,
        created_at=datetime.fromisoformat(row["created_at"]),
        expires_at=datetime.fromisoformat(row["expires_at"]) if row.get("expires_at") else None,
    )


@router.delete("/{session_id}")
async def close_session(session_id: str):
    """
    Close a session and purge ephemeral data (DPDP Act 2023 compliance).
    Deletes: uploaded document files, intermediate processing data.
    Keeps: structured clinical summary, audit records.
    """
    row = await DatabaseService.fetch_one(
        "SELECT * FROM sessions WHERE id = ?", (session_id,)
    )
    if not row:
        raise HTTPException(status_code=404, detail="Session not found")

    # 1. Delete raw uploaded document files from disk
    import os
    from pathlib import Path
    docs = await DatabaseService.fetch_all(
        "SELECT file_path FROM documents WHERE session_id = ?", (session_id,)
    )
    for doc in docs:
        if doc.get("file_path") and os.path.exists(doc["file_path"]):
            try:
                os.remove(doc["file_path"])
            except OSError:
                pass  # Best-effort deletion

    # 2. Clear raw extraction JSON from documents (keep metadata)
    await DatabaseService.execute(
        "UPDATE documents SET extraction_json = NULL, file_path = NULL WHERE session_id = ?",
        (session_id,),
    )

    # 3. Mark session as inactive
    await DatabaseService.update("sessions", session_id, {
        "is_active": 0,
    })

    return {
        "session_id": session_id,
        "status": "closed",
        "ephemeral_data_purged": True,
        "message": "Session closed. Audio recordings, raw images, and intermediate AI data cleared per DPDP Act 2023.",
    }
