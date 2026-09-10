import 'medication.dart';
import 'allergy.dart';
import 'lab_result.dart';
import 'symptom.dart';
import 'patient_info.dart';

class MedicalExtraction {
  final PatientInfo? patientInformation;
  final List<Symptom> symptoms;
  final List<String> diagnoses;
  final List<Medication> medications;
  final List<Allergy> allergies;
  final List<LabResult> labResults;
  final List<String> previousTreatments;
  final List<String> medicalHistory;

  const MedicalExtraction({
    this.patientInformation,
    this.symptoms = const [],
    this.diagnoses = const [],
    this.medications = const [],
    this.allergies = const [],
    this.labResults = const [],
    this.previousTreatments = const [],
    this.medicalHistory = const [],
  });

  MedicalExtraction copyWith({
    PatientInfo? patientInformation,
    List<Symptom>? symptoms,
    List<String>? diagnoses,
    List<Medication>? medications,
    List<Allergy>? allergies,
    List<LabResult>? labResults,
    List<String>? previousTreatments,
    List<String>? medicalHistory,
  }) {
    return MedicalExtraction(
      patientInformation: patientInformation ?? this.patientInformation,
      symptoms: symptoms ?? this.symptoms,
      diagnoses: diagnoses ?? this.diagnoses,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      labResults: labResults ?? this.labResults,
      previousTreatments: previousTreatments ?? this.previousTreatments,
      medicalHistory: medicalHistory ?? this.medicalHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_information': patientInformation?.toJson(),
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'diagnoses': diagnoses,
      'medications': medications.map((m) => m.toJson()).toList(),
      'allergies': allergies.map((a) => a.toJson()).toList(),
      'lab_results': labResults.map((l) => l.toJson()).toList(),
      'previous_treatments': previousTreatments,
      'medical_history': medicalHistory,
    };
  }

  factory MedicalExtraction.fromJson(Map<String, dynamic> json) {
    return MedicalExtraction(
      patientInformation: json['patient_information'] != null
          ? PatientInfo.fromJson(json['patient_information'] as Map<String, dynamic>)
          : null,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((s) => Symptom.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      diagnoses: (json['diagnoses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medications: (json['medications'] as List<dynamic>?)
              ?.map((m) => Medication.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((a) => Allergy.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      labResults: (json['lab_results'] as List<dynamic>?)
              ?.map((l) => LabResult.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      previousTreatments: (json['previous_treatments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medicalHistory: (json['medical_history'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
