import 'medication.dart';
import 'allergy.dart';

enum SummaryStatus { draft, confirmed, shared }

class ClinicalSummary {
  final String id;
  final String patientId;
  final String patientName;
  final int patientAge;
  final String patientGender;
  final DateTime createdAt;
  final String chiefComplaint;
  final List<String> symptoms;
  final String onset;
  final String duration;
  final String severity;
  final List<String> associatedSymptoms;
  final List<String> medicalHistory;
  final List<Medication> currentMedications;
  final List<Allergy> allergies;
  final List<String> previousTreatments;
  final List<String> attachedRecords;
  final String additionalNotes;
  final String? clinicianNotes;
  final SummaryStatus status;

  const ClinicalSummary({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientAge,
    required this.patientGender,
    required this.createdAt,
    required this.chiefComplaint,
    required this.symptoms,
    required this.onset,
    required this.duration,
    required this.severity,
    this.associatedSymptoms = const [],
    this.medicalHistory = const [],
    this.currentMedications = const [],
    this.allergies = const [],
    this.previousTreatments = const [],
    this.attachedRecords = const [],
    this.additionalNotes = '',
    this.clinicianNotes,
    this.status = SummaryStatus.draft,
  });

  ClinicalSummary copyWith({
    String? id,
    String? patientId,
    String? patientName,
    int? patientAge,
    String? patientGender,
    DateTime? createdAt,
    String? chiefComplaint,
    List<String>? symptoms,
    String? onset,
    String? duration,
    String? severity,
    List<String>? associatedSymptoms,
    List<String>? medicalHistory,
    List<Medication>? currentMedications,
    List<Allergy>? allergies,
    List<String>? previousTreatments,
    List<String>? attachedRecords,
    String? additionalNotes,
    String? clinicianNotes,
    SummaryStatus? status,
  }) {
    return ClinicalSummary(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientGender: patientGender ?? this.patientGender,
      createdAt: createdAt ?? this.createdAt,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      onset: onset ?? this.onset,
      duration: duration ?? this.duration,
      severity: severity ?? this.severity,
      associatedSymptoms: associatedSymptoms ?? this.associatedSymptoms,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      currentMedications: currentMedications ?? this.currentMedications,
      allergies: allergies ?? this.allergies,
      previousTreatments: previousTreatments ?? this.previousTreatments,
      attachedRecords: attachedRecords ?? this.attachedRecords,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      clinicianNotes: clinicianNotes ?? this.clinicianNotes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'createdAt': createdAt.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'symptoms': symptoms,
      'onset': onset,
      'duration': duration,
      'severity': severity,
      'associatedSymptoms': associatedSymptoms,
      'medicalHistory': medicalHistory,
      'currentMedications': currentMedications.map((m) => m.toJson()).toList(),
      'allergies': allergies.map((a) => a.toJson()).toList(),
      'previousTreatments': previousTreatments,
      'attachedRecords': attachedRecords,
      'additionalNotes': additionalNotes,
      'clinicianNotes': clinicianNotes,
      'status': status.name,
    };
  }

  factory ClinicalSummary.fromJson(Map<String, dynamic> json) {
    return ClinicalSummary(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      patientName: json['patientName'] as String,
      patientAge: json['patientAge'] as int,
      patientGender: json['patientGender'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      chiefComplaint: json['chiefComplaint'] as String,
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      onset: json['onset'] as String,
      duration: json['duration'] as String,
      severity: json['severity'] as String,
      associatedSymptoms: (json['associatedSymptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      medicalHistory: (json['medicalHistory'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      currentMedications: (json['currentMedications'] as List<dynamic>?)
              ?.map((m) => Medication.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((a) => Allergy.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      previousTreatments: (json['previousTreatments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      attachedRecords: (json['attachedRecords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      additionalNotes: json['additionalNotes'] as String? ?? '',
      clinicianNotes: json['clinicianNotes'] as String?,
      status:
          SummaryStatus.values.byName(json['status'] as String? ?? 'draft'),
    );
  }
}
