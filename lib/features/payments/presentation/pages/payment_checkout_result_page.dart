import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/features/auth/presentation/providers/auth_providers.dart';

class PaymentCheckoutResultPage extends ConsumerWidget {
  final String status;

  const PaymentCheckoutResultPage({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalized = status.toLowerCase();
    final user = ref.watch(authStateProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );

    final title = switch (normalized) {
      'success' || 'approved' => 'Pago aprobado',
      'failure' || 'failed' => 'Pago no completado',
      _ => 'Pago pendiente',
    };

    final subtitle = switch (normalized) {
      'success' ||
      'approved' =>
        'Tu pago fue aprobado. Puedes volver al detalle de campaña.',
      'failure' ||
      'failed' =>
        'El pago fue rechazado o cancelado. Puedes reintentar desde la campaña.',
      _ =>
        'El pago sigue pendiente. Verifica el estado en la campaña en unos minutos.',
    };

    final icon = switch (normalized) {
      'success' || 'approved' => Icons.check_circle,
      'failure' || 'failed' => Icons.error,
      _ => Icons.hourglass_top,
    };

    final color = switch (normalized) {
      'success' || 'approved' => const Color(0xFF147A3D),
      'failure' || 'failed' => Colors.red,
      _ => const Color(0xFFB06A00),
    };

    final homePath =
        user?.role == UserRole.promoter ? '/promoter-home' : '/advertiser-home';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go(homePath),
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
