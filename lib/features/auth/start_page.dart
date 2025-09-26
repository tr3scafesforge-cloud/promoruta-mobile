import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/utils/image_utils.dart';
import 'package:promoruta/gen/assets.gen.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const SizedBox(height: 32),
          Image(
            image: capImageSize(context, AssetImage(Assets.images.splashImg.path))!,
            height: 250,
            opacity: const AlwaysStoppedAnimation(0.9),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).welcomeMessage,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}