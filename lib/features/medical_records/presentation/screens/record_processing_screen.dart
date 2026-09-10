import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../models/medical_record.dart';
import '../../../../services/service_providers.dart';
import '../controllers/records_controller.dart';

class RecordProcessingScreen extends ConsumerStatefulWidget {
  const RecordProcessingScreen({super.key});

  @override
  ConsumerState<RecordProcessingScreen> createState() => _RecordProcessingScreenState();
}

class _RecordProcessingScreenState extends ConsumerState<RecordProcessingScreen> {
  int _currentStep = 1;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  void _startProcessing() {
    final record = ref.read(activeProcessingRecordProvider);
    final service = ref.read(documentServiceProvider);
    final recordId = record?.id ?? 'rec_001';

    _subscription = service.processDocument(recordId).listen((step) async {
      if (mounted) {
        setState(() => _currentStep = step);
        if (step == 4) {
          try {
            final extraction = await service.getExtractedInformation(recordId);
            if (mounted && record != null) {
              ref.read(activeProcessingRecordProvider.notifier).state = record.copyWith(
                extractedInformation: extraction,
                status: RecordStatus.processed,
              );
            }
          } catch (_) {}

          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              ref.read(recordsListProvider.notifier).loadRecords();
              context.go('/record-details');
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final record = ref.watch(activeProcessingRecordProvider);
    final fileName = record?.fileName ?? 'Medical_Record.pdf';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Processing Record'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/records'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Animated Scanning Visual
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.document_scanner_rounded,
                    size: 48,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.analyzingDocument,
                style: AppTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                fileName,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // 4 Progress Steps Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProgressRow(
                      stepNumber: 1,
                      label: l10n.stepUploaded,
                      isDone: _currentStep > 1,
                      isActive: _currentStep == 1,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(color: AppColors.border, thickness: 2),
                        ),
                      ),
                    ),
                    _buildProgressRow(
                      stepNumber: 2,
                      label: l10n.stepExtracted,
                      isDone: _currentStep > 2,
                      isActive: _currentStep == 2,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(color: AppColors.border, thickness: 2),
                        ),
                      ),
                    ),
                    _buildProgressRow(
                      stepNumber: 3,
                      label: l10n.stepIdentifying,
                      isDone: _currentStep > 3,
                      isActive: _currentStep == 3,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          height: 24,
                          child: VerticalDivider(color: AppColors.border, thickness: 2),
                        ),
                      ),
                    ),
                    _buildProgressRow(
                      stepNumber: 4,
                      label: l10n.stepPreparing,
                      isDone: _currentStep >= 4,
                      isActive: _currentStep == 4,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Production engine status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'AI Clinical Vision Engine: Powered by Gemini Multimodal OCR',
                        textAlign: TextAlign.center,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_currentStep >= 4)
                AppButton(
                  text: 'View Extracted Information',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => context.go('/record-details'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressRow({
    required int stepNumber,
    required String label,
    required bool isDone,
    required bool isActive,
  }) {
    Widget indicator;
    Color textColor;

    if (isDone) {
      indicator = Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 18, color: Colors.white),
      );
      textColor = AppColors.textPrimary;
    } else if (isActive) {
      indicator = Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
            ),
          ),
        ),
      );
      textColor = AppColors.primaryDark;
    } else {
      indicator = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            '$stepNumber',
            style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
      textColor = AppColors.textMuted;
    }

    return Row(
      children: [
        indicator,
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: textColor,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
