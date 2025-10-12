import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/shared/providers/providers.dart';

class UserProfilePage extends ConsumerWidget {
  const UserProfilePage({
    super.key,
    this.onDeleteAccount,
    this.onSignOut,
  });

  /// Optional callbacks you can hook to your auth logic.
  final Future<void> Function()? onDeleteAccount;
  final Future<void> Function()? onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);
    final destructive = const Color(0xFFCC0033); // deep red like your mock
    final cardRadius = 12.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (user) => user == null
              ? const Center(child: Text('No user logged in'))
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
                          backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                              ? NetworkImage(user.photoUrl!)
                              : null,
                          child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 64, color: Colors.grey[400])
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Use the real values:
                    // (Replace the placeholder card above with this exact widget.)
                    _ProfileInfoCard(
                      radius: cardRadius,
                      rows: [
                        _InfoRowData(label: 'UID', value: user.id, valueAlignEnd: true),
                        _InfoRowData(label: 'Usuario', value: user.username ?? user.email),
                        _InfoRowData(label: 'Email', value: user.email),
                        if (user.createdAt != null)
                          _InfoRowData(label: 'Fecha de registro', value: user.createdAt!.toLocal().toString().split(' ')[0]),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Eliminar cuenta (destructive)
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: destructive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await _confirm(
                            context,
                            title: 'Eliminar cuenta',
                            message:
                                'Esta acción es permanente. ¿Seguro que deseas continuar?',
                            confirmText: 'Eliminar',
                            confirmColor: destructive,
                          );
                          if (confirmed && onDeleteAccount != null) {
                            await onDeleteAccount!();
                          }
                        },
                        child: const Text('Eliminar cuenta'),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Salir (sign out)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE7E8EA)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final confirmed = await _confirm(
                            context,
                            title: 'Salir',
                            message: '¿Deseas cerrar sesión?',
                            confirmText: 'Salir',
                          );
                          if (confirmed && onSignOut != null) {
                            await onSignOut!();
                          }
                        },
                        child: const Text('Salir'),
                      ),
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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: theme.textTheme.titleMedium),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
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
