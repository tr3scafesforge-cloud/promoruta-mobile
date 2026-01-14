import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:toastification/toastification.dart';
import 'package:promoruta/features/auth/domain/use_cases/two_factor_use_cases.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class PromoterTwoFactorAuthPage extends ConsumerStatefulWidget {
  const PromoterTwoFactorAuthPage({super.key});

  @override
  ConsumerState<PromoterTwoFactorAuthPage> createState() => _PromoterTwoFactorAuthPageState();
}

class _PromoterTwoFactorAuthPageState extends ConsumerState<PromoterTwoFactorAuthPage> {
  bool _isLoading = false;

  Future<void> _handleToggle2FA(bool enable) async {
    if (enable) {
      // Navigate to setup page to enable 2FA
      context.push('/promoter-2fa-setup');
    } else {
      // Show confirmation dialog and disable 2FA
      _showDisable2FADialog();
    }
  }

  Future<void> _showDisable2FADialog() async {
    final passwordController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.disable2FA),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.enterPasswordToDisable2FA),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.disable),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text.isNotEmpty) {
      await _disable2FA(passwordController.text);
    }
  }

  Future<void> _disable2FA(String password) async {
    setState(() => _isLoading = true);

    try {
      final disable2FAUseCase = ref.read(disable2FAUseCaseProvider);
      final message = await disable2FAUseCase(Disable2FAParams(password: password));

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        // Refresh user data
        ref.invalidate(authStateProvider);

        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: Text(l10n.twoFactorAuthDisabled),
          description: Text(message),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(l10n.error),
          description: Text(l10n.errorDisabling2FA(e.toString())),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(authStateProvider);

    return userAsync.when(
      data: (user) => _buildContent(context, user?.twoFactorEnabled ?? false),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      body: Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isEnabled) {
    const bg = Color(0xFFF3F5F7);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/promoter-security-settings'),
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
                  icon: Icons.lock_outline,
                  title: l10n.twoFactorAuthentication,
                  subtitle: isEnabled ? l10n.enabled : l10n.disabled,
                  trailing: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: isEnabled,
                          onChanged: _handleToggle2FA,
                          activeThumbColor: const Color(0xFF11A192),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isEnabled) ...[
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.smartphone,
                    title: l10n.authenticatorApp,
                    subtitle: l10n.googleAuthenticator,
                    onTap: () {
                      // Show info or reconfigure
                      _showAuthenticatorInfo();
                    },
                  ),
                  const _RowDivider(),
                  _SettingsTile(
                    icon: Icons.sms,
                    title: l10n.sms,
                    subtitle: l10n.notAvailable,
                    enabled: false,
                    onTap: null,
                  ),
                  const _RowDivider(),
                  _SettingsTile(
                    icon: Icons.email,
                    title: l10n.email,
                    subtitle: l10n.notAvailable,
                    enabled: false,
                    onTap: null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.backup,
                    title: l10n.recoveryCodes,
                    subtitle: l10n.viewOrRegenerateRecoveryCodes,
                    onTap: () {
                      context.push('/promoter-recovery-codes');
                    },
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE7E8EA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.whyEnable2FA,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.twoFactorAuthDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/promoter-2fa-setup'),
                        icon: const Icon(Icons.shield),
                        label: Text(l10n.enable2FA),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF11A192),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAuthenticatorInfo() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authenticatorApp),
        content: Text(l10n.authenticatorConfiguredMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

/// Rounded container that looks like the card in your screenshot.
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

/// Single row with left icon, bold title, and trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: enabled ? Colors.black87 : Colors.black38,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: enabled ? Colors.black54 : Colors.black26,
        );

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: enabled ? Colors.black87 : Colors.black38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: subtitleStyle),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null && enabled)
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
