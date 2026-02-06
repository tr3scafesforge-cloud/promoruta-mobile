import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/core.dart' as model;
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({
    super.key,
    this.onDeleteAccount,
    this.onSignOut,
  });

  /// Optional callbacks you can hook to your auth logic.
  final Future<void> Function()? onDeleteAccount;
  final Future<void> Function()? onSignOut;

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when the page loads
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userAsync = ref.read(authStateProvider);
    userAsync.whenData((user) async {
      if (user != null) {
        try {
          final userRepository = ref.read(userRepositoryProvider);
          await userRepository.getUserById(user.id, forceRefresh: true);
        } catch (e) {
          // Handle error silently or show a snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to refresh user data: $e')),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(authStateProvider);
    final destructive = const Color(0xFFCC0033); // deep red like your mock
    final cardRadius = 12.0;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        leading: currentUserAsync.maybeWhen(
          data: (user) => IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback navigation based on user role
                if (user?.role == model.UserRole.advertiser) {
                  context.go('/advertiser-home?tab=profile');
                } else if (user?.role == model.UserRole.promoter) {
                  context.go('/promoter-home');
                } else {
                  context.go('/');
                }
              }
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          orElse: () => IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
        ),
      ),
      body: SafeArea(
        child: currentUserAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (user) => user == null
              ? Center(child: Text(l10n.noUserLoggedIn))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    // Avatar
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .18),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.white,
                          backgroundImage:
                              user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? NetworkImage(user.photoUrl!)
                                  : null,
                          child:
                              (user.photoUrl == null || user.photoUrl!.isEmpty)
                                  ? Icon(Icons.person,
                                      size: 64, color: Colors.grey[400])
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Use the real values from API:
                    _ProfileInfoCard(
                      radius: cardRadius,
                      rows: [
                        _InfoRowData(
                            label: l10n.uid,
                            value: user.id,
                            valueAlignEnd: true),
                        _InfoRowData(
                            label: l10n.username,
                            value: user.name), // Use name from API
                        _InfoRowData(label: l10n.email, value: user.email),
                        if (user.createdAt != null)
                          _InfoRowData(
                              label: l10n.registrationDate,
                              value: user.createdAt!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                        if (user.updatedAt != null)
                          _InfoRowData(
                              label: 'Last Updated',
                              value: user.updatedAt!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                        if (user.emailVerifiedAt != null)
                          _InfoRowData(
                              label: 'Email Verified',
                              value: user.emailVerifiedAt!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Eliminar cuenta (destructive)
                    CustomButton(
                      text: l10n.deleteAccount,
                      backgroundColor: destructive,
                      onPressed: () async {
                        final confirmed = await _confirm(
                          context,
                          title: l10n.deleteAccount,
                          message: l10n.deleteAccountConfirmation,
                          confirmText: l10n.delete,
                          confirmColor: destructive,
                        );
                        if (confirmed && widget.onDeleteAccount != null) {
                          await widget.onDeleteAccount!();
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    // Salir (sign out)
                    CustomButton.outlined(
                      text: l10n.signOut,
                      backgroundColor: Colors.white,
                      outlineColor: AppColors.grayDarkStroke,
                      textColor: AppColors.textPrimary,
                      onPressed: () async {
                        final confirmed = await _confirm(
                          context,
                          title: l10n.signOut,
                          message: l10n.signOutConfirmation,
                          confirmText: l10n.signOut,
                        );
                        if (confirmed) {
                          await ref.read(authStateProvider.notifier).logout();
                          if (context.mounted) {
                            const LoginRoute().go(context);
                          }
                        }
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  static Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    Color? confirmColor,
  }) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: theme.textTheme.titleMedium),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: confirmColor,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Small helper to render the info card with dividers cleanly.
class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.rows,
    this.radius = 12,
  });

  final List<_InfoRowData> rows;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xFFE7E8EA)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(
              label: rows[i].label,
              value: rows[i].value,
              valueAlignEnd: rows[i].valueAlignEnd,
            ),
            if (i != rows.length - 1) const _RowDivider(),
          ],
        ],
      ),
    );
  }
}

class _InfoRowData {
  const _InfoRowData({
    required this.label,
    required this.value,
    this.valueAlignEnd = false,
  });
  final String label;
  final String value;
  final bool valueAlignEnd;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.valueAlignEnd = false,
  });

  final String label;
  final String? value;
  final bool valueAlignEnd;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
        );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value ?? '',
              textAlign: valueAlignEnd ? TextAlign.end : TextAlign.start,
              style: valueStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F2F4),
    );
  }
}
