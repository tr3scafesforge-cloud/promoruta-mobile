import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PromoRuta'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Welcome to PromoRuta Home'),
      ),
    );
  }
}
