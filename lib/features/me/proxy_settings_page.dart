import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/storage/preferences_storage.dart';

/// Proxy settings page for configuring HTTP proxy.
class ProxySettingsPage extends StatefulWidget {
  const ProxySettingsPage({super.key});

  @override
  State<ProxySettingsPage> createState() => _ProxySettingsPageState();
}

class _ProxySettingsPageState extends State<ProxySettingsPage> {
  bool _proxyEnabled = false;
  String _proxyHost = 'localhost';
  int _proxyPort = 9091;
  bool _isValidating = false;
  String? _validationError;

  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProxySettings();
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _loadProxySettings() {
    setState(() {
      _proxyEnabled = PreferencesStorage.getProxyEnabled();
      _proxyHost = PreferencesStorage.getProxyHost();
      _proxyPort = PreferencesStorage.getProxyPort();
      _hostController.text = _proxyHost;
      _portController.text = _proxyPort.toString();
    });
  }

  Future<void> _onProxyEnabledChanged(bool value) async {
    setState(() {
      _proxyEnabled = value;
      _validationError = null;
    });

    await PreferencesStorage.saveProxyEnabled(value);

    if (value) {
      // Validate proxy when enabling
      await _validateProxy();
    }

    AnalyticsService.instance.event(
      'tap_proxy_settings_enabled',
      properties: {'enabled': value.toString()},
    );
  }

  Future<void> _onHostChanged(String value) async {
    setState(() {
      _proxyHost = value.trim();
      _validationError = null;
    });

    await PreferencesStorage.saveProxyHost(_proxyHost);

    if (_proxyEnabled) {
      // Validate proxy when host changes and proxy is enabled
      await _validateProxy();
    }
  }

  Future<void> _onPortChanged(String value) async {
    final port = int.tryParse(value.trim());
    if (port != null && port > 0 && port <= 65535) {
      setState(() {
        _proxyPort = port;
        _validationError = null;
      });

      await PreferencesStorage.saveProxyPort(_proxyPort);

      if (_proxyEnabled && value.trim().isNotEmpty) {
        // Validate proxy when port changes and proxy is enabled
        await _validateProxy();
      }
    } else if (value.trim().isEmpty) {
      // Clear validation error when port is empty
      setState(() {
        _validationError = null;
      });
    }
  }

  Future<void> _validateProxy() async {
    if (!_proxyEnabled) {
      return;
    }

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      // Try to connect to the proxy server
      final socket = await Socket.connect(
        _proxyHost,
        _proxyPort,
        timeout: const Duration(seconds: 3),
      );
      await socket.close();

      setState(() {
        _isValidating = false;
        _validationError = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context)?.proxyValidationSuccess ??
                    'Proxy connection successful'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }

      AnalyticsService.instance.event('proxy_validation_success');
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationError =
            AppLocalizations.of(context)?.proxyValidationFailed ??
                'Failed to connect to proxy server';
      });

      AnalyticsService.instance.event(
        'proxy_validation_failed',
        properties: {'error': e.toString()},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.proxySettings),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: AppDesign.paddingCard,
        children: [
          // Proxy Enabled Switch (ui_spec: card radius 12)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusL),
            ),
            child: SwitchListTile(
              title: Text(l10n.enableProxy),
              subtitle: Text(l10n.enableProxyDescription),
              value: _proxyEnabled,
              onChanged: _onProxyEnabledChanged,
              secondary: Icon(
                AppIcons.settingsEthernet,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: AppDesign.spaceL),

          // Proxy Host Input
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusL),
            ),
            child: Padding(
              padding: AppDesign.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proxyHost,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDesign.spaceS),
                  TextField(
                    controller: _hostController,
                    enabled: _proxyEnabled,
                    decoration: InputDecoration(
                      hintText: l10n.proxyHostHint,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDesign.radiusL),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(AppIcons.dns),
                    ),
                    onChanged: _onHostChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesign.spaceL),

          // Proxy Port Input
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusL),
            ),
            child: Padding(
              padding: AppDesign.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proxyPort,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDesign.spaceS),
                  TextField(
                    controller: _portController,
                    enabled: _proxyEnabled,
                    decoration: InputDecoration(
                      hintText: l10n.proxyPortHint,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDesign.radiusL),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(AppIcons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onPortChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesign.spaceL),

          // Validation Status
          if (_isValidating)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusL),
              ),
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: AppDesign.paddingCard,
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDesign.spaceL),
                    Text(l10n.validatingProxy),
                  ],
                ),
              ),
            )
          else if (_validationError != null)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusL),
              ),
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: AppDesign.paddingCard,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.errorOutline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: AppDesign.spaceL),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_proxyEnabled)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusL),
              ),
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: AppDesign.paddingCard,
                child: Row(
                  children: [
                    Icon(
                      AppIcons.checkCircleOutline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppDesign.spaceL),
                    Expanded(
                      child: Text(
                        l10n.proxyConfigured,
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppDesign.spaceXl),

          // Validate Button
          if (_proxyEnabled)
            ElevatedButton.icon(
              onPressed: _isValidating ? null : _validateProxy,
              icon: const Icon(AppIcons.checkCircle),
              label: Text(l10n.validateProxy),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppDesign.spaceL),
              ),
            ),

          const SizedBox(height: AppDesign.spaceL),

          // Info Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusL),
            ),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: AppDesign.paddingCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        AppIcons.infoOutline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppDesign.spaceS),
                      Text(
                        l10n.proxyInfo,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.spaceS),
                  Text(
                    l10n.proxyInfoDescription,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
