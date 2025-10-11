import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/gen/assets.gen.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Add this import

class ChooseRole extends StatelessWidget {
  const ChooseRole({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).chooseRoleSubtitle,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface,
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
                cardColor: colorScheme.surface,
                titleColor: colorScheme.primary,
                onTap: () async {  // Make async
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingDone', true);
                  if (context.mounted) {
                    context.go('/login?role=advertiser');
                  }
                },
                heroTag: 'advertiser_image',
              ),
              const SizedBox(height: 20),
              // Card for Promotor
              RoleCard(
                title: AppLocalizations.of(context).promoterTitle,
                description: AppLocalizations.of(context).promoterDescription,
                image: AssetImage(Assets.images.promoterSelection.path),
                cardColor: colorScheme.surface,
                titleColor: AppColors.deepOrange,
                onTap: () async {  // Make async
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboardingDone', true);
                  if (context.mounted) {
                    context.go('/login?role=promoter');
                  }
                },
                heroTag: 'promoter_image',
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
    required this.heroTag,
  });

  final String title;
  final String description;
  final AssetImage image;
  final Color cardColor;
  final Color titleColor;
  final VoidCallback onTap;
  final String heroTag;

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: widget.heroTag,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: capImageSize(
                      context,
                      widget.image,
                    )!,
                    height: 48,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: widget.titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
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