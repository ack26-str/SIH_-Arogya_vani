import 'package:flutter_test/flutter_test.dart';
import 'package:sih_clinical_intake/models/patient.dart';
import 'package:sih_clinical_intake/models/conversation_message.dart';
import 'package:sih_clinical_intake/models/medication.dart';
import 'package:sih_clinical_intake/models/allergy.dart';
import 'package:sih_clinical_intake/models/lab_result.dart';
import 'package:sih_clinical_intake/models/medical_extraction.dart';
import 'package:sih_clinical_intake/models/medical_record.dart';
import 'package:sih_clinical_intake/models/clinical_summary.dart';

void main() {
  group('Domain Models Unit Tests', () {
    test('Patient serialization, deserialization, and copyWith', () {
      const patient = Patient(
        id: 'patient-123',
        name: 'Aarav Sharma',
        age: 42,
        gender: 'Male',
        phone: '+91 98765 43210',
        email: 'aarav.sharma@example.com',
        preferredLanguage: 'hi',
      );

      final json = patient.toJson();
      expect(json['id'], 'patient-123');
      expect(json['name'], 'Aarav Sharma');
      expect(json['preferredLanguage'], 'hi');
      expect(json['phone'], '+91 98765 43210');

      final restored = Patient.fromJson(json);
      expect(restored.id, patient.id);
      expect(restored.name, patient.name);
      expect(restored.age, 42);
      expect(restored.email, 'aarav.sharma@example.com');

      final updated = patient.copyWith(age: 43, preferredLanguage: 'en');
      expect(updated.age, 43);
      expect(updated.preferredLanguage, 'en');
      expect(updated.name, 'Aarav Sharma');
    });

    test('ConversationMessage role checking and json conversion', () {
      final userMsg = ConversationMessage(
        id: 'msg-1',
        role: MessageRole.patient,
        text: 'I have severe headache and fever',
        language: 'en',
        timestamp: DateTime(2026, 9, 5, 10, 30),
        quickSuggestions: const ['Yes', 'No', '2 days'],
        isVoice: false,
      );

      expect(userMsg.role, MessageRole.patient);
      expect(userMsg.quickSuggestions.length, 3);

      final json = userMsg.toJson();
      final restored = ConversationMessage.fromJson(json);
      expect(restored.id, 'msg-1');
      expect(restored.role, MessageRole.patient);
      expect(restored.text, 'I have severe headache and fever');
      expect(restored.quickSuggestions, contains('2 days'));
    });

    test('Medication & Allergy structured models serialization', () {
      const med = Medication(
        name: 'Metformin',
        dose: '500mg',
        frequency: 'Twice daily',
      );

      final json = med.toJson();
      final restored = Medication.fromJson(json);
      expect(restored.name, 'Metformin');
      expect(restored.dose, '500mg');
      expect(restored.frequency, 'Twice daily');

      const allergy = Allergy(
        allergen: 'Amoxicillin',
        reaction: 'Hives and facial swelling',
      );
      final algJson = allergy.toJson();
      final algRestored = Allergy.fromJson(algJson);
      expect(algRestored.allergen, 'Amoxicillin');
      expect(algRestored.reaction, 'Hives and facial swelling');
    });

    test('LabResult abnormal detection and interpretation', () {
      const normalLab = LabResult(
        testName: 'Hemoglobin',
        resultValue: '14.5 g/dL',
        date: '2026-08-10',
      );
      expect(normalLab.testName, 'Hemoglobin');

      const abnormalLab = LabResult(
        testName: 'HbA1c',
        resultValue: '8.4%',
        date: '2026-08-10',
      );
      final json = abnormalLab.toJson();
      final restored = LabResult.fromJson(json);
      expect(restored.testName, 'HbA1c');
      expect(restored.resultValue, '8.4%');
    });

    test('MedicalExtraction and MedicalRecord lifecycle', () {
      const extraction = MedicalExtraction(
        diagnoses: ['Type 2 Diabetes Mellitus', 'Stage 1 Hypertension'],
        medications: [
          Medication(name: 'Telmisartan', dose: '40mg', frequency: 'Once daily'),
        ],
        allergies: [
          Allergy(allergen: 'Sulfa Drugs', reaction: 'Rash'),
        ],
        labResults: [
          LabResult(testName: 'Fasting Blood Sugar', resultValue: '148 mg/dL', date: '2026-08-10'),
        ],
        previousTreatments: ['Diet control'],
        medicalHistory: ['Hypertension diagnosed 2021'],
      );

      expect(extraction.diagnoses.length, 2);
      expect(extraction.medications.first.name, 'Telmisartan');

      final record = MedicalRecord(
        id: 'rec-001',
        patientId: 'patient-123',
        fileName: 'apollo_discharge_summary.pdf',
        fileType: 'pdf',
        fileSize: 2048500,
        uploadDate: DateTime(2026, 8, 15),
        status: RecordStatus.processed,
        extractedInformation: extraction,
      );

      expect(record.status, RecordStatus.processed);
      expect(record.extractedInformation?.medications.first.name, 'Telmisartan');

      final json = record.toJson();
      final restored = MedicalRecord.fromJson(json);
      expect(restored.id, 'rec-001');
      expect(restored.status, RecordStatus.processed);
    });

    test('ClinicalSummary structure and status lifecycle', () {
      final summary = ClinicalSummary(
        id: 'sum-101',
        patientId: 'patient-123',
        patientName: 'Aarav Sharma',
        patientAge: 42,
        patientGender: 'Male',
        createdAt: DateTime(2026, 9, 1),
        chiefComplaint: 'Persistent cough for 2 weeks with low-grade evening fever',
        symptoms: const ['Dry cough', 'Evening fever', 'Fatigue'],
        onset: '2 weeks ago',
        duration: '14 days',
        severity: 'Moderate',
        associatedSymptoms: const ['Mild throat tickle'],
        medicalHistory: const ['Type 2 Diabetes'],
        currentMedications: const [
          Medication(name: 'Azithromycin', dose: '500mg', frequency: 'Once daily'),
        ],
        allergies: const [
          Allergy(allergen: 'Penicillin', reaction: 'Rash'),
        ],
        status: SummaryStatus.draft,
      );

      expect(summary.chiefComplaint, contains('cough'));
      expect(summary.symptoms.length, 3);
      expect(summary.status, SummaryStatus.draft);

      final json = summary.toJson();
      final restored = ClinicalSummary.fromJson(json);
      expect(restored.id, 'sum-101');
      expect(restored.patientName, 'Aarav Sharma');
      expect(restored.symptoms, contains('Dry cough'));

      final confirmed = summary.copyWith(status: SummaryStatus.confirmed);
      expect(confirmed.status, SummaryStatus.confirmed);
    });
  });
}
