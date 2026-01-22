import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/features/auth/domain/use_cases/two_factor_use_cases.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:toastification/toastification.dart';

class RecoveryCodesPage extends ConsumerStatefulWidget {
  const RecoveryCodesPage({super.key});

  @override
  ConsumerState<RecoveryCodesPage> createState() => _RecoveryCodesPageState();
}

class _RecoveryCodesPageState extends ConsumerState<RecoveryCodesPage> {
  bool _isLoading = true;
  bool _isRegenerating = false;
  List<String> _recoveryCodes = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecoveryCodes();
  }

  Future<void> _loadRecoveryCodes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final getCodesUseCase = ref.read(getRecoveryCodesUseCaseProvider);
      final response = await getCodesUseCase(NoParams());

      setState(() {
        _recoveryCodes = response.recoveryCodes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _regenerateCodes() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.regenerateCodes),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.regenerateCodesWarning),
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
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11A192),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.regenerate),
          ),
        ],
      ),
    );

    if (result == true && passwordController.text.isNotEmpty) {
      await _performRegeneration(passwordController.text);
    }
  }

  Future<void> _performRegeneration(String password) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isRegenerating = true);

    try {
      final regenerateUseCase = ref.read(regenerateRecoveryCodesUseCaseProvider);
      final response = await regenerateUseCase(
        RegenerateRecoveryCodesParams(password: password),
      );

      setState(() {
        _recoveryCodes = response.recoveryCodes;
        _isRegenerating = false;
      });

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: Text(l10n.codesRegenerated),
          description: Text(l10n.newRecoveryCodesReady),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() => _isRegenerating = false);

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(l10n.error),
          description: Text(l10n.errorRegeneratingCodes(e.toString())),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _copyAllCodes() {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: _recoveryCodes.join('\n')));
    toastification.show(
      context: context,
      type: ToastificationType.success,
      title: Text(l10n.codesCopied),
      description: Text(l10n.allCodesCopied),
      autoCloseDuration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    const bg = Color(0xFFF3F5F7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.recoveryCodesPageTitle,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (!_isLoading && _recoveryCodes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black87),
              onPressed: _isRegenerating ? null : _regenerateCodes,
              tooltip: l10n.regenerateCodes,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildCodesContent(),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingCodes,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? l10n.unknownError,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadRecoveryCodes,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodesContent() {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.recoveryCodesWarning,
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Codes List
            Container(
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.yourRecoveryCodes,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _copyAllCodes,
                        icon: const Icon(Icons.copy, size: 18),
                        label: Text(l10n.copyAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._recoveryCodes.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final code = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF11A192).withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF11A192),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                code,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 15,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        l10n.howToUseCodes,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.recoveryCodesInstructions,
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
