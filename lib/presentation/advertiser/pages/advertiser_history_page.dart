import 'package:flutter/material.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';

class AdvertiserHistoryPage extends StatelessWidget {
  const AdvertiserHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text('${l10n.history}${l10n.placeholderPending}',
          style: Theme.of(context).textTheme.titleMedium),
    );
  }
}