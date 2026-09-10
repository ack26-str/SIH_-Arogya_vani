import 'package:dio/dio.dart';
import '../../models/patient.dart';
import '../../core/network/api_client.dart';
import 'patient_service.dart';

class RealPatientService implements PatientService {
  final Dio _dio = ApiClient().dio;
  Patient? _currentPatient;

  @override
  Future<Patient?> getPatient() async {
    return _currentPatient;
  }

  @override
  Future<Patient> savePatient(Patient patient) async {
    try {
      final response = await _dio.post('/patients/register', data: patient.toJson());
      // The backend returns the full patient dict with the assigned ID.
      _currentPatient = Patient.fromJson(response.data);
      return _currentPatient!;
    } catch (e) {
      print('Error saving patient: $e');
      throw Exception('Failed to register patient with backend.');
    }
  }

  @override
  Future<void> updatePreferredLanguage(String languageCode) async {
    if (_currentPatient != null) {
      _currentPatient = _currentPatient!.copyWith(preferredLanguage: languageCode);
      // We could optionally PATCH to backend if supported, but for now we'll just keep it in memory
    }
  }

  @override
  Future<void> clearSession() async {
    _currentPatient = null;
  }
}
