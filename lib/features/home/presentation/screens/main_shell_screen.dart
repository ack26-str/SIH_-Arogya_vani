import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class MainShellScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    HapticFeedback.lightImpact(); // Tactile feedback for elderly users
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context, ref);
    final currentIndex = navigationShell.currentIndex;

    final items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: l10n.home),
      _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: l10n.consultation),
      _NavItem(icon: Icons.folder_outlined, activeIcon: Icons.folder_rounded, label: l10n.records),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: l10n.profile),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(15, 23, 42, 0.06),
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        // Extra tall nav bar — easy to tap for elderly
        height: 84 + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isActive = currentIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => _onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 28,
                        color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 13,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
