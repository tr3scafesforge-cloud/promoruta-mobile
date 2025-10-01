import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserLivePage extends StatelessWidget {
  const AdvertiserLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text('${l10n.live}${l10n.placeholderPending}',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}