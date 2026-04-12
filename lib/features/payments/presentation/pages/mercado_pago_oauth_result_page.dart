import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/shared/widgets/custom_button.dart';

class MercadoPagoOAuthResultPage extends StatelessWidget {
  final String status;
  final String? message;

  const MercadoPagoOAuthResultPage({
    super.key,
    required this.status,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final success = status.toLowerCase() == 'success';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mercado Pago'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              size: 64,
              color: success ? const Color(0xFF147A3D) : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              success
                  ? 'Cuenta vinculada correctamente'
                  : 'No se pudo vincular la cuenta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Volver a métodos de pago',
                backgroundColor: AppColors.secondary,
                onPressed: () => context.go('/payment-methods'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
