import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../services/service_providers.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/disclaimer_banner.dart';
import '../../../medical_records/presentation/controllers/records_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context, ref);
    final patientAsync = ref.watch(currentPatientProvider);
    final recordsAsync = ref.watch(recordsListProvider);
    final selectedLang = ref.watch(selectedLanguageCodeProvider);

    final patient = patientAsync.value;
    final recordsCount = recordsAsync.value?.length ?? 0;

    final langOption = AppConstants.supportedLanguages.firstWhere(
      (l) => l.code == selectedLang,
      orElse: () => AppConstants.supportedLanguages.first,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Profile Identity Card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (patient?.name.isNotEmpty == true)
                              ? patient!.name[0].toUpperCase()
                              : 'P',
                          style: AppTypography.displayMedium.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      patient?.name ?? 'Ramesh Kumar',
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient?.age ?? 48} yrs • ${patient?.gender ?? 'Male'} • ${patient?.phone ?? '+91 98451 23456'}',
                      style: AppTypography.bodySmall,
                    ),
                    if (patient?.email != null && patient!.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        patient.email!,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Activity Stats
              Row(
                children: [
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('1', style: AppTypography.titleLarge),
                          const SizedBox(height: 2),
                          Text('Consultations', style: AppTypography.labelSmall),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.folder_outlined,
                              size: 20, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('$recordsCount', style: AppTypography.titleLarge),
                          const SizedBox(height: 2),
                          Text('Medical Records', style: AppTypography.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Language Setting Shortcut Card
              AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/language'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.language_rounded, size: 20, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preferred Language', style: AppTypography.labelLarge),
                          Text('${langOption.englishName} (${langOption.nativeName})',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Settings Shortcut Card
              AppCard(
                padding: const EdgeInsets.all(16),
                onTap: () => context.push('/settings'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.settings, style: AppTypography.labelLarge),
                          Text('Notifications, Privacy, Session reset',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Disclaimer
              const DisclaimerBanner(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
