import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/disclaimer_banner.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context, ref);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Brand Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.medical_services_outlined,
                              size: 20,
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppConstants.appName,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Center Visual Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(15, 23, 42, 0.04),
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 32,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.welcomeHeadline,
                              style: AppTypography.displayMedium.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.welcomeSubtitle,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Feature Badges
                            _buildFeatureItem(
                              icon: Icons.record_voice_over_outlined,
                              title: 'Multilingual Voice & Chat',
                              subtitle: 'Speak or type in your native tongue',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              icon: Icons.document_scanner_outlined,
                              title: 'Medical Record OCR',
                              subtitle: 'Extract prescriptions & lab tests cleanly',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureItem(
                              icon: Icons.assignment_turned_in_outlined,
                              title: 'Doctor-Ready Summary',
                              subtitle: 'Clear clinical handoff for your provider',
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 16),

                      // Non-diagnostic note
                      const DisclaimerBanner(isCompact: true),
                      const SizedBox(height: 16),

                      // Action Buttons
                      AppButton(
                        text: l10n.getStarted,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.push('/language'),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () => context.go('/home'),
                          child: Text(
                            l10n.alreadyAccount,
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
