import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/version_info.dart';
import '../../gen/l10n/app_localizations.dart';

class UpdateDialog extends StatelessWidget {
  final VersionInfo versionInfo;
  final VoidCallback? onLater;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
    this.onLater,
  });

  Future<void> _launchDownload(BuildContext context) async {
    final uri = Uri.parse(versionInfo.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n.updateAvailable),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.updateVersionAvailable(versionInfo.version),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (versionInfo.releaseNotes != null &&
                versionInfo.releaseNotes!.isNotEmpty) ...[
              Text(
                l10n.updateReleaseNotes,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  versionInfo.releaseNotes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onLater?.call();
          },
          child: Text(l10n.updateLater),
        ),
        FilledButton.icon(
          onPressed: () => _launchDownload(context),
          icon: const Icon(Icons.download),
          label: Text(l10n.updateDownload),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context,
    VersionInfo versionInfo, {
    VoidCallback? onLater,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateDialog(
        versionInfo: versionInfo,
        onLater: onLater,
      ),
    );
  }
}
