import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
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
          // Profile header: avatar + display name
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDesign.spaceL,
              AppDesign.spaceXl,
              AppDesign.spaceL,
              AppDesign.spaceXl,
            ),
            child: Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      AppIcons.person,
                      size: 48,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: AppDesign.spaceMd),
                  Text(
                    l10n.user,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            height: AppDesign.dividerHeight,
            color: theme.colorScheme.onSurface
                .withValues(alpha: AppDesign.alphaDivider),
          ),
          // 收藏
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(
              AppIcons.favorite,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.favorites),
            trailing: const Icon(AppIcons.chevronRight),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_me_favorites',
              () => AppNavigator.pushNamed(context, AppRoutes.favorites),
            ),
          ),
          Divider(
            height: AppDesign.dividerHeight,
            color: theme.colorScheme.onSurface
                .withValues(alpha: AppDesign.alphaDivider),
          ),
          // 查词记录
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(
              AppIcons.history,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.history),
            trailing: const Icon(AppIcons.chevronRight),
            onTap: AnalyticsService.instance.wrapTap(
              'tap_me_history',
              () => AppNavigator.pushNamed(context, AppRoutes.history),
            ),
          ),
          Divider(
            height: AppDesign.dividerHeight,
            color: theme.colorScheme.onSurface
                .withValues(alpha: AppDesign.alphaDivider),
          ),
          // 设置
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(
              AppIcons.settings,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.settings),
            trailing: const Icon(AppIcons.chevronRight),
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
