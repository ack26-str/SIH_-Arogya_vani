import 'dart:convert';
import 'medical_extraction.dart';

enum RecordStatus { uploading, processing, processed, failed }

class MedicalRecord {
  final String id;
  final String patientId;
  final String fileName;
  final String fileType; // pdf, jpg, png, etc.
  final int fileSize;
  final DateTime uploadDate;
  final RecordStatus status;
  final MedicalExtraction? extractedInformation;
  final String? localPath;

  const MedicalRecord({
    required this.id,
    required this.patientId,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    required this.status,
    this.extractedInformation,
    this.localPath,
  });

  MedicalRecord copyWith({
    String? id,
    String? patientId,
    String? fileName,
    String? fileType,
    int? fileSize,
    DateTime? uploadDate,
    RecordStatus? status,
    MedicalExtraction? extractedInformation,
    String? localPath,
  }) {
    return MedicalRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      status: status ?? this.status,
      extractedInformation: extractedInformation ?? this.extractedInformation,
      localPath: localPath ?? this.localPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'status': status.name,
      'extractedInformation': extractedInformation?.toJson(),
      'localPath': localPath,
    };
  }

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    RecordStatus parsedStatus = RecordStatus.processed;
    final statusStr = (json['status'] as String?)?.toLowerCase();
    if (statusStr != null) {
      for (final s in RecordStatus.values) {
        if (s.name.toLowerCase() == statusStr) {
          parsedStatus = s;
          break;
        }
      }
    }

    MedicalExtraction? extraction;
    if (json['extractedInformation'] != null && json['extractedInformation'] is Map<String, dynamic>) {
      extraction = MedicalExtraction.fromJson(json['extractedInformation'] as Map<String, dynamic>);
    } else if (json['extraction'] != null && json['extraction'] is Map<String, dynamic>) {
      extraction = MedicalExtraction.fromJson(json['extraction'] as Map<String, dynamic>);
    } else if (json['extraction_json'] != null && json['extraction_json'] is String) {
      try {
        final decoded = jsonDecode(json['extraction_json'] as String);
        if (decoded is Map<String, dynamic>) {
          extraction = MedicalExtraction.fromJson(decoded);
        }
      } catch (_) {}
    }

    return MedicalRecord(
      id: json['id'] as String? ?? 'rec_${DateTime.now().millisecondsSinceEpoch}',
      patientId: (json['patientId'] ?? json['patient_id']) as String? ?? 'pat_001',
      fileName: (json['fileName'] ?? json['file_name']) as String? ?? 'Medical Document',
      fileType: (json['fileType'] ?? json['file_type']) as String? ?? 'pdf',
      fileSize: (json['fileSize'] ?? json['file_size']) as int? ?? 0,
      uploadDate: DateTime.tryParse(json['uploadDate']?.toString() ?? json['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: parsedStatus,
      extractedInformation: extraction,
      localPath: json['localPath'] as String?,
    );
  }
}
