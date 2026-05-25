import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/update_service.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../widgets/domain_selector.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/locale_utils.dart' as locale_utils;
import 'widgets/user_profile_section.dart';
import 'widgets/download_path_section.dart';
import 'widgets/about_section.dart';
import 'widgets/language_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: GradientAppBar(
          title: AppLocalizations.of(context).get('settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
            // User Profile Section
            if (user != null)
              UserProfileSection(user: user),

            const SizedBox(height: 24),

            // Library Section
            Text(
              AppLocalizations.of(context).get('library'),
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(
                        AppLocalizations.of(context).get('download_history')),
                    subtitle: Text(AppLocalizations.of(context).get(
                        'books_downloaded_any_device')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.history);
                    },
                  ),
                ],
              ),
            ),

            // Download Directory Section
            const DownloadPathSection(),

            const SizedBox(height: 24),

            // Network Section
            Text(
              AppLocalizations.of(context).get('network'),
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.dns_rounded),
                    const SizedBox(width: 16),
                    Expanded(child: Text(
                        AppLocalizations.of(context).get('network_line'))),
                    const DomainSelector(compact: false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Update Section
            Text(
              locale_utils.isZhLocale(context) ? '更新' : 'Update',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),

            Card(
              child: ListTile(
                leading: const Icon(Icons.system_update),
                title: Text(locale_utils.isZhLocale(context)
                    ? '检查更新'
                    : 'Check for Updates'),
                subtitle: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '...';
                    return Text(
                      locale_utils.isZhLocale(context)
                          ? '当前版本: v$version'
                          : 'Current version: v$version',
                    );
                  },
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => UpdateService.showManualCheckDialog(context),
              ),
            ),

            const SizedBox(height: 24),

            // Theme Section
            Text(
              AppLocalizations.of(context).get('appearance'),
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
            ),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context).get('system')),
                    value: AppThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value);
                      }
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context).get('light')),
                    value: AppThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value);
                      }
                    },
                  ),
                  RadioListTile<AppThemeMode>(
                    title: Text(AppLocalizations.of(context).get('dark')),
                    value: AppThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).setThemeMode(
                            value);
                      }
                    },
                  ),
                ],
              ),
            ),


            const SizedBox(height: 24),

            // Language Section
            const LanguageSection(),

            const SizedBox(height: 24),

            // About Section
            const AboutSection(),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(AppLocalizations.of(context).get('logout')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    inherit: false,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}