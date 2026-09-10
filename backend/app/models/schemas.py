from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum


# --- Enums ---

class MessageRole(str, Enum):
    system = "system"
    ai = "ai"
    patient = "patient"


class DepartmentConfig(str, Enum):
    AYUSH_OPD = "AYUSH_OPD"
    ALLOPATHIC_OPD = "ALLOPATHIC_OPD"


class ProvenanceTag(str, Enum):
    VOICE_CONFIRMED = "VOICE_CONFIRMED"
    OCR_EXTRACTED = "OCR_EXTRACTED"
    AI_INFERRED = "AI_INFERRED"
    PATIENT_REPORTED = "PATIENT_REPORTED"


class ConsentType(str, Enum):
    DATA_COLLECTION = "data_collection"
    VOICE_RECORDING = "voice_recording"
    DOCUMENT_SCANNING = "document_scanning"
    ABHA_LINKING = "abha_linking"


class IntakePhase(str, Enum):
    CHIEF_COMPLAINT = "CHIEF_COMPLAINT"
    SOCRATES = "SOCRATES"
    MEDICAL_HISTORY = "MEDICAL_HISTORY"
    AYUSH_ASSESSMENT = "AYUSH_ASSESSMENT"
    REVIEW_OF_SYSTEMS = "REVIEW_OF_SYSTEMS"
    COMPLETE = "COMPLETE"


# --- Core Medical Models ---

class Medication(BaseModel):
    name: str
    dose: Optional[str] = None
    frequency: Optional[str] = None


class Allergy(BaseModel):
    allergen: str
    reaction: Optional[str] = None


class LabResult(BaseModel):
    test_name: str
    result_value: str
    reference_range: Optional[str] = None
    is_abnormal: Optional[bool] = None
    date: Optional[str] = None


class Symptom(BaseModel):
    name: str
    duration: Optional[str] = None
    severity: Optional[str] = None


class PatientInfo(BaseModel):
    age: Optional[str] = None
    gender: Optional[str] = None
    weight: Optional[str] = None


# --- AYUSH: Dashavidha Pariksha ---

class DashavidhaPariksha(BaseModel):
    """Ten-fold assessment from Ayurvedic clinical examination."""
    prakriti: Optional[str] = None         # Constitution (Vata/Pitta/Kapha)
    vikriti: Optional[str] = None          # Current imbalance
    agni: Optional[str] = None             # Digestive capacity
    koshtha: Optional[str] = None          # Bowel nature
    sara: Optional[str] = None             # Tissue essence
    samhanana: Optional[str] = None        # Body compactness
    pramana: Optional[str] = None          # Body proportions
    satmya: Optional[str] = None           # Compatibility/habituation
    sattva: Optional[str] = None           # Mental constitution
    ahara_shakti: Optional[str] = None     # Dietary capacity
    vyayama_shakti: Optional[str] = None   # Exercise capacity
    vaya: Optional[str] = None             # Age/stage of life
    ahara_vihara: Optional[str] = None     # Diet & lifestyle habits


# --- Red-Flag Emergency Screening ---

class RedFlagScreening(BaseModel):
    has_chest_pain: bool = False
    has_breathing_difficulty: bool = False
    has_severe_bleeding: bool = False
    has_altered_consciousness: bool = False
    has_stroke_signs: bool = False
    is_emergency: bool = False


# --- ABHA (Ayushman Bharat Health Account) ---

class ABHAInfo(BaseModel):
    abha_id: Optional[str] = None
    abha_address: Optional[str] = None
    linked: bool = False
    verified: bool = False


# --- Patient ---

class PatientBase(BaseModel):
    name: str
    age: int
    gender: str
    phone: str
    email: Optional[str] = None
    preferred_language: str = "en"


class PatientCreate(PatientBase):
    pass


class Patient(PatientBase):
    id: str
    hospital_temp_id: Optional[str] = None
    abha_info: Optional[ABHAInfo] = None
    created_at: datetime


# --- Session ---

class SessionCreate(BaseModel):
    patient_id: str
    department_config: DepartmentConfig = DepartmentConfig.ALLOPATHIC_OPD
    language: str = "en"


class Session(BaseModel):
    id: str
    patient_id: str
    department_config: DepartmentConfig
    language: str
    is_active: bool = True
    created_at: datetime
    expires_at: Optional[datetime] = None


# --- Consent ---

class ConsentGrant(BaseModel):
    patient_id: str
    session_id: Optional[str] = None
    consent_types: List[ConsentType]
    consent_method: str = "digital"  # digital, audio_guided, assisted


class ConsentRecord(BaseModel):
    id: str
    patient_id: str
    session_id: Optional[str] = None
    consent_type: ConsentType
    granted: bool
    consent_method: str
    dpdp_compliant: bool = True
    granted_at: Optional[datetime] = None
    revoked_at: Optional[datetime] = None


class ConsentStatus(BaseModel):
    patient_id: str
    consents: Dict[str, bool] = {}  # consent_type -> granted
    all_required_granted: bool = False


# --- Conversation ---

class ConversationBase(BaseModel):
    patient_id: str
    status: str = "active"


class ConversationCreate(BaseModel):
    patient_id: str
    session_id: Optional[str] = None
    department_config: DepartmentConfig = DepartmentConfig.ALLOPATHIC_OPD
    language: str = "en"


class Conversation(ConversationBase):
    id: str
    session_id: Optional[str] = None
    department_config: DepartmentConfig = DepartmentConfig.ALLOPATHIC_OPD
    language: str = "en"
    completeness_score: float = 0.0
    created_at: datetime
    updated_at: datetime


# --- Messages ---

class ConversationMessageBase(BaseModel):
    conversation_id: str
    role: MessageRole
    text: str
    language: str = "en"
    is_voice: bool = False
    attached_record_id: Optional[str] = None


class ConversationMessageCreate(ConversationMessageBase):
    pass


class ConversationMessage(ConversationMessageBase):
    id: str
    timestamp: datetime
    provenance_tag: Optional[ProvenanceTag] = None
    quick_suggestions: List[str] = []


# --- Medical Extraction (from documents) ---

class MedicalExtraction(BaseModel):
    patient_information: Optional[PatientInfo] = None
    symptoms: List[Symptom] = []
    diagnoses: List[str] = []
    medications: List[Medication] = []
    allergies: List[Allergy] = []
    lab_results: List[LabResult] = []
    previous_treatments: List[str] = []
    medical_history: List[str] = []


# --- Medical Records (uploaded documents) ---

class MedicalRecordBase(BaseModel):
    patient_id: str
    file_url: Optional[str] = None
    type: str = "general"  # prescription, lab_report, discharge_summary, imaging
    status: str = "processing"


class MedicalRecordCreate(MedicalRecordBase):
    pass


class MedicalRecord(MedicalRecordBase):
    id: str
    created_at: datetime
    extraction: Optional[MedicalExtraction] = None


# --- Visit History (for "same complaint" detection) ---

class VisitHistoryEntry(BaseModel):
    id: str
    patient_id: str
    conversation_id: str
    chief_complaint: Optional[str] = None
    visit_date: datetime
    summary_id: Optional[str] = None


# --- API Request/Response Models ---

class StartConversationRequest(BaseModel):
    patient_id: str
    session_id: Optional[str] = None
    department_config: DepartmentConfig = DepartmentConfig.ALLOPATHIC_OPD
    language: str = "en"


class StartConversationResponse(BaseModel):
    conversation_id: str
    message: str
    current_phase: IntakePhase = IntakePhase.CHIEF_COMPLAINT
    completeness_score: float = 0.0


class SendMessageRequest(BaseModel):
    text: Optional[str] = None
    audio_base64: Optional[str] = None
    fallback_text: Optional[str] = None  # Device speech_to_text result — used when Bhashini is unavailable
    language: str = "en"
    is_voice: bool = False


class SendMessageResponse(BaseModel):
    reply_text: str
    audio_url: Optional[str] = None
    is_emergency: bool = False
    current_phase: Optional[IntakePhase] = None
    completeness_score: float = 0.0
    is_complete: bool = False
    updated_state: Optional[Dict[str, Any]] = None


class RedFlagScreeningRequest(BaseModel):
    has_chest_pain: bool = False
    has_breathing_difficulty: bool = False
    has_severe_bleeding: bool = False
    has_altered_consciousness: bool = False
    has_stroke_signs: bool = False


class RedFlagScreeningResponse(BaseModel):
    is_emergency: bool
    triggered_flags: List[str] = []
    message: str
