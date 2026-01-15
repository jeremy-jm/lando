import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_page.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Navigate when TextField gains focus (user taps on it)
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Small delay to allow user to see the focus effect
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _focusNode.hasFocus) {
            _navigateToQueryPage(
              _controller.text.trim().isEmpty ? null : _controller.text.trim(),
            );
            _focusNode.unfocus();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToQueryPage(String? query) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            QueryPage(initialQuery: query),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade and slide animation
          const begin = Offset(0.0, 0.1);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var slideAnimation = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve)).animate(animation);

          var fadeAnimation = Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve)).animate(animation);

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: l10n.translation,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      // Navigate to query page when submitted
                      _navigateToQueryPage(
                        value.trim().isEmpty ? null : value.trim(),
                      );
                    },
                  );
                },
              ),
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
