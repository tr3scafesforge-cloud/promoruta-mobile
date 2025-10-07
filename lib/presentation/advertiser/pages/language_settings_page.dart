import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _LanguageOption(
            title: l10n.english,
            locale: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (locale) => _changeLanguage(locale, l10n.english),
          ),
          const SizedBox(height: 12),
          _LanguageOption(
            title: l10n.spanish,
            locale: const Locale('es'),
            groupValue: currentLocale,
            onChanged: (locale) => _changeLanguage(locale, l10n.spanish),
          ),
          const SizedBox(height: 12),
          _LanguageOption(
            title: l10n.portuguese,
            locale: const Locale('pt'),
            groupValue: currentLocale,
            onChanged: (locale) => _changeLanguage(locale, l10n.portuguese),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(Locale locale, String languageName) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changeLanguageTitle),
        content: Text(l10n.changeLanguageMessage(languageName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(localeProvider.notifier).setLocale(locale);
    }
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.locale,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final Locale locale;
  final Locale groupValue;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        onTap: () => onChanged(locale),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Radio<Locale>(
                value: locale,
                groupValue: groupValue,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}