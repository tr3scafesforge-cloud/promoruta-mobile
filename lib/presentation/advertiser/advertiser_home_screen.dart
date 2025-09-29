import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class AdvertiserHomeScreen extends StatelessWidget {
  const AdvertiserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertiser Home'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Welcome to Advertiser Home Page'),
      ),
    );
  }
}