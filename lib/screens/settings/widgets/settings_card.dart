import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Flat, bordered card used as the visual container for every settings group.
/// Overrides the app's default Card style (elevation + horizontal margin) so
/// the settings page can control its own spacing and look uniformly flat.
class SettingsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const SettingsCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : AppColors.divider;

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        padding: padding,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: child,
        ),
      ),
    );
  }
}

/// Hair-line divider designed to slot between ListTiles in a SettingsCard.
/// Indents past the leading icon so the divider lines up with the title text.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : AppColors.divider,
    );
  }
}
