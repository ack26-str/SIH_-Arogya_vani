import '../../models/medical_record.dart';
import '../../models/medical_extraction.dart';

abstract class DocumentService {
  Future<List<MedicalRecord>> getRecords(String patientId);
  Future<MedicalRecord> uploadDocument(
    String patientId,
    String fileName,
    String fileType,
    int fileSize, {
    String? filePath,
  });
  Stream<int> processDocument(String recordId);
  Future<MedicalExtraction> getExtractedInformation(String recordId);
  Future<void> updateExtractedInformation(String recordId, MedicalExtraction updated);
}
