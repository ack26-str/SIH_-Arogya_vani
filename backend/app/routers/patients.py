"""
Patients Router — Registration, profile, visit history.
ABHA endpoints intentionally omitted (UI built but greyed out pending NHA registration).
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime
import uuid

from app.core.database import DatabaseService
from app.models.schemas import (
    PatientCreate,
    Patient,
    ABHAInfo,
    VisitHistoryEntry,
)

router = APIRouter(
    prefix="/api/patients",
    tags=["patients"],
)


@router.post("/register", response_model=Patient)
async def register_patient(request: PatientCreate):
    """Register a new patient and generate a Temporary Hospital ID."""
    patient_id = f"pat_{uuid.uuid4().hex[:8]}"
    hospital_temp_id = f"TMP-{uuid.uuid4().hex[:6].upper()}"

    await DatabaseService.insert("patients", {
        "id": patient_id,
        "name": request.name,
        "age": request.age,
        "gender": request.gender,
        "phone": request.phone,
        "email": request.email,
        "preferred_language": request.preferred_language,
        "hospital_temp_id": hospital_temp_id,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    })

    return Patient(
        id=patient_id,
        name=request.name,
        age=request.age,
        gender=request.gender,
        phone=request.phone,
        email=request.email,
        preferred_language=request.preferred_language,
        hospital_temp_id=hospital_temp_id,
        created_at=datetime.utcnow(),
    )


@router.get("/{patient_id}", response_model=Patient)
async def get_patient(patient_id: str):
    """Fetch a patient's profile by ID."""
    row = await DatabaseService.fetch_one(
        "SELECT * FROM patients WHERE id = ?", (patient_id,)
    )
    if not row:
        raise HTTPException(status_code=404, detail="Patient not found")

    return Patient(
        id=row["id"],
        name=row["name"],
        age=row["age"],
        gender=row["gender"],
        phone=row["phone"],
        email=row["email"],
        preferred_language=row["preferred_language"],
        hospital_temp_id=row["hospital_temp_id"],
        abha_info=ABHAInfo(
            abha_id=row.get("abha_id"),
            abha_address=row.get("abha_address"),
            linked=bool(row.get("abha_linked", 0)),
        ) if row.get("abha_id") else None,
        created_at=datetime.fromisoformat(row["created_at"]),
    )


@router.put("/{patient_id}", response_model=Patient)
async def update_patient(patient_id: str, request: PatientCreate):
    """Update patient profile."""
    existing = await DatabaseService.fetch_one(
        "SELECT * FROM patients WHERE id = ?", (patient_id,)
    )
    if not existing:
        raise HTTPException(status_code=404, detail="Patient not found")

    await DatabaseService.update("patients", patient_id, {
        "name": request.name,
        "age": request.age,
        "gender": request.gender,
        "phone": request.phone,
        "email": request.email,
        "preferred_language": request.preferred_language,
        "updated_at": datetime.utcnow().isoformat(),
    })

    return Patient(
        id=patient_id,
        name=request.name,
        age=request.age,
        gender=request.gender,
        phone=request.phone,
        email=request.email,
        preferred_language=request.preferred_language,
        hospital_temp_id=existing["hospital_temp_id"],
        created_at=datetime.fromisoformat(existing["created_at"]),
    )


@router.get("/{patient_id}/history", response_model=list[VisitHistoryEntry])
async def get_visit_history(patient_id: str):
    """Get previous visit summaries for 'same complaint' detection."""
    rows = await DatabaseService.fetch_all(
        "SELECT * FROM visit_history WHERE patient_id = ? ORDER BY visit_date DESC LIMIT 10",
        (patient_id,),
    )
    return [
        VisitHistoryEntry(
            id=row["id"],
            patient_id=row["patient_id"],
            conversation_id=row["conversation_id"],
            chief_complaint=row.get("chief_complaint"),
            visit_date=datetime.fromisoformat(row["visit_date"]),
            summary_id=row.get("summary_id"),
        )
        for row in rows
    ]


@router.get("/search/phone/{phone}")
async def search_by_phone(phone: str):
    """Search for an existing patient by phone number."""
    row = await DatabaseService.fetch_one(
        "SELECT * FROM patients WHERE phone = ?", (phone,)
    )
    if not row:
        return {"found": False, "patient": None}

    return {
        "found": True,
        "patient": Patient(
            id=row["id"],
            name=row["name"],
            age=row["age"],
            gender=row["gender"],
            phone=row["phone"],
            email=row["email"],
            preferred_language=row["preferred_language"],
            hospital_temp_id=row["hospital_temp_id"],
            created_at=datetime.fromisoformat(row["created_at"]),
        ),
    }
