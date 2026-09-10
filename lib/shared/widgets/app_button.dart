import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, ghost }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
    this.backgroundColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    BorderSide border;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = widget.backgroundColor ?? AppColors.primary;
        fg = AppColors.textOnPrimary;
        border = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bg = AppColors.primaryContainer;
        fg = AppColors.primaryDark;
        border = BorderSide.none;
        break;
      case AppButtonVariant.outlined:
        bg = Colors.transparent;
        fg = AppColors.primary;
        border = const BorderSide(color: AppColors.border, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        border = BorderSide.none;
        break;
    }

    return AnimatedScale(
      scale: _isPressed && isEnabled ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: Material(
          color: isEnabled ? bg : bg.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, size: 18, color: fg),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTypography.labelLarge.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
