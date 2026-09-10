# AarogyaVani (SIH26047) — Patient Journey Implementation Status

This document provides a comprehensive audit and cross-reference of the **10-Step Patient Journey** in AarogyaVani, highlighting implemented features, architecture, and designated "Yet to integrate" modules.

---

## Patient Journey Matrix

| Step | Journey Phase | Status | Architectural Implementation |
|:---:|:---|:---:|:---|
| **1** | **Language Selection** | ✅ Complete | Multilingual support across 6 Indian languages (English, Hindi, Malayalam, Tamil, Telugu, Kannada) with Riverpod dynamic state and persistent selection. |
| **2** | **Patient ID / Registration** | ✅ Complete | Clean demographic registration form (Name, Age, Gender, Phone, Email) with backend persistence (`POST /api/patients/register`). |
| **3** | **Consent Collection** | ✅ Complete | DPDP Act 2023 compliant consent screen with granular switches for Clinical Data Collection (mandatory), Voice Recording, and Document OCR. Connects to `POST /api/consent/grant`. |
| **4** | **Session Setup & Connectivity** | ✅ Complete | Kiosk network status verification, Department routing selector (**Allopathic OPD** vs **AYUSH OPD** / Dashavidha Pariksha), and encrypted temporary session generation (`POST /api/sessions/create`). |
| **5** | **Red-Flag Emergency Triage** | 🔒 *Yet to integrate* | Clearly marked with `"Yet to integrate"` badge and lock icon. Tap-to-explain bottom sheet details rapid vital screening and hospital ER escalation protocols. |
| **6** | **AI Clinical Intake Conversation** | ✅ Complete | Dynamic clinical state-machine driven by Gemini LLM with SOCRATES / Dashavidha clinical frameworks. Multilingual voice input and audio playback powered by Bhashini APIs. |
| **7** | **Document & Report Scanning** | ✅ Complete | Upload support for PDF, JPG, PNG lab reports and prescriptions with OCR pipeline (`POST /api/documents/upload` and `/process`). Includes instant sample files for testing. |
| **8** | **Clinical Summary Generation** | ✅ Complete | Hardened mapping of backend `IntakeState` into FHIR-aligned Clinical Summary with symptoms, onset, severity, medical history, medications, and allergies. |
| **9** | **ABHA / FHIR Record Linking** | 🔒 *Yet to integrate* | Prominently represented in Patient Profile and Home Dashboard as `"Yet to integrate"`. Details 14-digit ABHA ID linking and longitudinal health record syncing awaiting NHA sandbox clearance. |
| **10** | **Physician Review & EMR Sync** | 🔒 *Yet to integrate* | Backend table `clinical_summaries` is fully provisioned. Kiosk currently supports patient-side confirmation and review. |

---

## Architectural Highlights

### Frontend (Flutter + Riverpod + GoRouter)
- **Design System**: Strict color tokens, accessible typography, high contrast, and large touch targets optimized for elderly patients and rural kiosks.
- **Workflow Router**: Smooth progression: `Splash` → `Welcome` → `Language` → `Profile Setup` → `Consent` → `Session Setup` → `Home Dashboard` → `Intake Conversation` → `Clinical Summary`.
- **"Yet to Integrate" Pattern**: Implemented via reusable `PendingFeatureCard` widget adhering strictly to project guidelines (lock icon, amber badge, haptic tap, and detailed explanatory modal).

### Backend (FastAPI + SQLite + Gemini + Bhashini)
- **Compliance**: DPDP Act 2023 ephemeral data session purge endpoints (`DELETE /api/sessions/{session_id}`).
- **Dual Department Protocols**:
  - `ALLOPATHIC_OPD`: SOCRATES clinical questioning.
  - `AYUSH_OPD`: Dashavidha Pariksha holistic inquiry.
- **AI Pipelines**:
  - Structured extraction using Google Gemini.
  - Indian language speech synthesis and recognition via Bhashini.

---

## Verification & Analysis
- Ran `flutter analyze` with 0 errors and 0 warnings.
- Verified route tree, error boundaries, and null safety.
