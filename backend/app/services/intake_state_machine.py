from dataclasses import dataclass, field
from typing import List, Dict, Optional, Set
import json

from app.models.schemas import DepartmentConfig, IntakePhase, DashavidhaPariksha, Medication, Allergy


@dataclass
class TopicDirective:
    slot_name: str
    topic_guidance_text: str
    phase: IntakePhase


@dataclass
class IntakeState:
    """Structured representation of ALL clinical data collected so far in the conversation."""
    current_phase: IntakePhase
    department: DepartmentConfig

    # Chief Complaint
    chief_complaint: Optional[str] = None

    # SOCRATES slots
    site: Optional[str] = None
    onset: Optional[str] = None
    character: Optional[str] = None
    radiation: Optional[str] = None
    associations: List[str] = field(default_factory=list)
    timing: Optional[str] = None
    exacerbating_relieving: Optional[str] = None
    severity: Optional[str] = None

    # Medical History categories
    past_medical_history: List[str] = field(default_factory=list)
    past_surgical_history: List[str] = field(default_factory=list)
    drug_history: List[Medication] = field(default_factory=list)
    allergy_history: List[Allergy] = field(default_factory=list)
    family_history: List[str] = field(default_factory=list)
    personal_history: List[str] = field(default_factory=list)

    # AYUSH Dashavidha Pariksha
    dashavidha: Optional[DashavidhaPariksha] = None

    # Review of Systems
    review_of_systems: Dict[str, Optional[str]] = field(default_factory=dict)

    # Tracking lists to know what we have actively queried
    history_categories_asked: Set[str] = field(default_factory=set)
    dashavidha_fields_asked: Set[str] = field(default_factory=set)
    is_complete: bool = False

    def to_dict(self) -> dict:
        """Convert state to a dictionary for persistence."""
        data = {
            "current_phase": self.current_phase.value,
            "department": self.department.value,
            "chief_complaint": self.chief_complaint,
            "site": self.site,
            "onset": self.onset,
            "character": self.character,
            "radiation": self.radiation,
            "associations": self.associations,
            "timing": self.timing,
            "exacerbating_relieving": self.exacerbating_relieving,
            "severity": self.severity,
            "past_medical_history": self.past_medical_history,
            "past_surgical_history": self.past_surgical_history,
            "drug_history": [m.model_dump() for m in self.drug_history] if self.drug_history else [],
            "allergy_history": [a.model_dump() for a in self.allergy_history] if self.allergy_history else [],
            "family_history": self.family_history,
            "personal_history": self.personal_history,
            "dashavidha": self.dashavidha.model_dump() if self.dashavidha else None,
            "review_of_systems": self.review_of_systems,
            "history_categories_asked": list(self.history_categories_asked),
            "dashavidha_fields_asked": list(self.dashavidha_fields_asked),
            "is_complete": self.is_complete
        }
        return data

    @classmethod
    def from_dict(cls, data: dict) -> 'IntakeState':
        """Reconstruct from dictionary."""
        if not data:
            return cls(current_phase=IntakePhase.CHIEF_COMPLAINT, department=DepartmentConfig.ALLOPATHIC_OPD)

        drug_history = [Medication(**m) for m in data.get("drug_history", [])]
        allergy_history = [Allergy(**a) for a in data.get("allergy_history", [])]
        
        dashavidha_dict = data.get("dashavidha")
        dashavidha = DashavidhaPariksha(**dashavidha_dict) if dashavidha_dict else None

        return cls(
            current_phase=IntakePhase(data.get("current_phase", IntakePhase.CHIEF_COMPLAINT.value)),
            department=DepartmentConfig(data.get("department", DepartmentConfig.ALLOPATHIC_OPD.value)),
            chief_complaint=data.get("chief_complaint"),
            site=data.get("site"),
            onset=data.get("onset"),
            character=data.get("character"),
            radiation=data.get("radiation"),
            associations=data.get("associations", []),
            timing=data.get("timing"),
            exacerbating_relieving=data.get("exacerbating_relieving"),
            severity=data.get("severity"),
            past_medical_history=data.get("past_medical_history", []),
            past_surgical_history=data.get("past_surgical_history", []),
            drug_history=drug_history,
            allergy_history=allergy_history,
            family_history=data.get("family_history", []),
            personal_history=data.get("personal_history", []),
            dashavidha=dashavidha,
            review_of_systems=data.get("review_of_systems", {}),
            history_categories_asked=set(data.get("history_categories_asked", [])),
            dashavidha_fields_asked=set(data.get("dashavidha_fields_asked", [])),
            is_complete=data.get("is_complete", False)
        )


class IntakeStateMachine:
    """Deterministic logic to drive the clinical interview without relying on LLM to plan."""

    @staticmethod
    def get_next_topic(state: IntakeState) -> TopicDirective:
        """Determines the next required clinical question based on the current state."""

        # 1. Chief Complaint
        if not state.chief_complaint:
            state.current_phase = IntakePhase.CHIEF_COMPLAINT
            return TopicDirective(
                slot_name="chief_complaint",
                topic_guidance_text="Ask the patient what their primary reason for visiting is (chief complaint).",
                phase=IntakePhase.CHIEF_COMPLAINT
            )

        # 2. SOCRATES (History of Presenting Illness)
        if state.current_phase in (IntakePhase.CHIEF_COMPLAINT, IntakePhase.SOCRATES):
            state.current_phase = IntakePhase.SOCRATES
            if not state.onset:
                return TopicDirective("onset", "Ask when the symptoms first started (Onset).", IntakePhase.SOCRATES)
            if not state.site:
                return TopicDirective("site", "Ask exactly where they are feeling the symptom (Site).", IntakePhase.SOCRATES)
            if not state.character:
                return TopicDirective("character", "Ask what the symptom feels like (Character - e.g., sharp, dull, throbbing).", IntakePhase.SOCRATES)
            if not state.radiation:
                return TopicDirective("radiation", "Ask if the symptom spreads or radiates anywhere else (Radiation).", IntakePhase.SOCRATES)
            if not state.associations:
                return TopicDirective("associations", "Ask if they have any other symptoms accompanying the main one (Associated symptoms).", IntakePhase.SOCRATES)
            if not state.timing:
                return TopicDirective("timing", "Ask about the timing of the symptom (e.g., is it constant, comes and goes, worse at night?).", IntakePhase.SOCRATES)
            if not state.exacerbating_relieving:
                return TopicDirective("exacerbating_relieving", "Ask if anything makes it better or worse (Exacerbating/Relieving factors).", IntakePhase.SOCRATES)
            if not state.severity:
                return TopicDirective("severity", "Ask them to rate the severity (e.g., on a scale of 1 to 10).", IntakePhase.SOCRATES)

        # 3. Medical History
        if state.current_phase in (IntakePhase.SOCRATES, IntakePhase.MEDICAL_HISTORY):
            state.current_phase = IntakePhase.MEDICAL_HISTORY
            if "past_medical" not in state.history_categories_asked:
                state.history_categories_asked.add("past_medical")
                return TopicDirective("past_medical_history", "Ask if they have any long-term medical conditions like diabetes, hypertension, or asthma.", IntakePhase.MEDICAL_HISTORY)
            if "past_surgical" not in state.history_categories_asked:
                state.history_categories_asked.add("past_surgical")
                return TopicDirective("past_surgical_history", "Ask if they have had any surgeries in the past.", IntakePhase.MEDICAL_HISTORY)
            if "drug_allergy" not in state.history_categories_asked:
                state.history_categories_asked.add("drug_allergy")
                return TopicDirective("drug_allergy_history", "Ask if they are currently taking any medications or have any allergies to drugs or food.", IntakePhase.MEDICAL_HISTORY)
            if "family_personal" not in state.history_categories_asked:
                state.history_categories_asked.add("family_personal")
                return TopicDirective("family_personal_history", "Ask about any major illnesses in their family, and their lifestyle habits (smoking, alcohol, diet).", IntakePhase.MEDICAL_HISTORY)

        # 4. AYUSH Assessment (Dashavidha Pariksha) - ONLY IF AYUSH OPD
        if state.department == DepartmentConfig.AYUSH_OPD:
            if state.current_phase in (IntakePhase.MEDICAL_HISTORY, IntakePhase.AYUSH_ASSESSMENT):
                state.current_phase = IntakePhase.AYUSH_ASSESSMENT
                if not state.dashavidha:
                    state.dashavidha = DashavidhaPariksha()
                    
                if "agni" not in state.dashavidha_fields_asked:
                    state.dashavidha_fields_asked.add("agni")
                    return TopicDirective("agni", "Ask about their digestion and appetite (Agni). Is it strong, weak, or variable?", IntakePhase.AYUSH_ASSESSMENT)
                if "koshtha" not in state.dashavidha_fields_asked:
                    state.dashavidha_fields_asked.add("koshtha")
                    return TopicDirective("koshtha", "Ask about their bowel movements (Koshtha). Are they regular, constipated, or loose?", IntakePhase.AYUSH_ASSESSMENT)
                if "ahara_vihara" not in state.dashavidha_fields_asked:
                    state.dashavidha_fields_asked.add("ahara_vihara")
                    return TopicDirective("ahara_vihara", "Ask about their sleep quality and daily dietary routine (Ahara/Vihara).", IntakePhase.AYUSH_ASSESSMENT)

        # 5. Review of Systems (ROS) - Optional final check
        if state.current_phase in (IntakePhase.MEDICAL_HISTORY, IntakePhase.AYUSH_ASSESSMENT, IntakePhase.REVIEW_OF_SYSTEMS):
            state.current_phase = IntakePhase.REVIEW_OF_SYSTEMS
            if "ros_general" not in state.history_categories_asked:
                state.history_categories_asked.add("ros_general")
                return TopicDirective("ros_general", "Ask if they have any other general complaints like fever, fatigue, or weight loss before finishing.", IntakePhase.REVIEW_OF_SYSTEMS)

        # 6. Complete
        state.current_phase = IntakePhase.COMPLETE
        state.is_complete = True
        return TopicDirective(
            slot_name="COMPLETE",
            topic_guidance_text="Thank the patient, tell them the clinical summary is ready, and ask them to review it.",
            phase=IntakePhase.COMPLETE
        )

    @staticmethod
    def compute_completeness(state: IntakeState) -> float:
        """Calculate progress 0.0 to 1.0"""
        total_slots = 1 + 8 + 4 + 1  # CC + SOCRATES + History + ROS
        if state.department == DepartmentConfig.AYUSH_OPD:
            total_slots += 3
            
        filled = 0
        if state.chief_complaint: filled += 1
        
        # SOCRATES
        for field in [state.site, state.onset, state.character, state.radiation, state.timing, state.exacerbating_relieving, state.severity]:
            if field: filled += 1
        if state.associations: filled += 1
            
        # History
        if "past_medical" in state.history_categories_asked: filled += 1
        if "past_surgical" in state.history_categories_asked: filled += 1
        if "drug_allergy" in state.history_categories_asked: filled += 1
        if "family_personal" in state.history_categories_asked: filled += 1
            
        # AYUSH
        if state.department == DepartmentConfig.AYUSH_OPD:
            if "agni" in state.dashavidha_fields_asked: filled += 1
            if "koshtha" in state.dashavidha_fields_asked: filled += 1
            if "ahara_vihara" in state.dashavidha_fields_asked: filled += 1
            
        # ROS
        if "ros_general" in state.history_categories_asked: filled += 1
            
        return round(min(filled / total_slots, 1.0), 2)
