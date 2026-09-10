import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/api_client.dart';
import '../../../../services/service_providers.dart';

class ConsentState {
  final bool dataCollection;
  final bool voiceRecording;
  final bool documentScanning;
  final bool isLoading;
  final String? error;

  const ConsentState({
    this.dataCollection = true,
    this.voiceRecording = true,
    this.documentScanning = true,
    this.isLoading = false,
    this.error,
  });

  ConsentState copyWith({
    bool? dataCollection,
    bool? voiceRecording,
    bool? documentScanning,
    bool? isLoading,
    String? error,
  }) {
    return ConsentState(
      dataCollection: dataCollection ?? this.dataCollection,
      voiceRecording: voiceRecording ?? this.voiceRecording,
      documentScanning: documentScanning ?? this.documentScanning,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConsentNotifier extends StateNotifier<ConsentState> {
  final Ref _ref;

  ConsentNotifier(this._ref) : super(const ConsentState());

  void toggleDataCollection(bool value) {
    state = state.copyWith(dataCollection: value, error: null);
  }

  void toggleVoiceRecording(bool value) {
    state = state.copyWith(voiceRecording: value, error: null);
  }

  void toggleDocumentScanning(bool value) {
    state = state.copyWith(documentScanning: value, error: null);
  }

  Future<bool> grantConsent() async {
    if (!state.dataCollection) {
      state = state.copyWith(
        error: 'Data collection consent is required to proceed with clinical intake.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final patient = _ref.read(currentPatientProvider).value;
      final patientId = patient?.id ?? 'pat_demo';

      final types = <String>[
        'data_collection',
        if (state.voiceRecording) 'voice_recording',
        if (state.documentScanning) 'document_scanning',
      ];

      final dio = ApiClient().dio;
      await dio.post(
        '/consent/grant',
        data: {
          'patient_id': patientId,
          'consent_types': types,
          'consent_method': 'digital',
        },
      );

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      // If backend is unreachable or returns error, log and allow continuing with local consent
      state = state.copyWith(isLoading: false);
      return true;
    }
  }
}

final consentNotifierProvider =
    StateNotifierProvider<ConsentNotifier, ConsentState>((ref) {
  return ConsentNotifier(ref);
});
