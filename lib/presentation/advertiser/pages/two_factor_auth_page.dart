import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TwoFactorAuthPage extends StatefulWidget {
  const TwoFactorAuthPage({super.key});

  @override
  State<TwoFactorAuthPage> createState() => _TwoFactorAuthPageState();
}

class _TwoFactorAuthPageState extends State<TwoFactorAuthPage> {
  bool _isEnabled = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF3F5F7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.canPop() ? context.pop() : context.go('/advertiser-security-settings'),
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
                  title: 'Autenticación de dos factores',
                  subtitle: _isEnabled ? 'Activada' : 'Desactivada',
                  trailing: Switch(
                    value: _isEnabled,
                    onChanged: (value) => setState(() => _isEnabled = value),
                    activeThumbColor: const Color(0xFF11A192),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEnabled) ...[
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.smartphone,
                    title: 'Aplicación de autenticación',
                    subtitle: 'Google Authenticator',
                    onTap: () {
                      // TODO: Navigate to setup authenticator app
                    },
                  ),
                  const _RowDivider(),
                  _SettingsTile(
                    icon: Icons.sms,
                    title: 'SMS',
                    subtitle: '+598 ** *** ** 34',
                    onTap: () {
                      // TODO: Navigate to setup SMS
                    },
                  ),
                  const _RowDivider(),
                  _SettingsTile(
                    icon: Icons.email,
                    title: 'Email',
                    subtitle: 'm*****.d*****@mail.com',
                    onTap: () {
                      // TODO: Navigate to setup email
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.backup,
                    title: 'Códigos de respaldo',
                    subtitle: 'Generar códigos de respaldo',
                    onTap: () {
                      // TODO: Navigate to backup codes
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
                      '¿Por qué activar la autenticación de dos factores?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'La autenticación de dos factores añade una capa extra de seguridad a tu cuenta. '
                      'Además de tu contraseña, necesitarás un código generado por tu dispositivo '
                      'o enviado a tu teléfono/email.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
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
            if (trailing == null && onTap != null)
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