import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/pending_feature_card.dart';
import '../controllers/session_controller.dart';

class SessionSetupScreen extends ConsumerWidget {
  const SessionSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(sessionNotifierProvider);
    final notifier = ref.read(sessionNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kiosk Session & Department'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connectivity Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.wifi_tethering_rounded,
                        color: Color(0xFF065F46),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kiosk Network Online',
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Temporary session token will be generated on entry and purged after checkout.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Select Clinical Department',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'This customizes the clinical AI intake protocol for your OPD visit.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Option 1: Allopathic OPD
              _buildDepartmentCard(
                title: 'Allopathic OPD',
                subtitle: 'General Medicine, Pediatrics, Surgery, Orthopedics',
                description:
                    'Uses SOCRATES structured inquiry (Site, Onset, Character, Radiation, Associations, Timing, Exacerbating factors, Severity).',
                icon: Icons.local_hospital_outlined,
                isSelected: sessionState.department == 'ALLOPATHIC_OPD',
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.selectDepartment('ALLOPATHIC_OPD');
                },
              ),
              const SizedBox(height: 14),

              // Option 2: AYUSH OPD
              _buildDepartmentCard(
                title: 'AYUSH OPD',
                subtitle: 'Ayurveda, Yoga, Naturopathy, Unani, Siddha, Homeopathy',
                description:
                    'Includes traditional Dashavidha Pariksha holistic inquiry (Prakriti, Vikriti, Sara, Samhanana, Pramana, Satmya, Satva, Ahara Shakti, Vyayama Shakti, Vaya).',
                icon: Icons.spa_outlined,
                isSelected: sessionState.department == 'AYUSH_OPD',
                onTap: () {
                  HapticFeedback.lightImpact();
                  notifier.selectDepartment('AYUSH_OPD');
                },
              ),
              const SizedBox(height: 24),

              // Emergency Red-Flag Triage Card (Pending feature)
              const PendingFeatureCard(
                title: 'Emergency Red-Flag Screening',
                subtitle: 'Automated rapid triage for acute emergency vitals',
                icon: Icons.emergency_rounded,
                explanation:
                    'Red-Flag Screening continuously scans intake statements and vital readings for acute clinical warnings (such as crushing chest pain, anaphylaxis, severe respiratory distress, or stroke signs). When triggered, it immediately elevates patient priority to the ER desk. Pending hospital nursing triage integration.',
                expectedTimeline: 'Available in Phase 2 clinical rollout',
              ),
              const SizedBox(height: 28),

              // Proceed Button
              AppButton(
                text: 'Launch Kiosk Session',
                icon: Icons.arrow_forward_rounded,
                height: 56,
                isLoading: sessionState.isLoading,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final ok = await notifier.initKioskSession();
                  if (ok && context.mounted) {
                    context.go('/home');
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.3) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.titleSmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                              color: isSelected ? AppColors.primary : Colors.transparent,
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
