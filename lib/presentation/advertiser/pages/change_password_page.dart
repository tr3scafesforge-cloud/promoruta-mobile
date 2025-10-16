import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/shared/shared.dart';
import 'package:promoruta/shared/use_cases/auth_use_cases.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

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
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SettingsCard(
                children: [
                  _PasswordField(
                    controller: _currentPasswordController,
                    label: 'Contraseña actual',
                    obscureText: _obscureCurrent,
                    onToggleVisibility: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La contraseña actual es requerida';
                      }
                      return null;
                    },
                  ),
                  const _RowDivider(),
                  _PasswordField(
                    controller: _newPasswordController,
                    label: 'Nueva contraseña',
                    obscureText: _obscureNew,
                    onToggleVisibility: () => setState(() => _obscureNew = !_obscureNew),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La nueva contraseña es requerida';
                      }
                      if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                  const _RowDivider(),
                  _PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar nueva contraseña',
                    obscureText: _obscureConfirm,
                    onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La confirmación de contraseña es requerida';
                      }
                      if (value != _newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF11A192),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Cambiar Contraseña'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final changePasswordUseCase = ref.read(changePasswordUseCaseProvider);
        await changePasswordUseCase(ChangePasswordParams(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
          newPasswordConfirmation: _confirmPasswordController.text,
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña cambiada exitosamente')),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cambiar contraseña: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
            ),
            onPressed: onToggleVisibility,
          ),
        ),
        validator: validator,
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