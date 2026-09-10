import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/pending_feature_card.dart';
import '../controllers/consent_controller.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentState = ref.watch(consentNotifierProvider);
    final notifier = ref.read(consentNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Patient Consent & Privacy'),
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
              // DPDP Compliance Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_user_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DPDP Act 2023 Compliant',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your health data is encrypted and used solely for this consultation session. You maintain granular control and can revoke consent at any time.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.4,
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
                'Granular Permissions',
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Please select the services you authorize for this clinical intake.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Data Collection (Mandatory)
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryDark,
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
                              Text(
                                'Clinical Data Collection',
                                style: AppTypography.titleSmall,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Required',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Allows recording your chief complaint, symptoms, and medical history to formulate the doctor intake note.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: consentState.dataCollection,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        notifier.toggleDataCollection(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Voice Recording
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.mic_none_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Voice & Speech Processing',
                            style: AppTypography.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enables multilingual speech-to-text and conversational voice prompts via Bhashini AI.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: consentState.voiceRecording,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        notifier.toggleVoiceRecording(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Document Scanning
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.document_scanner_outlined,
                        color: AppColors.warning,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Record OCR',
                            style: AppTypography.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Extracts vital parameters and past medications from uploaded lab tests and prescriptions.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: consentState.documentScanning,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        HapticFeedback.lightImpact();
                        notifier.toggleDocumentScanning(val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. ABHA ID Linking (Pending integration)
              const PendingFeatureCard(
                title: 'ABHA Health ID Linking',
                subtitle: 'Consent to link longitudinal Ayushman Bharat records',
                icon: Icons.account_balance_outlined,
                explanation:
                    'ABHA (Ayushman Bharat Health Account) consent linking enables automatic synchronization of your national digital health records with the hospital information system. Awaiting National Health Authority (NHA) production gateway clearance.',
                expectedTimeline: 'Available in Phase 2 ABDM integration',
              ),
              const SizedBox(height: 24),

              if (consentState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          consentState.error!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Continue Button
              AppButton(
                text: 'Agree & Proceed',
                icon: Icons.check_circle_outline_rounded,
                height: 56,
                isLoading: consentState.isLoading,
                onPressed: () async {
                  HapticFeedback.mediumImpact();
                  final success = await notifier.grantConsent();
                  if (success && context.mounted) {
                    context.push('/session-setup');
                  }
                },
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  'By proceeding, you verify that you are the patient or an authorized caregiver.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
