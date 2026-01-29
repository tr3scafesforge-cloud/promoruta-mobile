import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/features/profile/presentation/pages/user_profile_page.dart';
import 'package:promoruta/features/profile/presentation/widgets/profile_widgets.dart';

class PromoterProfilePage extends StatefulWidget {
  const PromoterProfilePage({
    super.key,
    this.name = 'Promoter Name',
    this.email = 'promoter@example.com',
    this.avatarImage,
    this.onTapSecurity,
    this.onTapAccount,
  });

  final String name;
  final String email;
  final ImageProvider? avatarImage;

  final VoidCallback? onTapSecurity;
  final VoidCallback? onTapAccount;

  @override
  State<PromoterProfilePage> createState() => _PromoterProfilePageState();
}

class _PromoterProfilePageState extends State<PromoterProfilePage> {
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
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

            // Security
            ArrowTileCard(
              icon: Icons.shield_outlined,
              label: l10n.security,
              onTap: widget.onTapSecurity,
            ),
          ],
        ));
  }
}
