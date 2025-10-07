import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:promoruta/gen/l10n/app_localizations.dart';
import 'package:promoruta/shared/shared.dart';

const _kAccent = Color(0xFF0A9995); // stroke + check fill color
const _kFillOpacity = 0.08; // tweak if you want stronger/weaker fill

class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  ConsumerState<LanguageSettingsPage> createState() =>
      _LanguageSettingsPageState();
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
          const SizedBox(height: 5),
          _LanguageOption(
            title: l10n.spanish,
            locale: const Locale('es'),
            groupValue: currentLocale,
            onChanged: (locale) => _changeLanguage(locale, l10n.spanish),
          ),
          const SizedBox(height: 5),
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
    final selected = locale == groupValue;

    // We wrap the AppCard child with a DecoratedBox to control stroke/fill.
    return AppCard(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? _kAccent.withValues(alpha: _kFillOpacity) : null,
          border: Border.all(
            color: selected ? _kAccent : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          type: MaterialType.transparency,
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
                  _RoundCheck(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundCheck extends StatelessWidget {
  const _RoundCheck({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _kAccent : Colors.transparent,
        border: Border.all(
          color: selected ? _kAccent : Theme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
