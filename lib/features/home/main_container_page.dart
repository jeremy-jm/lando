import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lando/features/home/home_page.dart';
import 'package:lando/features/me/me_page.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/analytics/analytics_service.dart';

/// 主容器页面，包含 BottomNavigationBar 和两个 Tab 页面
/// 使用 IndexedStack 来保持页面状态，避免切换时重新构建
class MainContainerPage extends StatefulWidget {
  const MainContainerPage({super.key});

  @override
  State<MainContainerPage> createState() => _MainContainerPageState();
}

class _MainContainerPageState extends State<MainContainerPage> {
  int _currentIndex = 0;

  // 保持页面实例，避免重新构建
  final List<Widget> _pages = [
    const _HomeTabWrapper(),
    const _MeTabWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      // Bottom navigation bar with iOS liquid glass effect
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
                selectedLabelStyle:
                    theme.bottomNavigationBarTheme.selectedLabelStyle,
                unselectedLabelStyle:
                    theme.bottomNavigationBarTheme.unselectedLabelStyle,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: l10n.translation,
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.person),
                    label: l10n.me,
                  ),
                ],
                onTap: (index) {
                  AnalyticsService.instance.event(
                    'tap_bottom_nav',
                    properties: {'index': index},
                  );
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home Tab 包装器，用于移除 HomePage 的 AppBar（因为现在在容器中）
class _HomeTabWrapper extends StatelessWidget {
  const _HomeTabWrapper();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MyHomePage(
      title: l10n?.appTitle ?? 'Lando Dictionary',
      showAppBar: false, // 不显示 AppBar，因为现在在容器中
    );
  }
}

/// Me Tab 包装器，用于移除 MePage 的 AppBar（因为现在在容器中）
class _MeTabWrapper extends StatelessWidget {
  const _MeTabWrapper();

  @override
  Widget build(BuildContext context) {
    return const MePage(showAppBar: false);
  }
}
