import 'package:dio/dio.dart';
import '../../models/medical_record.dart';
import '../../models/medical_extraction.dart';
import '../../core/network/api_client.dart';
import 'document_service.dart';

class RealDocumentService implements DocumentService {
  final Dio _dio = ApiClient().dio;

  // In-memory cache of extracted data keyed by recordId for instant navigation
  final Map<String, MedicalExtraction> _extractionCache = {};

  @override
  Future<List<MedicalRecord>> getRecords(String patientId) async {
    try {
      final response = await _dio.get('/documents/patient/$patientId');
      if (response.data is List) {
        return (response.data as List).map((item) {
          final map = item as Map<String, dynamic>;
          final record = MedicalRecord.fromJson(map);
          if (record.extractedInformation != null) {
            _extractionCache[record.id] = record.extractedInformation!;
          }
          return record;
        }).toList();
      }
      return [];
    } catch (e) {
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

      final data = response.data as Map<String, dynamic>;
      return MedicalRecord.fromJson(data).copyWith(
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
        localPath: filePath,
        status: RecordStatus.uploading,
      );
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  @override
  Stream<int> processDocument(String recordId) async* {
    // Step 1: Upload verified
    yield 1;
    await Future.delayed(const Duration(milliseconds: 300));

    // Step 2: Optical scanning & multimodal OCR via Gemini
    yield 2;

    try {
      final response = await _dio.post(
        '/documents/$recordId/process',
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.data != null && response.data is Map<String, dynamic>) {
        final extraction = MedicalExtraction.fromJson(response.data as Map<String, dynamic>);
        _extractionCache[recordId] = extraction;
      }

      // Step 3: Identifying clinical entities & lab values
      yield 3;
      await Future.delayed(const Duration(milliseconds: 400));

      // Step 4: Structured clinical summary ready
      yield 4;
    } catch (e) {
      // Step 4 fallback to allow viewing whatever was extracted
      yield 4;
    }
  }

  @override
  Future<MedicalExtraction> getExtractedInformation(String recordId) async {
    if (_extractionCache.containsKey(recordId)) {
      return _extractionCache[recordId]!;
    }

    try {
      final response = await _dio.get('/documents/$recordId/extraction');
      if (response.data != null && response.data is Map<String, dynamic>) {
        final extraction = MedicalExtraction.fromJson(response.data as Map<String, dynamic>);
        _extractionCache[recordId] = extraction;
        return extraction;
      }
    } catch (_) {}

    return const MedicalExtraction();
  }

  @override
  Future<void> updateExtractedInformation(String recordId, MedicalExtraction updated) async {
    _extractionCache[recordId] = updated;
    try {
      await _dio.patch(
        '/documents/$recordId/extraction',
        data: updated.toJson(),
      );
    } catch (_) {}
  }
}
