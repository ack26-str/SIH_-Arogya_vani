"""
Consent Router — DPDP Act 2023 compliant consent management.
Supports granular consent types: data collection, voice recording,
document scanning, ABHA linking.
"""

from fastapi import APIRouter, HTTPException
from datetime import datetime
import uuid

from app.core.database import DatabaseService
from app.models.schemas import (
    ConsentGrant,
    ConsentRecord,
    ConsentStatus,
    ConsentType,
)

router = APIRouter(
    prefix="/api/consent",
    tags=["consent"],
)

# Required consent types that must be granted before proceeding
REQUIRED_CONSENTS = {ConsentType.DATA_COLLECTION}


@router.post("/grant", response_model=ConsentStatus)
async def grant_consent(request: ConsentGrant):
    """
    Record granular consent from the patient.
    Multiple consent types can be granted in a single call.
    """
    # Verify patient exists
    patient = await DatabaseService.fetch_one(
        "SELECT id FROM patients WHERE id = ?", (request.patient_id,)
    )
    if not patient:
        raise HTTPException(status_code=404, detail="Patient not found")

    now = datetime.utcnow().isoformat()

    for consent_type in request.consent_types:
        consent_id = f"cons_{uuid.uuid4().hex[:8]}"

        # Check if consent already exists for this patient + type
        existing = await DatabaseService.fetch_one(
            "SELECT id FROM consent_records WHERE patient_id = ? AND consent_type = ? AND revoked_at IS NULL",
            (request.patient_id, consent_type.value),
        )

        if existing:
            # Update existing consent
            await DatabaseService.update("consent_records", existing["id"], {
                "granted": 1,
                "consent_method": request.consent_method,
                "granted_at": now,
            })
        else:
            # Create new consent record
            await DatabaseService.insert("consent_records", {
                "id": consent_id,
                "patient_id": request.patient_id,
                "session_id": request.session_id,
                "consent_type": consent_type.value,
                "granted": 1,
                "consent_method": request.consent_method,
                "dpdp_compliant": 1,
                "granted_at": now,
            })

    # Return current consent status
    return await _get_consent_status(request.patient_id)


@router.get("/{patient_id}", response_model=ConsentStatus)
async def get_consent(patient_id: str):
    """Get current consent status for a patient."""
    return await _get_consent_status(patient_id)


@router.delete("/{patient_id}/revoke")
async def revoke_consent(patient_id: str, consent_type: str = "all"):
    """
    Revoke consent. Can revoke specific type or all consents.
    Per DPDP Act 2023, revocation must be as easy as granting.
    """
    now = datetime.utcnow().isoformat()

    if consent_type == "all":
        await DatabaseService.execute(
            "UPDATE consent_records SET granted = 0, revoked_at = ? WHERE patient_id = ? AND granted = 1",
            (now, patient_id),
        )
    else:
        await DatabaseService.execute(
            "UPDATE consent_records SET granted = 0, revoked_at = ? WHERE patient_id = ? AND consent_type = ? AND granted = 1",
            (now, patient_id, consent_type),
        )

    return {
        "patient_id": patient_id,
        "revoked": consent_type,
        "revoked_at": now,
        "message": "Consent revoked successfully per DPDP Act 2023.",
    }


async def _get_consent_status(patient_id: str) -> ConsentStatus:
    """Build the current consent status for a patient."""
    rows = await DatabaseService.fetch_all(
        "SELECT consent_type, granted FROM consent_records WHERE patient_id = ? AND revoked_at IS NULL",
        (patient_id,),
    )

    consents = {}
    for row in rows:
        consents[row["consent_type"]] = bool(row["granted"])

    # Check if all required consents are granted
    all_required = all(
        consents.get(ct.value, False) for ct in REQUIRED_CONSENTS
    )

    return ConsentStatus(
        patient_id=patient_id,
        consents=consents,
        all_required_granted=all_required,
    )
