import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_page.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/features/home/widgets/translation_input_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';

/// Translation tab: input box and query result.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    this.showAppBar = true,
  });

  final String title;
  final bool showAppBar;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _languageSelectorKey = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Detect language from input
    _controller.addListener(_detectLanguage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Force rebuild language selector when returning from another page
    // This ensures language changes are reflected
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          setState(() {
            _languageSelectorKey++;
          });
        }
      });
    }
  }

  void _detectLanguage() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    // Simple language detection (can be improved with ML or API)
    // Currently not used but kept for future use
    _simpleLanguageDetection(text); // ignore: unused_result
    setState(() {});
  }

  String? _simpleLanguageDetection(String text) {
    // Simple heuristic: check for Chinese, Japanese, etc.
    // Returns language code (e.g., 'zh', 'ja', 'hi', 'en') for consistency
    // The display name should be converted using AppLocalizations when displayed
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return 'zh';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return 'ja';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return 'hi';
    // Default to English for Latin scripts
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return 'en';
    return 'en'; // Default fallback
  }

  @override
  void dispose() {
    _isDisposed = true;
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
        settings: RouteSettings(
          name: AppRoutes.query,
          arguments: query == null ? null : <String, dynamic>{'query': query},
        ),
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
      appBar: widget.showAppBar
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
            )
          : null,
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

              // Translation input widget that navigates to query page when user presses enter
              TranslationInputWidget(
                controller: _controller,
                focusNode: _focusNode,
                hintText: AppLocalizations.of(context)?.enterTextToTranslate,
                onSubmitted: (value) {
                  AnalyticsService.instance.event('tap_home_enter_translate');
                  if (value.trim().isNotEmpty) {
                    _navigateToQueryPage(value.trim());
                  } else {
                    _navigateToQueryPage(null);
                  }
                },
                onTap: AnalyticsService.instance.wrapTap(
                  'tap_home_enter_translate',
                  () {
                    // Focus is already handled by focusNode
                  },
                ),
                enableSuggestions: true,
              ),
              const SizedBox(height: 16.0),
              LanguageSelectorWidget(
                key: ValueKey(_languageSelectorKey),
                showBackground: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
