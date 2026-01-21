import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/features/me/settings_page.dart';

/// "我的"页面，包含收藏、查词记录、设置三个选项
class MePage extends StatelessWidget {
  const MePage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(l10n.me),
              backgroundColor: theme.colorScheme.inversePrimary,
            )
          : null,
      body: ListView(
        children: [
          // 收藏
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.favorites),
            trailing: const Icon(Icons.chevron_right),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_me_favorites',
              () => AppNavigator.pushNamed(context, AppRoutes.favorites),
            ),
          ),
          const Divider(),
          // 查词记录
          ListTile(
            leading: Icon(
              Icons.history,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.history),
            trailing: const Icon(Icons.chevron_right),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_me_history',
              () => AppNavigator.pushNamed(context, AppRoutes.history),
            ),
          ),
          const Divider(),
          // 设置
          ListTile(
            leading: Icon(
              Icons.settings,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.settings),
            trailing: const Icon(Icons.chevron_right),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_me_settings',
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                    settings: const RouteSettings(
                      name: AppRoutes.settings,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}