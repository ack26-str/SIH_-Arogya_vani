import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/pending_feature_card.dart';
import '../controllers/onboarding_controller.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = 'Male';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final controller = ref.read(onboardingControllerProvider);
      await controller.submitProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        gender: _selectedGender,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        context.push('/consent');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final isLoading = ref.watch(onboardingLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profileSetup),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileSetupDesc,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Name field
                AppTextField(
                  label: l10n.fullName,
                  hint: 'e.g. Ramesh Kumar',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, 'Please enter your full name'),
                ),
                const SizedBox(height: 16),

                // Age and Gender row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppTextField(
                        label: l10n.age,
                        hint: '48',
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.calendar_today_outlined,
                        validator: Validators.age,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.gender,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: ['Male', 'Female', 'Other'].map((gender) {
                                final isSelected = _selectedGender == gender;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _selectedGender = gender),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.primaryContainer
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        gender == 'Male'
                                            ? l10n.male
                                            : (gender == 'Female' ? l10n.female : l10n.other),
                                        style: AppTypography.labelMedium.copyWith(
                                          color: isSelected
                                              ? AppColors.primaryDark
                                              : AppColors.textSecondary,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Phone number
                AppTextField(
                  label: l10n.phone,
                  hint: '9845123456',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.phone,
                ),
                const SizedBox(height: 16),

                // Email (Optional)
                AppTextField(
                  label: l10n.email,
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  validator: Validators.optionalEmail,
                ),
                const SizedBox(height: 20),

                // ABHA ID Linking (Pending integration)
                const PendingFeatureCard(
                  title: 'ABHA Health ID / Number',
                  subtitle: 'Fetch profile via Ayushman Bharat Digital Mission',
                  icon: Icons.badge_outlined,
                  explanation:
                      'Linking your 14-digit ABHA ID will automatically populate your demographic details, previous hospital encounters, and verified clinical history via ABDM OTP verification.',
                  expectedTimeline: 'Available in Phase 2 integration',
                ),
                const SizedBox(height: 32),

                // Submit CTA
                AppButton(
                  text: l10n.continueBtn,
                  isLoading: isLoading,
                  icon: Icons.check_rounded,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push('/consent'),
                    child: Text(
                      l10n.skip,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
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
