import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Enter your text'),
              ),
              const SizedBox(height: 16.0),
              Text('Translation'),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      // Bottom navigation bar example
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return BottomNavigationBar(
            backgroundColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.backgroundColor,
            selectedItemColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedItemColor,
            unselectedItemColor: Theme.of(
              context,
            ).bottomNavigationBarTheme.unselectedItemColor,
            selectedLabelStyle: Theme.of(
              context,
            ).bottomNavigationBarTheme.selectedLabelStyle,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: l10n.translation,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: l10n.settings,
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  AppNavigator.pushNamed(context, AppRoutes.home);
                  break;
                case 1:
                  AppNavigator.pushNamed(context, AppRoutes.settings);
                  break;
                case 2:
                  AppNavigator.pushNamed(context, AppRoutes.profile);
                  break;
                case 3:
                  AppNavigator.pushNamed(context, AppRoutes.about);
                  break;
              }
            },
          );
        },
      ),
    );
  }
}
