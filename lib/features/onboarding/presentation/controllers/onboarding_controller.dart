import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../models/patient.dart';
import '../../../../services/service_providers.dart';

final onboardingLoadingProvider = StateProvider<bool>((ref) => false);

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingController {
  final Ref _ref;

  OnboardingController(this._ref);

  void selectLanguage(String code) {
    _ref.read(selectedLanguageCodeProvider.notifier).state = code;
    final patientState = _ref.read(currentPatientProvider);
    if (patientState.hasValue && patientState.value != null) {
      final updated = patientState.value!.copyWith(preferredLanguage: code);
      _ref.read(currentPatientProvider.notifier).savePatient(updated);
    }
  }

  Future<void> submitProfile({
    required String name,
    required int age,
    required String gender,
    required String phone,
    String? email,
  }) async {
    _ref.read(onboardingLoadingProvider.notifier).state = true;
    try {
      final selectedLanguage = _ref.read(selectedLanguageCodeProvider);
      final newPatient = Patient(
        id: 'pat_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
        name: name,
        age: age,
        gender: gender,
        phone: phone,
        email: email?.trim().isEmpty == true ? null : email,
        preferredLanguage: selectedLanguage,
      );

      await _ref.read(currentPatientProvider.notifier).savePatient(newPatient);
    } finally {
      _ref.read(onboardingLoadingProvider.notifier).state = false;
    }
  }
}
