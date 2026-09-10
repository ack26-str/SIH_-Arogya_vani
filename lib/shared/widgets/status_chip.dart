import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/medical_record.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusChip.fromRecordStatus(RecordStatus status) {
    switch (status) {
      case RecordStatus.processed:
        return const StatusChip(
          label: 'Processed',
          backgroundColor: AppColors.successContainer,
          textColor: Color(0xFF065F46),
          icon: Icons.check_circle_outline_rounded,
        );
      case RecordStatus.processing:
        return const StatusChip(
          label: 'Analyzing',
          backgroundColor: AppColors.primaryContainer,
          textColor: AppColors.primaryDark,
          icon: Icons.sync_rounded,
        );
      case RecordStatus.uploading:
        return const StatusChip(
          label: 'Uploading',
          backgroundColor: AppColors.secondaryContainer,
          textColor: Color(0xFF0369A1),
          icon: Icons.cloud_upload_outlined,
        );
      case RecordStatus.failed:
        return const StatusChip(
          label: 'Failed',
          backgroundColor: AppColors.errorContainer,
          textColor: Color(0xFF991B1B),
          icon: Icons.error_outline_rounded,
        );
    }
  }

  factory StatusChip.forLabStatus(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return const StatusChip(
          label: 'Normal',
          backgroundColor: AppColors.successContainer,
          textColor: Color(0xFF065F46),
        );
      case 'borderline':
      case 'elevated':
      case 'low':
        return const StatusChip(
          label: 'Borderline',
          backgroundColor: AppColors.warningContainer,
          textColor: Color(0xFF92400E),
        );
      case 'critical':
      case 'abnormal':
        return const StatusChip(
          label: 'Abnormal',
          backgroundColor: AppColors.errorContainer,
          textColor: Color(0xFF991B1B),
        );
      default:
        return StatusChip(
          label: status,
          backgroundColor: AppColors.surfaceMuted,
          textColor: AppColors.textSecondary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
