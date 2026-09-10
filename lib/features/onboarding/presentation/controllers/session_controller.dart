import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/network/api_client.dart';
import '../../../../services/service_providers.dart';

class SessionState {
  final String department;
  final String? sessionId;
  final bool isConnected;
  final bool isLoading;
  final String? error;

  const SessionState({
    this.department = 'ALLOPATHIC_OPD',
    this.sessionId,
    this.isConnected = true,
    this.isLoading = false,
    this.error,
  });

  SessionState copyWith({
    String? department,
    String? sessionId,
    bool? isConnected,
    bool? isLoading,
    String? error,
  }) {
    return SessionState(
      department: department ?? this.department,
      sessionId: sessionId ?? this.sessionId,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref _ref;

  SessionNotifier(this._ref) : super(const SessionState());

  void selectDepartment(String dept) {
    state = state.copyWith(department: dept);
  }

  Future<bool> initKioskSession() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final patient = _ref.read(currentPatientProvider).value;
      final patientId = patient?.id ?? 'pat_demo';
      final lang = _ref.read(selectedLanguageCodeProvider);

      final dio = ApiClient().dio;
      final response = await dio.post(
        '/sessions/create',
        data: {
          'patient_id': patientId,
          'department_config': state.department,
          'language': lang,
        },
      );

      final data = response.data;
      final newSessionId = data['id']?.toString() ?? 'sess_local';

      state = state.copyWith(
        sessionId: newSessionId,
        isConnected: true,
        isLoading: false,
      );
      return true;
    } catch (e) {
      // Backend offline or mock: create a fallback local session ID so the user is not blocked
      final fallbackId = 'sess_${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
      state = state.copyWith(
        sessionId: fallbackId,
        isConnected: false,
        isLoading: false,
      );
      return true;
    }
  }
}

final sessionNotifierProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});
