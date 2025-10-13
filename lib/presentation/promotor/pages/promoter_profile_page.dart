import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/widgets/profile_widgets.dart';

class PromoterProfilePage extends StatefulWidget {
  const PromoterProfilePage({
    super.key,
    this.name = 'Promoter Name',
    this.email = 'promoter@example.com',
    this.avatarImage,
    this.isDarkMode = false,
    this.onToggleDarkMode,
    this.onTapSecurity,
    this.onTapLanguage,
    this.onTapAccount,
  });

  final String name;
  final String email;
  final ImageProvider? avatarImage;

  /// Initial dark mode state (you can pass Theme.of(context).brightness == Brightness.dark)
  final bool isDarkMode;

  /// Called when the user flips the dark mode switch.
  final ValueChanged<bool>? onToggleDarkMode;

  final VoidCallback? onTapSecurity;
  final VoidCallback? onTapLanguage;
  final VoidCallback? onTapAccount;

  @override
  State<PromoterProfilePage> createState() => _PromoterProfilePageState();
}

class _PromoterProfilePageState extends State<PromoterProfilePage> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Account card
            ProfileCard(
              onTap: widget.onTapAccount,
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: widget.avatarImage,
                child: widget.avatarImage == null
                    ? const Icon(Icons.person, size: 28)
                    : null,
              ),
              title: widget.name,
              subtitle: widget.email,
            ),
            const SizedBox(height: 16),

            // Dark mode switch
            SwitchTileCard(
              label: l10n.darkMode,
              value: _darkMode,
              onChanged: (v) {
                setState(() => _darkMode = v);
                widget.onToggleDarkMode?.call(v);
              },
            ),
            const SizedBox(height: 12),

            // Security
            ArrowTileCard(
              icon: Icons.shield_outlined,
              label: l10n.security,
              onTap: widget.onTapSecurity,
            ),
            const SizedBox(height: 12),

            // Language
            ArrowTileCard(
              icon: Icons.language,
              label: l10n.language,
              onTap: widget.onTapLanguage,
            ),
          ],
        ));
  }
}
