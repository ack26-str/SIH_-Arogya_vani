import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'patient/patient_service.dart';
import 'patient/real_patient_service.dart';
import 'conversation/conversation_service.dart';
import 'conversation/real_conversation_service.dart';
import 'documents/document_service.dart';
import 'documents/real_document_service.dart';
import 'voice/voice_service.dart';
import 'voice/real_voice_service.dart';
import '../models/patient.dart';

final patientServiceProvider = Provider<PatientService>((ref) {
  return RealPatientService();
});

final conversationServiceProvider = Provider<ConversationService>((ref) {
  return RealConversationService();
});

final documentServiceProvider = Provider<DocumentService>((ref) {
  return RealDocumentService();
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return RealVoiceService();
});

// Patient State Notifier
class CurrentPatientNotifier extends StateNotifier<AsyncValue<Patient?>> {
  final PatientService _service;

  CurrentPatientNotifier(this._service) : super(const AsyncValue.loading()) {
    loadPatient();
  }

  Future<void> loadPatient() async {
    state = const AsyncValue.loading();
    try {
      final patient = await _service.getPatient();
      state = AsyncValue.data(patient);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePatient(Patient patient) async {
    state = const AsyncValue.loading();
    try {
      final saved = await _service.savePatient(patient);
      state = AsyncValue.data(saved);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> clearSession() async {
    await _service.clearSession();
    state = const AsyncValue.data(null);
  }
}

final currentPatientProvider =
    StateNotifierProvider<CurrentPatientNotifier, AsyncValue<Patient?>>((ref) {
  final service = ref.watch(patientServiceProvider);
  return CurrentPatientNotifier(service);
});
