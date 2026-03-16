# PromoRuta Project Patterns Reference

Read this file when you need the exact code from the project's existing widgets to match their patterns precisely.

## Table of Contents

1. CustomButton (complete source)
2. CommonInputField (complete source)
3. AppCard (complete source)
4. Labeled field pattern
5. AdvertiserSearchFilterBar (search input pattern)
6. Provider patterns
7. ARB file format
8. Barrel file exports

---

## 1. CustomButton — `lib/shared/widgets/custom_button.dart`

```dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final Color textColor;
  final bool isOutlined;
  final Color? outlineColor;
  final bool shrinkToFit;

  const CustomButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.onPressed,
    this.textColor = Colors.white,
    this.isOutlined = false,
    this.outlineColor,
    this.shrinkToFit = false,
  });

  static CustomButton outlined({
    required String text,
    required Color backgroundColor,
    required Color outlineColor,
    required VoidCallback onPressed,
    required Color textColor,
  }) {
    return CustomButton(
      text: text,
      backgroundColor: backgroundColor,
      onPressed: onPressed,
      textColor: textColor,
      isOutlined: true,
      outlineColor: outlineColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: isOutlined
                ? Border.all(color: outlineColor ?? backgroundColor, width: 1)
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: shrinkToFit
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    text,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
```

## 2. CommonInputField — `lib/shared/widgets/common_input_field.dart`

The standard input field widget. Use this instead of raw `TextFormField`:

```dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:promoruta/core/constants/colors.dart';

class CommonInputField extends StatelessWidget {
  const CommonInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.headIcon,
    this.onHeadIconPressed,
    this.tailIcon,
    this.onTailIconPressed,
    this.suffixIcon,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? headIcon;
  final VoidCallback? onHeadIconPressed;
  final IconData? tailIcon;
  final VoidCallback? onTailIconPressed;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry contentPadding;

  Widget? _buildIconButton({
    required IconData? icon,
    required VoidCallback? onPressed,
  }) {
    if (icon == null) return null;
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: AppColors.textHint),
      splashRadius: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.surface,
        prefixIcon: _buildIconButton(
          icon: headIcon,
          onPressed: onHeadIconPressed,
        ),
        suffixIcon: suffixIcon ??
            _buildIconButton(
              icon: tailIcon,
              onPressed: onTailIconPressed,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayStroke),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.grayStroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: contentPadding,
      ),
    );
  }
}
```

**Usage examples:**
```dart
// Basic
CommonInputField(
  controller: _nameController,
  hintText: l10n.nameHint,
  validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
)

// Email
CommonInputField(
  controller: _emailController,
  hintText: l10n.emailHint,
  keyboardType: TextInputType.emailAddress,
)

// With leading and trailing icons
CommonInputField(
  controller: _searchController,
  hintText: l10n.searchHint,
  headIcon: Icons.search,
  tailIcon: Icons.clear,
  onTailIconPressed: () => _searchController.clear(),
)

// Multiline
CommonInputField(
  controller: _messageController,
  hintText: l10n.messageHint,
  maxLines: 4,
)

// Read-only with tap (date picker, etc.)
CommonInputField(
  controller: _dateController,
  hintText: l10n.selectDate,
  readOnly: true,
  onTap: () { /* show picker */ },
  suffixIcon: const Icon(Icons.calendar_today),
)
```

## 3. AppCard — `lib/shared/widgets/app_card.dart`

Standard card container with theme-aware border. Use this to wrap card-style content:

```dart
AppCard(
  child: Column(
    children: [/* content */],
  ),
)
```

- Border radius: 16px
- Uses `theme.colorScheme.surface` background
- Uses `theme.colorScheme.outline` border (when `hasBorder: true`)

## 4. Labeled Field Pattern

Labels go ABOVE the field as a separate Text widget:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      AppLocalizations.of(context).fieldLabel,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    ),
    const SizedBox(height: 8),
    CommonInputField(
      controller: _controller,
      hintText: l10n.fieldHint,
    ),
  ],
)
```

## 5. Search Input Pattern — `AdvertiserSearchFilterBar`

Different from form fields — uses plain `TextField` inside a custom container:

```dart
Container(
  decoration: BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: theme.colorScheme.outline),
  ),
  child: Row(
    children: [
      const SizedBox(width: 12),
      Icon(Icons.search, size: 20, color: theme.colorScheme.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  ),
)
```

## 6. Provider Patterns


**StateNotifier with AsyncValue:**
```dart
final myStateProvider = StateNotifierProvider<MyNotifier, AsyncValue<List<Item>>>((ref) {
  final useCase = ref.watch(myUseCaseProvider);
  return MyNotifier(useCase);
});

class MyNotifier extends StateNotifier<AsyncValue<List<Item>>> {
  final MyUseCase _useCase;

  MyNotifier(this._useCase) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _useCase();
      if (mounted) {
        state = AsyncValue.data(items);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }
}
```

**FutureProvider with family:**
```dart
final itemByIdProvider = FutureProvider.autoDispose
    .family<Item?, String>((ref, id) async {
  final useCase = ref.watch(getItemUseCaseProvider);
  return await useCase(id);
});
```

## 7. ARB File Format

Each string needs an entry + metadata in all 3 files:

**app_en.arb:**
```json
"widgetTitle": "My Title",
"@widgetTitle": {
  "description": "Title for the widget component"
}
```

**app_es.arb:**
```json
"widgetTitle": "Mi Título",
"@widgetTitle": {
  "description": "Título para el componente widget"
}
```

**app_pt.arb:**
```json
"widgetTitle": "Meu Título",
"@widgetTitle": {
  "description": "Título para o componente widget"
}
```

## 8. Barrel Exports

**`lib/shared/shared.dart`** — add new shared widgets here:
```dart
export 'widgets/my_widget.dart';
```

**`lib/shared/providers/providers.dart`** — add new shared providers here (either define inline or re-export from a feature).
