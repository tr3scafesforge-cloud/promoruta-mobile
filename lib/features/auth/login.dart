import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.login,
            size: 100,
            color: Colors.teal,
          ),
          const SizedBox(height: 32),
          Text(
            'Inicia Sesión',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Ingresa tus credenciales para continuar.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}