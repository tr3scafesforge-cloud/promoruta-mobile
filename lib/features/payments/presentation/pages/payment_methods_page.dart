import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';
import 'package:promoruta/features/payments/domain/models/mercado_pago_oauth_models.dart';
import 'package:promoruta/features/payments/presentation/providers/mercado_pago_oauth_providers.dart';
import 'package:promoruta/shared/providers/providers.dart'
    show notificationServiceProvider;
import 'package:promoruta/shared/services/in_app_browser_launcher.dart';
import 'package:promoruta/shared/services/notification_service.dart';
import 'package:promoruta/shared/widgets/app_confirmation_dialog.dart';
import 'package:promoruta/shared/widgets/custom_button.dart';

class PaymentMethodsPage extends ConsumerStatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  ConsumerState<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends ConsumerState<PaymentMethodsPage>
    with WidgetsBindingObserver {
  bool _isConnecting = false;
  bool _isDisconnecting = false;
  bool _isRefreshingStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshMercadoPagoStatus(showFeedback: false);
    }
  }

  Future<void> _refreshMercadoPagoStatus({bool showFeedback = true}) async {
    if (_isRefreshingStatus) return;
    setState(() => _isRefreshingStatus = true);

    try {
      await ref.refresh(mercadoPagoAccountStatusProvider.future);
      if (!mounted || !showFeedback) return;
      _showNotification(
        'Estado de Mercado Pago actualizado.',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showNotification(
        _cleanError(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshingStatus = false);
      }
    }
  }

  Future<void> _connectMercadoPago() async {
    setState(() => _isConnecting = true);
    try {
      final useCase = ref.read(getMercadoPagoAuthorizeUrlUseCaseProvider);
      final data = await useCase();
      final uri = Uri.tryParse(data.authorizeUrl);
      if (uri == null) {
        throw Exception('Invalid Mercado Pago authorize URL.');
      }

      if (!mounted) return;
      await InAppBrowserLauncher.open(context, uri);

      if (!mounted) return;
      _showNotification(
        'Complete la autorización en Mercado Pago y vuelva a la app.',
        type: ToastType.info,
      );
    } catch (e) {
      if (!mounted) return;
      _showNotification(
        _cleanError(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
      ref.invalidate(mercadoPagoAccountStatusProvider);
    }
  }

  Future<void> _disconnectMercadoPago() async {
    setState(() => _isDisconnecting = true);
    try {
      final useCase = ref.read(disconnectMercadoPagoUseCaseProvider);
      await useCase();

      if (!mounted) return;
      _showNotification(
        'Cuenta de Mercado Pago desconectada.',
        type: ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      _showNotification(
        _cleanError(e),
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isDisconnecting = false);
      }
      ref.invalidate(mercadoPagoAccountStatusProvider);
    }
  }

  String _cleanError(Object error) {
    var message = error.toString().trim();
    if (message.startsWith('Exception:')) {
      message = message.replaceFirst('Exception:', '').trim();
    }
    return message.isEmpty ? 'Ocurrió un error inesperado.' : message;
  }

  void _showNotification(
    String message, {
    ToastType type = ToastType.info,
  }) {
    ref.read(notificationServiceProvider).showToast(
          message,
          type: type,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF3F5F7);
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final isPromoter = user?.role == UserRole.promoter;
    final fallbackSecurityRoute = isPromoter
        ? '/promoter-security-settings'
        : '/advertiser-security-settings';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(fallbackSecurityRoute),
        ),
        title: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (isPromoter)
              _PromoterMercadoPagoCard(
                statusAsync: ref.watch(mercadoPagoAccountStatusProvider),
                isConnecting: _isConnecting,
                isDisconnecting: _isDisconnecting,
                isRefreshing: _isRefreshingStatus,
                onConnect: _connectMercadoPago,
                onDisconnect: _disconnectMercadoPago,
                onRefresh: _refreshMercadoPagoStatus,
              )
            else
              const _AdvertiserPaymentMethodsCard(),
          ],
        ),
      ),
    );
  }
}

class _PromoterMercadoPagoCard extends StatelessWidget {
  final AsyncValue<MercadoPagoAccountStatus> statusAsync;
  final bool isConnecting;
  final bool isDisconnecting;
  final bool isRefreshing;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final Future<void> Function() onRefresh;

  const _PromoterMercadoPagoCard({
    required this.statusAsync,
    required this.isConnecting,
    required this.isDisconnecting,
    required this.isRefreshing,
    required this.onConnect,
    required this.onDisconnect,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: [
        const _SettingsTile(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Mercado Pago',
          subtitle: 'Conecta tu cuenta para recibir pagos al aceptar ofertas.',
        ),
        const _RowDivider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: statusAsync.when(
            loading: () => const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 10),
                Expanded(child: Text('Consultando estado de conexión...')),
              ],
            ),
            error: (error, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isRefreshing ? null : () => onRefresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
            data: (status) => _ConnectedState(
              status: status,
              isConnecting: isConnecting,
              isDisconnecting: isDisconnecting,
              isRefreshing: isRefreshing,
              onConnect: onConnect,
              onDisconnect: onDisconnect,
              onRefresh: onRefresh,
            ),
          ),
        ),
      ],
    );
  }
}

class _ConnectedState extends StatelessWidget {
  final MercadoPagoAccountStatus status;
  final bool isConnecting;
  final bool isDisconnecting;
  final bool isRefreshing;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final Future<void> Function() onRefresh;

  const _ConnectedState({
    required this.status,
    required this.isConnecting,
    required this.isDisconnecting,
    required this.isRefreshing,
    required this.onConnect,
    required this.onDisconnect,
    required this.onRefresh,
  });

  Future<bool> _confirmDisconnect(BuildContext context) async {
    final result = await AppConfirmationDialog.show(
      context,
      title: 'Desconectar Mercado Pago',
      message: 'Estas seguro de que deseas desconectar tu cuenta de Mercado Pago?',
      confirmText: 'Desconectar',
      cancelText: 'Cancelar',
      confirmButtonColor: const Color(0xFFCC0033),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = status.connected;
    final isBusy = isConnecting || isDisconnecting || isRefreshing;
    final subtitle = isConnected
        ? 'Cuenta conectada${status.username != null ? ' (${status.username})' : ''}'
        : 'Cuenta no conectada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            color: isConnected ? const Color(0xFF147A3D) : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (status.userId != null) ...[
          const SizedBox(height: 6),
          Text(
            'ID Mercado Pago: ${status.userId}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
        const SizedBox(height: 14),
        AbsorbPointer(
          absorbing: isBusy,
          child: Opacity(
            opacity: isBusy ? 0.7 : 1,
            child: CustomButton(
              text: isBusy
                  ? 'Procesando...'
                  : (isConnected
                        ? 'Desconectar Mercado Pago'
                        : 'Conectar Mercado Pago'),
              backgroundColor: isConnected
                  ? const Color(0xFFCC0033)
                  : AppColors.secondary,
              leadingIcon: isBusy
                  ? Icons.hourglass_top
                  : (isConnected ? Icons.link_off : Icons.link),
              onPressed: () async {
                if (!isConnected) {
                  onConnect();
                  return;
                }

                final confirmed = await _confirmDisconnect(context);
                if (confirmed) {
                  onDisconnect();
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        AbsorbPointer(
          absorbing: isBusy,
          child: Opacity(
            opacity: isBusy ? 0.7 : 1,
            child: CustomButton(
              text: isRefreshing ? 'Actualizando...' : 'Actualizar estado',
              backgroundColor: Colors.white,
              textColor: AppColors.secondary,
              isOutlined: true,
              outlineColor: AppColors.secondary,
              leadingIcon: isRefreshing ? Icons.hourglass_top : Icons.refresh,
              onPressed: () => onRefresh(),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdvertiserPaymentMethodsCard extends StatelessWidget {
  const _AdvertiserPaymentMethodsCard();

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      children: const [
        _SettingsTile(
          icon: Icons.credit_card,
          title: 'Tarjeta de Crédito',
          subtitle: '**** **** **** 1234',
        ),
        _RowDivider(),
        _SettingsTile(
          icon: Icons.account_balance,
          title: 'Transferencia Bancaria',
          subtitle: 'Cuenta corriente',
        ),
        _RowDivider(),
        _SettingsTile(
          icon: Icons.add,
          title: 'Agregar método de pago',
        ),
      ],
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
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black54,
        );

    return Padding(
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
