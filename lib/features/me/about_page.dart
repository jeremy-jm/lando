import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// About page showing app information, version, and legal links.
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _packageInfo = packageInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showPrivacyPolicy() {
    // TODO: Implement privacy policy page or open URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        content: Text(AppLocalizations.of(context)!.privacyPolicyContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    // TODO: Implement terms of service page or open URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.termsOfService),
        content: Text(AppLocalizations.of(context)!.termsOfServiceContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showLicense() {
    showLicensePage(
      context: context,
      applicationName: AppLocalizations.of(context)!.appTitle,
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: const Icon(Icons.book),
    );
  }

  void _copyVersionInfo() {
    if (_packageInfo != null) {
      final versionInfo = '${AppLocalizations.of(context)!.appTitle}\n'
          '${AppLocalizations.of(context)!.version}: ${_packageInfo!.version}\n'
          '${AppLocalizations.of(context)!.buildNumber}: ${_packageInfo!.buildNumber}';
      Clipboard.setData(ClipboardData(text: versionInfo));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.versionInfoCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.about),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // App Icon and Name
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.book,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_packageInfo != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n.version} ${_packageInfo!.version}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // App Description
                Text(
                  l10n.appDescription,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Divider(),
                // Version Info
                if (_packageInfo != null)
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.versionInfo),
                    subtitle: Text(
                      '${l10n.version}: ${_packageInfo!.version}\n'
                      '${l10n.buildNumber}: ${_packageInfo!.buildNumber}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyVersionInfo,
                      tooltip: l10n.copy,
                    ),
                  ),
                const Divider(),
                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacyPolicy,
                ),
                const Divider(),
                // Terms of Service
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showTermsOfService,
                ),
                const Divider(),
                // Open Source Licenses
                ListTile(
                  leading: const Icon(Icons.code_outlined),
                  title: Text(l10n.openSourceLicenses),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showLicense,
                ),
                const Divider(),
                // Copyright
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.copyright,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }
}
