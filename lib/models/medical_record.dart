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
    return MedicalRecord(
      id: json['id'] as String,
      patientId: json['patientId'] as String,
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int? ?? 0,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      status: RecordStatus.values.byName(json['status'] as String? ?? 'processed'),
      extractedInformation: json['extractedInformation'] != null
          ? MedicalExtraction.fromJson(
              json['extractedInformation'] as Map<String, dynamic>)
          : null,
      localPath: json['localPath'] as String?,
    );
  }
}
