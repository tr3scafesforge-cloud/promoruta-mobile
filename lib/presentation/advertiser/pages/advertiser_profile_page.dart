import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserProfilePage extends StatelessWidget {
  const AdvertiserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text('${l10n.profile}${l10n.placeholderPending}',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}