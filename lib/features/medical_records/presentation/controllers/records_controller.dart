import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../models/medical_record.dart';
import '../../../../models/medical_extraction.dart';
import '../../../../services/service_providers.dart';

class RecordsListNotifier extends StateNotifier<AsyncValue<List<MedicalRecord>>> {
  final Ref _ref;

  RecordsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadRecords();
  }

  Future<void> loadRecords() async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(documentServiceProvider);
      final patient = _ref.read(currentPatientProvider).value;
      final records = await service.getRecords(patient?.id ?? 'pat_001');
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<MedicalRecord> uploadAndProcessRecord({
    required String fileName,
    required String fileType,
    required int fileSize,
    String? filePath,
  }) async {
    final service = _ref.read(documentServiceProvider);
    final patient = _ref.read(currentPatientProvider).value;

    final newRecord = await service.uploadDocument(
      patient?.id ?? 'pat_001',
      fileName,
      fileType,
      fileSize,
      filePath: filePath,
    );

    // Refresh list
    await loadRecords();
    return newRecord;
  }

  Future<void> updateExtractedInfo(String recordId, MedicalExtraction updated) async {
    final service = _ref.read(documentServiceProvider);
    await service.updateExtractedInformation(recordId, updated);
    await loadRecords();
  }
}

final recordsListProvider =
    StateNotifierProvider<RecordsListNotifier, AsyncValue<List<MedicalRecord>>>((ref) {
  return RecordsListNotifier(ref);
});

// Processing step state for document processing screen (1 to 4)
final documentProcessingStepProvider = StateProvider<int>((ref) => 1);
final activeProcessingRecordProvider = StateProvider<MedicalRecord?>((ref) => null);
