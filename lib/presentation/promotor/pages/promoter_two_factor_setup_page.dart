import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/features/auth/domain/models/two_factor_models.dart';
import 'package:promoruta/features/auth/domain/use_cases/two_factor_use_cases.dart';
import 'package:promoruta/shared/providers/providers.dart';
import 'package:toastification/toastification.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class PromoterTwoFactorSetupPage extends ConsumerStatefulWidget {
  const PromoterTwoFactorSetupPage({super.key});

  @override
  ConsumerState<PromoterTwoFactorSetupPage> createState() => _PromoterTwoFactorSetupPageState();
}

class _PromoterTwoFactorSetupPageState extends ConsumerState<PromoterTwoFactorSetupPage> {
  final _codeController = TextEditingController();
  bool _isLoading = true;
  bool _isVerifying = false;
  TwoFactorEnableResponse? _setupData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSetup();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _initializeSetup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final enable2FAUseCase = ref.read(enable2FAUseCaseProvider);
      final response = await enable2FAUseCase(NoParams());

      setState(() {
        _setupData = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAndEnable() async {
    final l10n = AppLocalizations.of(context);
    if (_codeController.text.length != 6) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(l10n.invalidCode),
        description: Text(l10n.codeMustBeSixDigits),
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final confirm2FAUseCase = ref.read(confirm2FAUseCaseProvider);
      final response = await confirm2FAUseCase(
        Confirm2FAParams(
          secret: _setupData!.secret,
          code: _codeController.text,
        ),
      );

      if (mounted) {
        // Refresh user data to update 2FA status
        ref.invalidate(authStateProvider);

        // Show recovery codes
        await _showRecoveryCodes(response.recoveryCodes);

        // Navigate back
        if (context.mounted) {
          context.go('/promoter-security-settings');
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text(l10n.error),
          description: Text(l10n.incorrectCode(e.toString())),
          autoCloseDuration: const Duration(seconds: 3),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<void> _showRecoveryCodes(List<String> codes) async {
    final l10n = AppLocalizations.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.recoveryCodes),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.saveRecoveryCodesMessage,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: codes
                    .map((code) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SelectableText(
                            code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final l10n = AppLocalizations.of(context);
              Clipboard.setData(ClipboardData(text: codes.join('\n')));
              toastification.show(
                context: context,
                type: ToastificationType.success,
                title: Text(l10n.codesCopied),
                autoCloseDuration: const Duration(seconds: 2),
              );
            },
            child: Text(l10n.copyCodes),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF11A192),
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
  }

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
        title: Text(
          l10n.setup2FA,
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildSetupContent(),
    );
  }

  Widget _buildErrorState() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.errorSettingUp2FA,
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
              onPressed: _initializeSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupContent() {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Step 1: Download App
            _buildStepCard(
              stepNumber: '1',
              title: l10n.downloadAuthenticatorApp,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.weRecommend),
                  const SizedBox(height: 8),
                  Text('• ${l10n.googleAuthenticator}'),
                  Text('• ${l10n.microsoftAuthenticator}'),
                  Text('• ${l10n.authy}'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 2: Scan QR Code
            _buildStepCard(
              stepNumber: '2',
              title: l10n.scanQRCode,
              content: Column(
                children: [
                  if (_setupData?.qrCodeSvg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.string(
                        _setupData!.qrCodeSvg,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.orEnterKeyManually,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SelectableText(
                              _setupData!.secret,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _setupData!.secret),
                              );
                              toastification.show(
                                context: context,
                                type: ToastificationType.success,
                                title: Text(l10n.keyCopied),
                                autoCloseDuration: const Duration(seconds: 2),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Enter Code
            _buildStepCard(
              stepNumber: '3',
              title: l10n.enterVerificationCode,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.enterSixDigitCode),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: '000000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Verify Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndEnable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF11A192),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.verifyAndEnable,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFF11A192),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
