import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lando/l10n/app_localizations/app_localizations.dart';
import 'package:lando/services/analytics/analytics_service.dart';
import 'package:lando/services/mdict/mdict_manager.dart';
import 'package:lando/storage/preferences_storage.dart';
import 'package:lando/theme/app_design.dart';
import 'package:lando/theme/app_icons.dart';

/// MDict offline dictionary settings page.
///
/// Allows users to:
/// - Enable/disable offline dictionary
/// - View current dictionary status
/// - Import custom .mdx dictionary files
/// - Reset to default dictionary
class MdictSettingsPage extends StatefulWidget {
  const MdictSettingsPage({super.key});

  @override
  State<MdictSettingsPage> createState() => _MdictSettingsPageState();
}

class _MdictSettingsPageState extends State<MdictSettingsPage> {
  bool _mdictEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _mdictEnabled = PreferencesStorage.isMdictEnabled();
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: AppDesign.paddingSectionTitle,
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required ThemeData theme,
    required Widget child,
  }) {
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(AppDesign.radiusL),
      child: child,
    );
  }

  Widget _buildStatusCard(ThemeData theme, AppLocalizations l10n) {
    final manager = MdictManager.instance;
    final isSupported = manager.isSupported;
    final isReady = manager.isInitialized;
    final hasDict = manager.hasDictionary;

    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (!isSupported) {
      statusText = l10n.mdictWebNotSupported;
      statusIcon = AppIcons.errorOutline;
      statusColor = theme.colorScheme.error;
    } else if (_isLoading) {
      statusText = l10n.mdictLoading;
      statusIcon = Icons.hourglass_empty;
      statusColor = theme.colorScheme.tertiary;
    } else if (hasDict) {
      statusText = l10n.mdictReady;
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else if (isReady && !hasDict) {
      statusText = l10n.mdictNotLoaded;
      statusIcon = Icons.info_outline;
      statusColor = theme.colorScheme.tertiary;
    } else {
      statusText = l10n.mdictNotInitialized;
      statusIcon = Icons.hourglass_empty;
      statusColor = theme.colorScheme.tertiary;
    }

    return _buildSectionCard(
      theme: theme,
      child: Padding(
        padding: AppDesign.paddingListTile,
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 40),
            const SizedBox(width: AppDesign.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.mdictStatus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnableSwitch(ThemeData theme, AppLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      child: SwitchListTile(
        contentPadding: AppDesign.paddingListTile,
        title: Text(l10n.mdictEnable),
        subtitle: Text(l10n.mdictEnableDescription),
        value: _mdictEnabled,
        onChanged: (value) async {
          await PreferencesStorage.saveMdictEnabled(value);
          setState(() {
            _mdictEnabled = value;
          });
          AnalyticsService.instance.event(
            value ? 'mdict_enabled' : 'mdict_disabled',
          );
        },
      ),
    );
  }

  Widget _buildActions(ThemeData theme, AppLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(Icons.file_upload, color: theme.colorScheme.primary),
            title: Text(l10n.mdictImport),
            subtitle: Text(l10n.mdictImportDescription),
            trailing: const Icon(AppIcons.chevronRight),
            onTap: _importDictionary,
          ),
          Divider(
            height: AppDesign.dividerHeight,
            color: theme.colorScheme.onSurface
                .withValues(alpha: AppDesign.alphaDivider),
          ),
          ListTile(
            contentPadding: AppDesign.paddingListTile,
            leading: Icon(Icons.restore, color: theme.colorScheme.primary),
            title: Text(l10n.mdictReset),
            subtitle: Text(l10n.mdictResetDescription),
            trailing: const Icon(AppIcons.chevronRight),
            onTap: _resetToDefault,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, AppLocalizations l10n) {
    return _buildSectionCard(
      theme: theme,
      child: Padding(
        padding: AppDesign.paddingListTile,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.mdictInfoTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.spaceS),
            Text(
              l10n.mdictInfoDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importDictionary() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Check platform support
    if (!MdictManager.instance.isSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mdictWebNotSupported)),
        );
      }
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mdx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final path = result.files.first.path;
        if (path != null) {
          setState(() => _isLoading = true);

          await MdictManager.instance.loadFromPath(path, isPrimary: true);
          await PreferencesStorage.saveMdictCustomPath(path);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.mdictImportSuccess)),
            );
          }

          AnalyticsService.instance.event('mdict_custom_imported');
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mdictImportFailed),
            backgroundColor: theme.colorScheme.errorContainer,
          ),
        );
      }
    }
  }

  Future<void> _resetToDefault() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    setState(() => _isLoading = true);

    try {
      // Reload default dictionary from assets
      await MdictManager.instance.initDefault();
      await PreferencesStorage.saveMdictCustomPath(null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.mdictResetSuccess)),
        );
      }

      AnalyticsService.instance.event('mdict_reset_to_default');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.mdictResetFailed),
            backgroundColor: theme.colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mdictSettings),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: AppDesign.iconXs),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: AppDesign.paddingPage,
        children: [
          _buildStatusCard(theme, l10n),
          const SizedBox(height: AppDesign.spaceL),
          _buildSectionTitle(theme, l10n.mdictSettings),
          const SizedBox(height: AppDesign.spaceS),
          _buildEnableSwitch(theme, l10n),
          const SizedBox(height: AppDesign.spaceS),
          _buildActions(theme, l10n),
          const SizedBox(height: AppDesign.spaceL),
          _buildInfoSection(theme, l10n),
        ],
      ),
    );
  }
}
