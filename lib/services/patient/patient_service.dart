import '../../models/patient.dart';

abstract class PatientService {
  Future<Patient?> getPatient();
  Future<Patient> savePatient(Patient patient);
  Future<void> updatePreferredLanguage(String languageCode);
  Future<void> clearSession();
}
