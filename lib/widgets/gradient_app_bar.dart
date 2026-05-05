import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    // Minimalist AppBar: No gradient, matches scaffold background
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.black.withValues(alpha:0.05), // Subtle separator
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
