import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/constants/colors.dart';
import 'package:promoruta/core/utils/image_helper.dart';
import 'package:promoruta/gen/assets.gen.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class ChooseRole extends StatelessWidget {
  const ChooseRole({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context).chooseRoleTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 28
                      ,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).chooseRoleSubtitle,
                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w100,
                      fontSize: 20,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // Card for Anunciante
              RoleCard(
                title: AppLocalizations.of(context).advertiserTitle,
                description: AppLocalizations.of(context).advertiserDescription,
                image: AssetImage(Assets.images.advertiserSelection.path),
                cardColor: AppColors.background,
                titleColor: AppColors.secondary,
                onTap: () => context.go('/login?role=advertiser'),
              ),
              const SizedBox(height: 20),
              // Card for Promotor
              RoleCard(
                title: AppLocalizations.of(context).promoterTitle,
                description: AppLocalizations.of(context).promoterDescription,
                image: AssetImage(Assets.images.promoterSelection.path),
                cardColor: Colors.white,
                titleColor: Colors.deepOrange,
                onTap: () => context.go('/login?role=promoter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class RoleCard extends StatefulWidget {
  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    required this.cardColor,
    required this.titleColor,
    required this.onTap,
  });

  final String title;
  final String description;
  final AssetImage image;
  final Color cardColor;
  final Color titleColor;
  final VoidCallback onTap;

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: capImageSize(
                    context,
                    widget.image,
                  )!,
                  height: 48,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            color: widget.titleColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}