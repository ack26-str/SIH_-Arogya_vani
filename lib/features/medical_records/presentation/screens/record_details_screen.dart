import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../models/medical_extraction.dart';
import '../../../../models/medication.dart';
import '../../../../models/allergy.dart';
import '../../../../models/lab_result.dart';
import '../../../../models/patient_info.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../controllers/records_controller.dart';

class RecordDetailsScreen extends ConsumerStatefulWidget {
  const RecordDetailsScreen({super.key});

  @override
  ConsumerState<RecordDetailsScreen> createState() => _RecordDetailsScreenState();
}

class _RecordDetailsScreenState extends ConsumerState<RecordDetailsScreen> {
  late MedicalExtraction _extraction;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final record = ref.read(activeProcessingRecordProvider);
    _extraction = record?.extractedInformation ??
        const MedicalExtraction(
          patientInformation: PatientInfo(
            age: '48',
            gender: 'Male',
          ),
          diagnoses: [
            'Acute Febrile Illness (Suspected Viral Syndrome)',
            'Type 2 Diabetes Mellitus',
          ],
          medications: [
            Medication(
              name: 'Metformin',
              dose: '500 mg',
              frequency: 'Twice daily',
            ),
            Medication(
              name: 'Paracetamol',
              dose: '650 mg',
              frequency: 'As needed for fever',
            ),
          ],
          allergies: [
            Allergy(allergen: 'Penicillin', reaction: 'Skin rash'),
          ],
          labResults: [
            LabResult(
              testName: 'Platelet Count',
              resultValue: '195,000',
              date: 'Aug 28, 2026',
            ),
            LabResult(
              testName: 'HbA1c',
              resultValue: '6.8',
              date: 'Aug 28, 2026',
            ),
          ],
          previousTreatments: [
            'Oral hydration therapy',
            'Paracetamol SOS',
          ],
          medicalHistory: [
            'Type 2 Diabetes since 2020',
          ],
        );
  }

  void _showAddMedicationDialog() {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Medication', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Medication Name (e.g. Paracetamol)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: doseCtrl,
              decoration: const InputDecoration(labelText: 'Dosage (e.g. 650mg)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: freqCtrl,
              decoration: const InputDecoration(labelText: 'Frequency (e.g. Twice daily)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  final updatedList = List<Medication>.from(_extraction.medications)
                    ..add(Medication(
                      name: nameCtrl.text.trim(),
                      dose: doseCtrl.text.trim(),
                      frequency: freqCtrl.text.trim(),
                    ));
                  _extraction = _extraction.copyWith(medications: updatedList);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddDiagnosisDialog() {
    final diagCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Diagnosis / Finding', style: AppTypography.titleMedium),
        content: TextField(
          controller: diagCtrl,
          decoration: const InputDecoration(labelText: 'Diagnosis Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (diagCtrl.text.isNotEmpty) {
                setState(() {
                  final updatedList = List<String>.from(_extraction.diagnoses)
                    ..add(diagCtrl.text.trim());
                  _extraction = _extraction.copyWith(diagnoses: updatedList);
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context, ref);
    final record = ref.watch(activeProcessingRecordProvider);
    
    final patientEntries = <MapEntry<String, String>>[];
    if (_extraction.patientInformation != null) {
      if (_extraction.patientInformation?.age != null) {
        patientEntries.add(MapEntry('Age', _extraction.patientInformation!.age!));
      }
      if (_extraction.patientInformation?.gender != null) {
        patientEntries.add(MapEntry('Gender', _extraction.patientInformation!.gender!));
      }
      if (_extraction.patientInformation?.weight != null) {
        patientEntries.add(MapEntry('Weight', _extraction.patientInformation!.weight!));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.extractedInfoTitle),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Alert Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 20,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.reviewNotice,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Patient Information Card
              if (patientEntries.isNotEmpty)
                AppCard(
                  title: l10n.patientInfo,
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: patientEntries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: AppTypography.bodySmall),
                            Text(
                              entry.value,
                              style: AppTypography.labelLarge.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (patientEntries.isNotEmpty) const SizedBox(height: 16),

              // Diagnoses
              AppCard(
                title: l10n.diagnoses,
                icon: Icons.health_and_safety_outlined,
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: _showAddDiagnosisDialog,
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _extraction.diagnoses.map((diag) {
                        return Chip(
                          label: Text(diag),
                          labelStyle: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.6),
                          deleteIcon: _isEditing ? const Icon(Icons.close, size: 14) : null,
                          onDeleted: _isEditing
                              ? () {
                                  setState(() {
                                    final list = List<String>.from(_extraction.diagnoses)
                                      ..remove(diag);
                                    _extraction = _extraction.copyWith(diagnoses: list);
                                  });
                                }
                              : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Medications Card
              AppCard(
                title: l10n.medications,
                icon: Icons.medication_outlined,
                trailing: _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                        onPressed: _showAddMedicationDialog,
                      )
                    : null,
                child: Column(
                  children: _extraction.medications.map((med) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.medication_rounded, size: 16, color: AppColors.primaryDark),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.name, style: AppTypography.labelLarge),
                                const SizedBox(height: 2),
                                Text(
                                  '${med.dose ?? ''} ${med.frequency != null ? '• ${med.frequency}' : ''}',
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (_isEditing)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () {
                                setState(() {
                                  final list = List<Medication>.from(_extraction.medications)
                                    ..remove(med);
                                  _extraction = _extraction.copyWith(medications: list);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Allergies Card
              AppCard(
                title: l10n.allergies,
                icon: Icons.warning_amber_rounded,
                child: Column(
                  children: _extraction.allergies.map((allergy) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.crisis_alert_rounded, size: 18, color: AppColors.error),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allergy.allergen,
                                  style: AppTypography.labelLarge.copyWith(
                                    color: const Color(0xFF7F1D1D),
                                  ),
                                ),
                                Text(
                                  'Reaction: ${allergy.reaction ?? 'Unknown'}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: const Color(0xFF991B1B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Lab Results Card
              AppCard(
                title: l10n.labResults,
                icon: Icons.biotech_outlined,
                child: Column(
                  children: _extraction.labResults.map((lab) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lab.testName, style: AppTypography.labelLarge.copyWith(fontSize: 13)),
                                const SizedBox(height: 2),
                                Text(
                                  'Date: ${lab.date ?? 'Unknown'}',
                                  style: AppTypography.labelSmall,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(lab.resultValue, style: AppTypography.metricValue),
                              const SizedBox(height: 4),
                              StatusChip.forLabStatus('Normal'),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Medical History Card
              AppCard(
                title: l10n.medicalHistory,
                icon: Icons.history_edu_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _extraction.medicalHistory.map((hist) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                          Expanded(child: Text(hist, style: AppTypography.bodySmall)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),

              // Save & Continue Button
              AppButton(
                text: 'Confirm & Continue Intake',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  if (record != null) {
                    ref.read(recordsListProvider.notifier).updateExtractedInfo(
                          record.id,
                          _extraction,
                        );
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verified records saved to clinical context.')),
                  );
                  context.push('/conversation');
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

