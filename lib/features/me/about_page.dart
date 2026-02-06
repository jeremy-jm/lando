import 'package:flutter/material.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';
import 'package:flutter/services.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/analytics/analytics_service.dart';
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
    AnalyticsService.instance.event('tap_about_privacy_policy');
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
    AnalyticsService.instance.event('tap_about_terms_of_service');
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
    AnalyticsService.instance.event('tap_about_license');
    showLicensePage(
      context: context,
      applicationName: AppLocalizations.of(context)!.appTitle,
      applicationVersion: _packageInfo?.version ?? '1.0.0',
      applicationIcon: const Icon(AppIcons.book),
    );
  }

  void _copyVersionInfo() {
    AnalyticsService.instance.event('tap_about_copy_version');
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
              padding: AppDesign.paddingCard,
              children: [
                // App Icon and Name (use local logo)
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: AppDesign.aboutLogoSize,
                        height: AppDesign.aboutLogoSize,
                      ),
                      const SizedBox(height: AppDesign.spaceL),
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_packageInfo != null) ...[
                        const SizedBox(height: AppDesign.spaceS),
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
                const SizedBox(height: AppDesign.aboutSectionSpacing),
                // App Description
                Text(
                  l10n.appDescription,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDesign.aboutSectionSpacing),
                Divider(
                  height: AppDesign.dividerHeight,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDivider),
                ),
                // Version Info
                if (_packageInfo != null)
                  ListTile(
                    contentPadding: AppDesign.paddingListTile,
                    leading: Icon(AppIcons.infoOutline,
                        color: theme.colorScheme.primary),
                    title: Text(l10n.versionInfo),
                    subtitle: Text(
                      '${l10n.version}: ${_packageInfo!.version}\n'
                      '${l10n.buildNumber}: ${_packageInfo!.buildNumber}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(AppIcons.copy),
                      onPressed: _copyVersionInfo,
                      tooltip: l10n.copy,
                    ),
                  ),
                Divider(
                  height: AppDesign.dividerHeight,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDivider),
                ),
                // Privacy Policy (ui_spec: leading primary)
                ListTile(
                  contentPadding: AppDesign.paddingListTile,
                  leading: Icon(AppIcons.privacyTip,
                      color: theme.colorScheme.primary),
                  title: Text(l10n.privacyPolicy),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: _showPrivacyPolicy,
                ),
                Divider(
                  height: AppDesign.dividerHeight,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDivider),
                ),
                // Terms of Service
                ListTile(
                  contentPadding: AppDesign.paddingListTile,
                  leading: Icon(AppIcons.description,
                      color: theme.colorScheme.primary),
                  title: Text(l10n.termsOfService),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: _showTermsOfService,
                ),
                Divider(
                  height: AppDesign.dividerHeight,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDivider),
                ),
                // Open Source Licenses
                ListTile(
                  contentPadding: AppDesign.paddingListTile,
                  leading:
                      Icon(AppIcons.code, color: theme.colorScheme.primary),
                  title: Text(l10n.openSourceLicenses),
                  trailing: const Icon(AppIcons.chevronRight),
                  onTap: _showLicense,
                ),
                Divider(
                  height: AppDesign.dividerHeight,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: AppDesign.alphaDivider),
                ),
                // Copyright
                Padding(
                  padding:
                      const EdgeInsets.all(AppDesign.aboutCopyrightPadding),
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
