import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lando/features/home/query/query_page.dart';
import 'package:lando/features/home/widgets/language_selector_widget.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/routes/app_routes.dart';
import 'package:lando/services/analytics/analytics_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    this.showAppBar = true,
  });

  final String title;
  final bool showAppBar;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _languageSelectorKey = 0;
  Timer? _focusDelayTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    // Listen to text changes and navigate to query page when user types
    _controller.addListener(_onTextChanged);

    // Navigate when TextField gains focus (user taps on it)
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_isDisposed) {
        // Cancel any pending navigation
        _focusDelayTimer?.cancel();
        // Use post frame callback to ensure keyboard events are processed first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted && _focusNode.hasFocus) {
            // Small delay to allow keyboard events to complete
            _focusDelayTimer = Timer(const Duration(milliseconds: 150), () {
              if (!_isDisposed && mounted && _focusNode.hasFocus) {
                // If there's no text, navigate to empty query page
                if (_controller.text.trim().isEmpty) {
                  _focusNode.unfocus();
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (!_isDisposed && mounted) {
                      _navigateToQueryPage(null);
                    }
                  });
                }
              }
            });
          }
        });
      }
    });

    // Detect language from input (also called in _onTextChanged, but kept for compatibility)
    _controller.addListener(_detectLanguage);
  }

  void _onTextChanged() {
    if (_isDisposed || !mounted) return;

    final text = _controller.text.trim();

    // If user has typed something, navigate to query page with the text
    if (text.isNotEmpty) {
      // Cancel any pending navigation
      _focusDelayTimer?.cancel();

      // Small delay to allow user to continue typing
      // After user stops typing for 300ms, navigate to query page
      _focusDelayTimer = Timer(const Duration(milliseconds: 300), () {
        if (!_isDisposed && mounted) {
          final currentText = _controller.text.trim();
          if (currentText.isNotEmpty) {
            // Unfocus to avoid keyboard state issues
            _focusNode.unfocus();
            // Navigate after a brief delay
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!_isDisposed && mounted) {
                _navigateToQueryPage(currentText);
              }
            });
          }
        }
      });
    }
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
    if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) return '中文';
    if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) return '日语';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(text)) return '印地语';
    // Default to English for Latin scripts
    if (RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) return '英语';
    return '英语'; // Default fallback
  }

  @override
  void dispose() {
    _isDisposed = true;
    _focusDelayTimer?.cancel();
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

              // Input field that navigates to query page when user types
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(
                          alpha: 0.1,
                        ),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText:
                        AppLocalizations.of(context)?.enterTextToTranslate ??
                            'Enter text to translate',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onTap: AnalyticsService.instance.wrapTap(
                    'tap_home_enter_translate',
                    () {
                      // Focus is already handled by focusNode listener
                    },
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _navigateToQueryPage(value.trim());
                    } else {
                      _navigateToQueryPage(null);
                    }
                  },
                ),
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
