import 'dart:io';
import 'package:flutter/material.dart';
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
            content: Text(AppLocalizations.of(context)?.proxyValidationSuccess ?? 'Proxy connection successful'),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }

      AnalyticsService.instance.event('proxy_validation_success');
    } catch (e) {
      setState(() {
        _isValidating = false;
        _validationError = AppLocalizations.of(context)?.proxyValidationFailed ?? 'Failed to connect to proxy server';
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
        padding: const EdgeInsets.all(16.0),
        children: [
          // Proxy Enabled Switch
          Card(
            child: SwitchListTile(
              title: Text(l10n.enableProxy),
              subtitle: Text(l10n.enableProxyDescription),
              value: _proxyEnabled,
              onChanged: _onProxyEnabledChanged,
              secondary: Icon(
                Icons.settings_ethernet,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Proxy Host Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proxyHost,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _hostController,
                    enabled: _proxyEnabled,
                    decoration: InputDecoration(
                      hintText: l10n.proxyHostHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.dns),
                    ),
                    onChanged: _onHostChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Proxy Port Input
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.proxyPort,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _portController,
                    enabled: _proxyEnabled,
                    decoration: InputDecoration(
                      hintText: l10n.proxyPortHint,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: _onPortChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),

          // Validation Status
          if (_isValidating)
            Card(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                    const SizedBox(width: 16.0),
                    Text(l10n.validatingProxy),
                  ],
                ),
              ),
            )
          else if (_validationError != null)
            Card(
              color: theme.colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 16.0),
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
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16.0),
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

          const SizedBox(height: 24.0),

          // Validate Button
          if (_proxyEnabled)
            ElevatedButton.icon(
              onPressed: _isValidating ? null : _validateProxy,
              icon: const Icon(Icons.check_circle),
              label: Text(l10n.validateProxy),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),

          const SizedBox(height: 16.0),

          // Info Card
          Card(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        l10n.proxyInfo,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
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
