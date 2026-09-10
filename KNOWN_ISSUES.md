# AarogyaVani (SIH26047) — Known Issues & Technical Notes

This document details known environmental constraints, external dependencies, and technical considerations for AarogyaVani.

---

## 1. Network & Backend Connectivity
- **Backend Base URL**: The Flutter client connects by default to `https://api.clg-website.in/api` via Cloudflare Tunnel. When running backend locally without Cloudflare, update `ApiClient.baseUrl` in `lib/core/network/api_client.dart` (`http://10.0.2.2:8000/api` for Android Emulator or `http://localhost:8000/api` for iOS Simulator / macOS desktop).
- **Graceful Offline Degradation**: All onboarding screens (`ProfileSetupScreen`, `ConsentScreen`, `SessionSetupScreen`) include local fallback state handling. If backend connectivity fails, the user is not blocked and can proceed through the intake flow.

## 2. Audio & Speech Services (Bhashini)
- **Microphone Permissions**:
  - Android: Requires `android.permission.RECORD_AUDIO` and `android.permission.INTERNET` (configured in `AndroidManifest.xml`).
  - iOS/macOS: Microphone access modal must be accepted on first launch.
- **Audio Payload Format**: Bhashini expects 16kHz linear PCM or WAV. When recording from device microphones, the `voice_service` captures Base64 PCM or fallback text input if the environment lacks microphone hardware.

## 3. ABHA (Ayushman Bharat Digital Mission) Integration
- **Status**: Designated as **"Yet to integrate"** in UI via `PendingFeatureCard`.
- **Requirements for Production**:
  - Sandbox client ID and client secret from the National Health Authority (NHA).
  - Aadhaar / Mobile OTP gateway integration for M1 (ABHA creation), M2 (Health record discovery), and M3 (Health Information Exchange).

## 4. Emergency Red-Flag Triage
- **Status**: Designated as **"Yet to integrate"** in UI via `PendingFeatureCard`.
- **Requirements for Production**:
  - Direct integration with Hospital Information System (HIS) emergency desk or nurse station paging sirens.
  - Vitals IoT integration (Pulse Oximeter, Automated BP cuff) for hardware-verified triage escalation.

## 5. Session Ephemeral Storage & DPDP Act 2023
- **Privacy Compliance**: All audio recordings and intermediate AI extraction states are marked as ephemeral.
- **Session Cleanup**: Calling `POST /api/sessions/create` creates a 4-hour time-limited token. Calling `DELETE /api/sessions/{session_id}` purges all associated temporary files and intermediate drafts.
