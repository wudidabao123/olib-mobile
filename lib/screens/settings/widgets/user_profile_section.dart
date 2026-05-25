import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

class UserProfileSection extends StatelessWidget {
  final User user;

  const UserProfileSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme
                  .of(context)
                  .textTheme
                  .titleLarge,
            ),
            Text(
              user.email,
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${user.downloadsLeft} ${AppLocalizations
                    .of(context)
                    .get('downloads_left_today')}',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
