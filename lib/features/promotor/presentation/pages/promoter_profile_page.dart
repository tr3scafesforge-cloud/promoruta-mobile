import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:promoruta/shared/providers/providers.dart';

class PromoterProfilePage extends ConsumerStatefulWidget {
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
  ConsumerState<PromoterProfilePage> createState() =>
      _PromoterProfilePageState();
}

class _PromoterProfilePageState extends ConsumerState<PromoterProfilePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Watch the current user state
    final userAsync = ref.watch(authStateProvider);

    return Container(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Account card
            userAsync.when(
              data: (user) => ProfileCard(
                onTap: widget.onTapAccount,
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: widget.avatarImage,
                  child: widget.avatarImage == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                title: user?.name ?? widget.name,
                subtitle: user?.email ?? widget.email,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => ProfileCard(
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
