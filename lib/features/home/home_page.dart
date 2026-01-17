import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_page.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
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
  String? _detectedLanguage;
  int _languageSelectorKey = 0;

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

    // Detect language from input
    _controller.addListener(_detectLanguage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild language selector when returning from another page
    // This ensures language changes are reflected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _languageSelectorKey++;
        });
      }
    });
  }

  void _detectLanguage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _detectedLanguage = null;
      });
      return;
    }

    // Simple language detection (can be improved with ML or API)
    final detected = _simpleLanguageDetection(text);
    setState(() {
      _detectedLanguage = detected;
    });
  }

  String? _simpleLanguageDetection(String text) {
    // Simple heuristic: check for Chinese, Japanese, etc.
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return '中文';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return '日语';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return '印地语';
    // Default to English for Latin scripts
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return '英语';
    return '英语'; // Default fallback
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToQueryPage(String? query) {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                QueryPage(initialQuery: query),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
        )
        .then((_) {
          // When returning from query page, force language selector to reload
          if (mounted) {
            setState(() {
              _languageSelectorKey++;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40.0),
              //Lando logo
              Image.asset('assets/images/logo.png', width: 100, height: 100),

              const SizedBox(height: 40.0),

              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return TranslationInputWidget(
                    controller: _controller,
                    focusNode: _focusNode,
                    hintText: l10n.translation,
                    detectedLanguage: _detectedLanguage,
                    onSubmitted: (value) {
                      _navigateToQueryPage(
                        value.trim().isEmpty ? null : value.trim(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              LanguageSelectorWidget(
                key: ValueKey(_languageSelectorKey),
                showBackground: true,
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation bar with iOS liquid glass effect
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          return ClipRRect(
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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
