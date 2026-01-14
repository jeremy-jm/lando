import 'package:flutter/material.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.notFound)),
      body: Center(child: Text(l10n.pageNotFound)),
    );
  }
}
