import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../services/service_providers.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primaryDark),
            ),
            const SizedBox(width: 10),
            Text(AppConstants.appName, style: AppTypography.titleMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0 (SIH Prototype)', style: AppTypography.bodySmall),
            const SizedBox(height: 8),
            Text(
              'AarogyaVani is a multimodal, multilingual AI clinical intake assistant designed for the Smart India Hackathon (SIH). It facilitates structured patient health capture, medical document OCR, and physician handoff.',
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppConstants.nonDiagnosticDisclaimer,
                style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Privacy & Security', style: AppTypography.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Protection Architecture:',
                style: AppTypography.labelLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '• No permanent cloud storage without patient consent.\n'
                '• Document processing occurs via isolated pipeline abstractions.\n'
                '• Ready for HIPAA/GDPR-aligned encrypted EHR synchronization in Phase 2.\n'
                '• All clinical intake data can be purged at any time.',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _handleResetSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Intake Session?'),
        content: const Text(
          'This will clear current session data and return to the onboarding flow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(currentPatientProvider.notifier).clearSession();
      if (mounted) {
        context.go('/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final selectedLang = ref.watch(selectedLanguageCodeProvider);
    final langOption = AppConstants.supportedLanguages.firstWhere(
      (l) => l.code == selectedLang,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Language Section
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => context.push('/language'),
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Language', style: AppTypography.labelLarge),
                        Text('${langOption.englishName} • ${langOption.nativeName}',
                            style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Notifications
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(l10n.notifications, style: AppTypography.labelLarge),
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Privacy & Data
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => _showPrivacyDialog(context),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.privacyData, style: AppTypography.labelLarge),
                        Text('Data retention, consent & security',
                            style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // About
            AppCard(
              padding: const EdgeInsets.all(16),
              onTap: () => _showAboutDialog(context),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.aboutApp, style: AppTypography.labelLarge),
                        Text('Version 1.0.0 • SIH 2026', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Reset Session / Logout
            AppButton(
              text: l10n.logout,
              variant: AppButtonVariant.outlined,
              icon: Icons.logout_rounded,
              onPressed: _handleResetSession,
            ),
          ],
        ),
      ),
    );
  }
}
