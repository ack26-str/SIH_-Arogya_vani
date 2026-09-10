import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/medical_record.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../controllers/records_controller.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  final bool autoTriggerUpload;

  const MedicalRecordsScreen({
    super.key,
    this.autoTriggerUpload = false,
  });

  @override
  ConsumerState<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoTriggerUpload) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleFilePick();
        }
      });
    }
  }

  Future<void> _handleFilePick([BuildContext? ctx, WidgetRef? r]) async {
    try {
      // file_picker v12: pickFile returns a single PlatformFile?
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (file == null) return; // user cancelled
      if (file.path == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not access file path. Please try again.')),
          );
        }
        return;
      }

      final record = await ref
          .read(recordsListProvider.notifier)
          .uploadAndProcessRecord(
            fileName: file.name,
            fileType: file.extension ?? 'pdf',
            fileSize: file.lengthSync() ?? 0,
            filePath: file.path,
          );

      ref.read(activeProcessingRecordProvider.notifier).state = record;
      if (mounted) {
        context.push('/record-processing');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handleSampleUpload(dynamic arg1, [dynamic arg2, dynamic arg3, dynamic arg4]) {
    // Overloaded to support both:
    // (sampleName, type) AND (context, ref, sampleName, type)
    final String sampleName = (arg3 ?? arg1).toString();
    final String type = (arg4 ?? arg2).toString();

    // Sample uploads don't need a real file — create a local demo record
    // and jump straight to the processing screen.
    final demoRecord = MedicalRecord(
      id: 'demo_${sampleName.hashCode.abs()}',
      patientId: 'pat_demo',
      fileName: sampleName,
      fileType: type,
      fileSize: 1250000,
      uploadDate: DateTime.now(),
      status: RecordStatus.processing,
    );
    ref.read(activeProcessingRecordProvider.notifier).state = demoRecord;
    if (mounted) {
      context.push('/record-processing');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final recordsAsync = ref.watch(recordsListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.medicalRecordsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: l10n.uploadRecord,
            onPressed: () => _handleFilePick(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Banner Card
              AppCard(
                backgroundColor: AppColors.surface,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 28,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.uploadTitle,
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.uploadSubtitle,
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: l10n.chooseFile,
                            icon: Icons.file_upload_outlined,
                            height: 44,
                            onPressed: () => _handleFilePick(context, ref),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Quick Sample Records for instant testing
                    Text(
                      'Or load a sample clinical document:',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Colors.red),
                          label: const Text('Complete Blood Count (PDF)'),
                          labelStyle: AppTypography.labelSmall,
                          backgroundColor: AppColors.surfaceMuted,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () => _handleSampleUpload(
                            context,
                            ref,
                            'CBC_Lab_Report_2026.pdf',
                            'pdf',
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.image_outlined, size: 16, color: Colors.blue),
                          label: const Text('Prescription Note (JPG)'),
                          labelStyle: AppTypography.labelSmall,
                          backgroundColor: AppColors.surfaceMuted,
                          side: const BorderSide(color: AppColors.border),
                          onPressed: () => _handleSampleUpload(
                            context,
                            ref,
                            'Diabetes_Prescription.jpg',
                            'jpg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Uploaded Records Section
              Text(
                'Indexed Documents',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 12),

              recordsAsync.when(
                data: (records) {
                  if (records.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.folder_open_rounded,
                      title: 'No Medical Records Uploaded',
                      description:
                          'Upload test results, discharge summaries, or prescriptions to auto-extract your clinical context.',
                      actionLabel: l10n.uploadRecord,
                      onAction: () => _handleFilePick(context, ref),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final isPdf = record.fileType.toLowerCase() == 'pdf';

                      return AppCard(
                        padding: const EdgeInsets.all(16),
                        onTap: () {
                          if (record.status == RecordStatus.processed) {
                            ref.read(activeProcessingRecordProvider.notifier).state = record;
                            context.push('/record-details');
                          } else {
                            ref.read(activeProcessingRecordProvider.notifier).state = record;
                            context.push('/record-processing');
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isPdf
                                    ? const Color(0xFFFEE2E2)
                                    : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                                color: isPdf ? const Color(0xFFDC2626) : AppColors.primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.fileName,
                                    style: AppTypography.labelLarge,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${Formatters.formatFileSize(record.fileSize)} • ${Formatters.formatDate(record.uploadDate)}',
                                    style: AppTypography.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StatusChip.fromRecordStatus(record.status),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Failed to load records: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
