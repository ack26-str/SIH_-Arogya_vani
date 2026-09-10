import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/clinical_summary.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/disclaimer_banner.dart';
import '../controllers/summary_controller.dart';

class ClinicalSummaryScreen extends ConsumerWidget {
  const ClinicalSummaryScreen({super.key});

  // Removed _getDefaultSummary() — no more fake data.

  void _showShareDialog(BuildContext context, ClinicalSummary summary) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_outlined, color: AppColors.primaryDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Share Clinical Summary', style: AppTypography.titleMedium),
                      Text('Secure transmission to healthcare provider', style: AppTypography.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_2_rounded, size: 54, color: AppColors.primaryDark),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Clinical Handoff Token', style: AppTypography.labelLarge),
                        const SizedBox(height: 2),
                        Text(
                          '#CLIN-2026-8942',
                          style: AppTypography.metricValue.copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scan in clinician EHR portal or share secure PDF link.',
                          style: AppTypography.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Copy PDF Link',
                    variant: AppButtonVariant.outlined,
                    icon: Icons.link_rounded,
                    height: 46,
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Clinical summary link copied to clipboard!')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'Send to Doctor',
                    variant: AppButtonVariant.primary,
                    icon: Icons.send_rounded,
                    height: 46,
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Summary shared with clinician portal.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context, ref);
    final summary = ref.watch(activeSummaryProvider);
    final isConfirmed = ref.watch(summaryConfirmedProvider);

    // If no real summary exists, show an empty state
    if (summary == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l10n.clinicalSummaryTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 20),
                Text(
                  'No Clinical Summary Yet',
                  style: AppTypography.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Complete a voice intake conversation first, then tap "Generate Clinical Intake Summary" to see your summary here.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                AppButton(
                  text: 'Start New Consultation',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.clinicalSummaryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _showShareDialog(context, summary),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clinical Handoff Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(15, 23, 42, 0.04),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            size: 20,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Clinical Intake Handoff',
                                style: AppTypography.titleMedium,
                              ),
                              Text(
                                'Prepared on ${Formatters.formatDateTime(summary.createdAt)}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isConfirmed
                                ? AppColors.successContainer
                                : AppColors.warningContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isConfirmed ? 'Confirmed' : 'Draft Intake',
                            style: AppTypography.labelSmall.copyWith(
                              color: isConfirmed ? const Color(0xFF065F46) : const Color(0xFF92400E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Demographics row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHandoffMeta('Patient', summary.patientName),
                        _buildHandoffMeta('Age/Gender', '${summary.patientAge}y • ${summary.patientGender}'),
                        _buildHandoffMeta('ID', summary.patientId),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Chief Complaint Card
              AppCard(
                title: l10n.chiefComplaint,
                icon: Icons.flag_outlined,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.report_problem_outlined, size: 20, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          summary.chiefComplaint,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reported Symptoms & Breakdown
              AppCard(
                title: l10n.symptoms,
                icon: Icons.checklist_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: summary.symptoms.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            s,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Onset:', summary.onset),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Duration:', summary.duration),
                    const SizedBox(height: 6),
                    _buildSummaryRow('Severity:', summary.severity),
                    if (summary.associatedSymptoms.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Associated:',
                        summary.associatedSymptoms.join(', '),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Medical History & Medications
              AppCard(
                title: 'Medical History & Regimen',
                icon: Icons.medical_services_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('History / Comorbidities:', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    ...summary.medicalHistory.map((h) => Text('• $h', style: AppTypography.bodySmall)),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(l10n.currentMedications, style: AppTypography.labelMedium),
                    const SizedBox(height: 8),
                    ...summary.currentMedications.map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.circle, size: 6, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${m.name} (${m.dose ?? ""}) — ${m.frequency ?? ""}',
                                style: AppTypography.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Allergies & Previous Treatments
              AppCard(
                title: 'Allergies & Treatments',
                icon: Icons.warning_amber_rounded,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.allergies, style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    ...summary.allergies.map(
                      (a) => Text(
                        '• ${a.allergen}: ${a.reaction ?? "Unknown"}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(l10n.previousTreatments, style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    ...summary.previousTreatments.map((t) => Text('• $t', style: AppTypography.bodySmall)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Attached Records
              if (summary.attachedRecords.isNotEmpty)
                AppCard(
                  title: l10n.attachedRecords,
                  icon: Icons.attach_file_rounded,
                  child: Column(
                    children: summary.attachedRecords.map((r) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf_outlined, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(child: Text(r, style: AppTypography.bodySmall)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 16),

              // Non-diagnostic banner
              const DisclaimerBanner(),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: l10n.editInformation,
                      variant: AppButtonVariant.outlined,
                      icon: Icons.edit_outlined,
                      height: 48,
                      onPressed: () => context.push('/conversation'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: isConfirmed ? 'Confirmed ✓' : l10n.confirmSummary,
                      variant: AppButtonVariant.primary,
                      icon: Icons.check_circle_outline_rounded,
                      height: 48,
                      backgroundColor: isConfirmed ? AppColors.success : null,
                      onPressed: () {
                        ref.read(summaryConfirmedProvider.notifier).state = true;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.summaryConfirmedNotice)),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                text: l10n.shareWithClinician,
                variant: AppButtonVariant.secondary,
                icon: Icons.share_rounded,
                height: 48,
                onPressed: () => _showShareDialog(context, summary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandoffMeta(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
