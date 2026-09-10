from fastapi import APIRouter, UploadFile, File, Form, HTTPException, BackgroundTasks
from fastapi.concurrency import run_in_threadpool
import uuid
import os
import aiofiles
import json
from datetime import datetime
from pathlib import Path

from app.core.database import DatabaseService
from app.core.config import settings
from app.models.schemas import MedicalRecord, MedicalExtraction
from app.services.document_processor import DocumentProcessor

router = APIRouter(
    prefix="/api/documents",
    tags=["documents"]
)

@router.post("/upload", response_model=MedicalRecord)
async def upload_document(
    patient_id: str = Form(...),
    session_id: str = Form(None),
    file: UploadFile = File(...)
):
    """
    Upload a document (PDF/Image), save to local filesystem, and register in the database.
    """
    # Auto-create the patient row if it doesn't exist yet.
    # This handles 'pat_demo', newly onboarded patients, and offline-first flows
    # where the patient profile hasn't been synced to the DB yet.
    patient = await DatabaseService.fetch_one("SELECT id FROM patients WHERE id = ?", (patient_id,))
    if not patient:
        await DatabaseService.insert("patients", {
            "id": patient_id,
            "name": "Patient",
            "age": 0,
            "gender": "unknown",
            "created_at": datetime.utcnow().isoformat(),
        })

    doc_id = f"doc_{uuid.uuid4().hex[:8]}"
    
    # Save file locally
    ext = Path(file.filename).suffix if file.filename else ".bin"
    file_path = Path(settings.UPLOAD_DIR) / f"{doc_id}{ext}"
    
    # Write file asynchronously
    file_size = 0
    async with aiofiles.open(file_path, 'wb') as out_file:
        while content := await file.read(1024 * 1024):  # read 1MB chunks
            await out_file.write(content)
            file_size += len(content)
            
    # Insert record into database
    now = datetime.utcnow()
    await DatabaseService.insert("documents", {
        "id": doc_id,
        "patient_id": patient_id,
        "session_id": session_id,
        "file_name": file.filename or "unknown",
        "file_type": file.content_type or "application/octet-stream",
        "file_size": file_size,
        "file_path": str(file_path),
        "status": "uploaded",
        "created_at": now.isoformat()
    })
    
    return MedicalRecord(
        id=doc_id,
        patient_id=patient_id,
        file_url=str(file_path), # Returning local path for now
        type="general",
        status="uploaded",
        created_at=now
    )

@router.post("/{document_id}/process", response_model=MedicalExtraction)
async def process_document(document_id: str):
    """
    Process an uploaded document using Gemini Multimodal OCR.
    """
    doc = await DatabaseService.fetch_one("SELECT * FROM documents WHERE id = ?", (document_id,))
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
        
    if not doc.get("file_path") or not os.path.exists(doc["file_path"]):
        raise HTTPException(status_code=404, detail="Document file is missing from disk")
        
    await DatabaseService.update("documents", document_id, {"status": "processing"})
    
    try:
        # Run the heavy Gemini processing in a threadpool to not block the event loop
        extraction = await run_in_threadpool(
            DocumentProcessor.extract_medical_entities,
            file_path=doc["file_path"],
            mime_type=doc["file_type"]
        )
        
        # Save extraction to database
        extraction_json = extraction.model_dump_json()
        await DatabaseService.update("documents", document_id, {
            "status": "processed",
            "extraction_json": extraction_json
        })
        
        return extraction
        
    except Exception as e:
        await DatabaseService.update("documents", document_id, {"status": "failed"})
        raise HTTPException(status_code=500, detail=f"Failed to process document: {str(e)}")

@router.get("/{document_id}/status")
async def get_document_status(document_id: str):
    """Check processing status."""
    doc = await DatabaseService.fetch_one("SELECT status FROM documents WHERE id = ?", (document_id,))
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
    return {"document_id": document_id, "status": doc["status"]}

@router.get("/{document_id}/extraction", response_model=MedicalExtraction)
async def get_document_extraction(document_id: str):
    """Retrieve the extracted structured data for a processed document."""
    doc = await DatabaseService.fetch_one("SELECT extraction_json, status FROM documents WHERE id = ?", (document_id,))
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
        
    if doc["status"] != "processed" or not doc["extraction_json"]:
        return MedicalExtraction() # Return empty if not processed yet
        
    return MedicalExtraction.model_validate_json(doc["extraction_json"])

@router.get("/patient/{patient_id}")
async def get_patient_documents(patient_id: str):
    """
    Get all uploaded and processed documents for a patient.
    """
    docs = await DatabaseService.fetch_all(
        "SELECT id, patient_id, file_name, file_type, file_size, status, extraction_json, created_at FROM documents WHERE patient_id = ? ORDER BY created_at DESC",
        (patient_id,)
    )
    results = []
    for doc in docs:
        ext = None
        if doc.get("extraction_json"):
            try:
                ext = json.loads(doc["extraction_json"])
            except Exception:
                pass
        results.append({
            "id": doc["id"],
            "patientId": doc["patient_id"],
            "patient_id": doc["patient_id"],
            "fileName": doc["file_name"],
            "file_name": doc["file_name"],
            "fileType": doc["file_type"],
            "file_type": doc["file_type"],
            "fileSize": doc["file_size"] or 0,
            "file_size": doc["file_size"] or 0,
            "status": doc["status"] or "processed",
            "uploadDate": doc["created_at"],
            "created_at": doc["created_at"],
            "extractedInformation": ext,
            "extraction": ext,
        })
    return results

@router.patch("/{document_id}/extraction", response_model=MedicalExtraction)
async def update_document_extraction(document_id: str, updated_extraction: MedicalExtraction):
    """
    Update or manually correct clinical entities extracted from a document.
    """
    doc = await DatabaseService.fetch_one("SELECT * FROM documents WHERE id = ?", (document_id,))
    if not doc:
        raise HTTPException(status_code=404, detail="Document not found")
        
    extraction_json = updated_extraction.model_dump_json()
    await DatabaseService.update("documents", document_id, {
        "extraction_json": extraction_json,
        "status": "processed"
    })
    return updated_extraction

@router.get("/patient/{patient_id}/timeline")
async def get_patient_timeline(patient_id: str):
    """
    Synthesize all document extractions for a patient into a chronological timeline.
    """
    docs = await DatabaseService.fetch_all(
        "SELECT extraction_json FROM documents WHERE patient_id = ? AND status = 'processed'", 
        (patient_id,)
    )
    
    extractions = []
    for doc in docs:
        if doc["extraction_json"]:
            extractions.append(MedicalExtraction.model_validate_json(doc["extraction_json"]))
            
    timeline = DocumentProcessor.build_timeline(extractions)
    return {"patient_id": patient_id, "timeline": timeline}

