import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lando/features/home/home_page.dart';
import 'package:lando/features/me/me_page.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/analytics/analytics_service.dart';

/// Root page with bottom navigation (Translation tab + Me tab).
/// Uses IndexedStack to keep tab state when switching.
class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTabWrapper(),
    const _MeTabWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final translationLabel = l10n?.translation ?? 'Translation';
    final meLabel = l10n?.me ?? 'Me';

    final barContent = SafeArea(
      top: false,
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(
          alpha: 0.6,
        ),
        selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle:
            theme.bottomNavigationBarTheme.unselectedLabelStyle,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: translationLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: meLabel,
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
    );

    final bottomBar = Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.98),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Platform.isIOS
          ? barContent
          : ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                  ),
                  child: barContent,
                ),
              ),
            ),
    );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class _HomeTabWrapper extends StatelessWidget {
  const _HomeTabWrapper();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return HomePage(
      title: l10n?.appTitle ?? 'Lando Dictionary',
      showAppBar: false,
    );
  }
}

class _MeTabWrapper extends StatelessWidget {
  const _MeTabWrapper();

  @override
  Widget build(BuildContext context) {
    return const MePage(showAppBar: false);
  }
}
