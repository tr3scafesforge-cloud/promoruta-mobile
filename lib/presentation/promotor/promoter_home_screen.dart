import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class PromoterHomeScreen extends StatelessWidget {
  const PromoterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promoter Home'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Welcome to Promoter Home Page'),
      ),
    );
  }
}