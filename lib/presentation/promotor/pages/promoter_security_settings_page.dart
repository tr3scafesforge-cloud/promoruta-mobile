import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/app/routes/app_router.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class PromoterSecuritySettingsPage extends StatelessWidget {
  const PromoterSecuritySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF3F5F7);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SettingsCard(
              children: [
                _SettingsTile(
                  icon: Icons.credit_card,
                  title: l10n.paymentMethods,
                  onTap: () => const PaymentMethodsRoute().push(context),
                ),
                const _RowDivider(),
                _SettingsTile(
                  icon: Icons.password_outlined,
                  title: l10n.changePassword,
                  onTap: () => const ChangePasswordRoute().push(context),
                ),
                const _RowDivider(),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  title: l10n.twoFactorAuth,
                  onTap: () => const PromoterTwoFactorAuthRoute().push(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E8EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.black87),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: titleStyle)),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
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
