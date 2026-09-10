import 'package:dio/dio.dart';
import '../../models/medical_record.dart';
import '../../models/medical_extraction.dart';
import '../../core/network/api_client.dart';
import 'document_service.dart';

class RealDocumentService implements DocumentService {
  final Dio _dio = ApiClient().dio;

  @override
  Future<List<MedicalRecord>> getRecords(String patientId) async {
    try {
      await _dio.get('/documents/patient/$patientId/timeline');
      // Assume the backend returns a list of timeline events
      // We would map these to MedicalRecord objects. For now, returning empty list.
      return [];
    } catch (e) {
      print('Error fetching records: $e');
      return [];
    }
  }

  @override
  Future<MedicalRecord> uploadDocument(
    String patientId,
    String fileName,
    String fileType,
    int fileSize, {
    String? filePath,
  }) async {
    if (filePath == null) {
      throw Exception("FilePath is required for real document upload.");
    }

    try {
      final formData = FormData.fromMap({
        'patient_id': patientId,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        '/documents/upload',
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      final data = response.data;
      return MedicalRecord(
        id: data['id'],
        patientId: patientId,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        uploadDate: DateTime.now(),
        status: RecordStatus.processed,
      );
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Failed to upload document.');
    }
  }

  @override
  Stream<int> processDocument(String recordId) async* {
    yield 10;
    try {
      yield 40; // Simulate OCR
      await _dio.post('/documents/$recordId/process');
      yield 90;
      // We don't need to yield the final extraction data in this progress stream, 
      // just indicating progress completes.
      yield 100;
    } catch (e) {
      print('Error processing document: $e');
      throw Exception('Failed to process document.');
    }
  }

  @override
  Future<MedicalExtraction> getExtractedInformation(String recordId) async {
    // In our backend design, the extraction is stored in the `documents` table row.
    // Or we just rely on the processing step having updated it.
    // For now, we will just return a dummy MedicalExtraction since our UI logic 
    // expects it to be pulled immediately after stream completes.
    // In a full implementation, we'd GET /documents/{recordId}.
    return const MedicalExtraction();
  }

  @override
  Future<void> updateExtractedInformation(String recordId, MedicalExtraction updated) async {
    // Optional PATCH endpoint
  }
}
