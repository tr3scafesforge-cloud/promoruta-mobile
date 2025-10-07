import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

class AdvertiserProfilePage extends StatefulWidget {
  const AdvertiserProfilePage({
    super.key,
    this.name = 'Melissa Domehr',
    this.email = 'melissa.domehr@mail.com',
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
  State<AdvertiserProfilePage> createState() => _AdvertiserProfilePageState();
}

class _AdvertiserProfilePageState extends State<AdvertiserProfilePage> {
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
          _ProfileCard(
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
          _SwitchTileCard(
            icon: Icons.nightlight_round,
            label: l10n.darkMode,
            value: _darkMode,
            onChanged: (v) {
              setState(() => _darkMode = v);
              widget.onToggleDarkMode?.call(v);
            },
          ),
          const SizedBox(height: 12),

          // Security
          _ArrowTileCard(
            icon: Icons.shield_outlined,
            label: l10n.security,
            onTap: widget.onTapSecurity,
          ),
          const SizedBox(height: 12),

          // Language
          _ArrowTileCard(
            icon: Icons.language,
            label: l10n.language,
            onTap: widget.onTapLanguage,
          ),
        ],
      )
    );
  }
}

/* ------------------------------ UI pieces ------------------------------ */

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwitchTileCard extends StatelessWidget {
  const _SwitchTileCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _ArrowTileCard extends StatelessWidget {
  const _ArrowTileCard({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
