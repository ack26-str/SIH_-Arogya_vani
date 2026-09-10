import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../services/service_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/disclaimer_banner.dart';
import '../../../../shared/widgets/pending_feature_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../conversation/presentation/controllers/conversation_controller.dart';
import '../../../../models/conversation.dart';
import '../../../medical_records/presentation/controllers/records_controller.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context, ref);
    final patientAsync = ref.watch(currentPatientProvider);
    final recordsAsync = ref.watch(recordsListProvider);
    final pastConsultationsAsync = ref.watch(pastConsultationsProvider);

    final patientName = patientAsync.value?.name ?? 'Patient';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(recordsListProvider);
            ref.invalidate(pastConsultationsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Greeting Header ────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          size: 30,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.goodMorning},',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            patientName,
                            style: AppTypography.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                    // Notification bell — large tap target
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.notifications_none_rounded, size: 26),
                        color: AppColors.textSecondary,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No new clinical alerts')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Primary CTA: Start Consultation ───────────────────────
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(conversationNotifierProvider.notifier).initConversation();
                    context.push('/conversation');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(13, 148, 136, 0.30),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                                  const SizedBox(width: 6),
                                  Text(
                                    'AI Clinical Assistant',
                                    style: AppTypography.labelMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.startNewConsultation,
                          style: AppTypography.headlineLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tellUsWhatExperiencing,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 22),
                        // Large tap-friendly button
                        Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.mic_rounded, size: 24, color: AppColors.primaryDark),
                              const SizedBox(width: 10),
                              Text(
                                l10n.startNewConsultation,
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                // ── Quick Actions — 2-column large cards ──────────────────
                Text(l10n.quickActions, style: AppTypography.titleMedium),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildBigActionCard(
                        context,
                        icon: Icons.mic_rounded,
                        iconBg: AppColors.primaryContainer,
                        iconColor: AppColors.primaryDark,
                        title: 'Voice\nIntake',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(conversationNotifierProvider.notifier).initConversation();
                          context.push('/conversation');
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildBigActionCard(
                        context,
                        icon: Icons.cloud_upload_rounded,
                        iconBg: AppColors.secondaryContainer,
                        iconColor: AppColors.secondary,
                        title: 'Upload\nRecord',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/upload-record');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildBigActionCard(
                        context,
                        icon: Icons.history_rounded,
                        iconBg: AppColors.warningContainer,
                        iconColor: AppColors.warning,
                        title: 'Past\nVisits',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/clinical-summary');
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildBigActionCard(
                        context,
                        icon: Icons.folder_open_rounded,
                        iconBg: AppColors.successContainer,
                        iconColor: AppColors.success,
                        title: 'My\nRecords',
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.push('/records');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // ── Medical Records Summary ────────────────────────────────
                AppCard(
                  title: l10n.medicalRecordsTitle,
                  icon: Icons.folder_outlined,
                  trailing: TextButton(
                    onPressed: () => context.push('/records'),
                    child: Text(
                      l10n.viewRecords,
                      style: AppTypography.labelMedium.copyWith(color: AppColors.primary),
                    ),
                  ),
                  child: recordsAsync.when(
                    data: (records) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${records.length}',
                                style: AppTypography.displayMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  l10n.uploadedRecordsCount,
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: l10n.viewRecords,
                                  variant: AppButtonVariant.outlined,
                                  height: 56, // Larger for elderly
                                  onPressed: () => context.push('/records'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppButton(
                                  text: l10n.uploadRecord,
                                  variant: AppButtonVariant.primary,
                                  height: 56,
                                  onPressed: () => context.push('/upload-record'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (e, _) => Text(
                      'Failed to load records',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Integrated Hospital Services & ABHA ───────────────────
                Text('Integrated Services', style: AppTypography.titleMedium),
                const SizedBox(height: 12),
                const PendingFeatureCard(
                  title: 'ABHA Health Locker & Records',
                  subtitle: 'Ayushman Bharat Digital Mission (ABDM) Integration',
                  icon: Icons.badge_outlined,
                  explanation:
                      'Access your pan-India unified digital health records via ABHA. Fetch longitudinal OPD summaries, hospital lab results, and immunization histories. Awaiting NHA certification.',
                  expectedTimeline: 'Phase 2 rollout',
                ),
                const SizedBox(height: 12),
                const PendingFeatureCard(
                  title: 'Emergency Red-Flag Stratification',
                  subtitle: 'Rapid nurse triage for acute clinical presentations',
                  icon: Icons.emergency_rounded,
                  explanation:
                      'AI clinical analysis automatically detects emergency symptoms (acute chest pain, respiratory distress, trauma) to immediately summon triage staff and prioritize care.',
                  expectedTimeline: 'Phase 2 clinical protocol',
                ),
                const SizedBox(height: 24),

                // ── Previous Consultations ─────────────────────────────────
                Text(l10n.previousConsultations, style: AppTypography.titleMedium),
                const SizedBox(height: 14),
                pastConsultationsAsync.when(
                  data: (consultations) {
                    if (consultations.isEmpty) {
                      return AppCard(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
                          child: Column(
                            children: [
                              Icon(Icons.history_rounded, size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'No previous consultations yet.\nStart one to see your history here.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: consultations.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final conv = consultations[index];
                        final title = conv.collectedData.isNotEmpty
                            ? (conv.collectedData['title'] ?? 'General Consultation')
                            : 'General Consultation';
                        final status = conv.status == ConversationStatus.completed
                            ? 'Completed'
                            : conv.status == ConversationStatus.summarized
                                ? 'Summarized'
                                : 'In Progress';

                        final (chipBg, chipText) = switch (conv.status) {
                          ConversationStatus.completed => (
                              AppColors.successContainer,
                              const Color(0xFF065F46)
                            ),
                          ConversationStatus.summarized => (
                              AppColors.infoContainer,
                              const Color(0xFF1E40AF)
                            ),
                          ConversationStatus.inProgress => (
                              AppColors.warningContainer,
                              const Color(0xFF92400E)
                            ),
                        };

                        return AppCard(
                          padding: const EdgeInsets.all(18),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.push('/clinical-summary');
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_outlined,
                                  size: 26,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      Formatters.formatDate(conv.startedAt),
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              StatusChip(
                                label: status,
                                backgroundColor: chipBg,
                                textColor: chipText,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 26,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Failed to load history',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 24),

                const DisclaimerBanner(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
