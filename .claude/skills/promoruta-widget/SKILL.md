---
name: promoruta-widget
description: >
  Create Flutter widgets for the PromoRuta mobile app following its established architecture:
  Clean Architecture, Riverpod state management, Material 3 theming, and i18n localization.
  Use this skill whenever the user asks to create a new widget, UI component, screen element,
  reusable card, form, dialog, bottom sheet, or any visual building block for the promoruta_mobile
  project. Also trigger when the user says things like "add a widget for...", "build a component
  that...", "I need a UI for...", or mentions creating something visual in this Flutter project.
---

# PromoRuta Widget Creator

You are creating widgets for the PromoRuta mobile app — a Flutter application connecting advertisers with promoters for campaign management. The codebase follows Clean Architecture with Riverpod, Material 3 theming, and supports 3 languages (en, es, pt).

## Before You Start

1. **Use the Dart MCP** if available — it provides Dart analysis, code actions, and refactoring tools that make widget creation more reliable. Check your available tools for any `dart_mcp` or `dart_tooling` entries.
2. **Read the existing patterns first.** Before writing any widget, read at least one similar existing widget from `lib/shared/widgets/` to match the current style. The project evolves, so always check the latest code rather than relying solely on these instructions.

## Widget Architecture Decision

Choose the right base class based on what the widget needs:

| Widget needs...                  | Use                        |
|----------------------------------|----------------------------|
| Only constructor params, no state | `StatelessWidget`         |
| Local UI state (animation, toggle)| `StatefulWidget`          |
| Riverpod provider data            | `ConsumerWidget`          |
| Both local state + providers      | `ConsumerStatefulWidget`  |

## File Creation Checklist

When creating a new shared widget, you'll touch up to 4 areas:

1. **Widget file** → `lib/shared/widgets/<widget_name>.dart`
2. **Barrel export** → add to `lib/shared/shared.dart`
3. **Localization strings** → add to all 3 `.arb` files in `lib/l10n/`
4. **Provider** (if data-driven) → `lib/shared/providers/` or feature-specific provider

### Step 1: Create the Widget File

Place shared reusable widgets in `lib/shared/widgets/`. Use `snake_case` for the filename, `PascalCase` for the class.

**Import order** (follow this consistently):
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // only if using providers
import 'package:promoruta/core/core.dart';               // for AppColors, models
import 'package:promoruta/gen/l10n/app_localizations.dart'; // for i18n
import 'package:promoruta/shared/shared.dart';            // for shared widgets/providers
```

**Constructor pattern:**
```dart
class MyWidget extends StatelessWidget {
  const MyWidget({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // ...
  }
}
```

Key conventions:
- Use `super.key` (not `Key? key`)
- Declare fields as `final` after the constructor
- Extract `theme` and `l10n` at the top of `build()`
- Use `theme.colorScheme` and `theme.textTheme` — never hardcode colors or text styles
- Private helper widgets (prefixed with `_`) are encouraged for composition within the same file

### Step 2: Buttons and Input Fields — Use the Standard Designs

This is important: the project has established button and input patterns. New widgets that contain buttons or text inputs must reuse these designs for visual consistency.

**Buttons — use `CustomButton`:**

```dart
// Primary filled button
CustomButton(
  text: l10n.someAction,
  backgroundColor: theme.colorScheme.primary,
  textColor: theme.colorScheme.onPrimary,
  onPressed: () { /* action */ },
)

// Outlined variant
CustomButton.outlined(
  text: l10n.cancel,
  backgroundColor: theme.colorScheme.surface,
  outlineColor: theme.colorScheme.outline,
  textColor: theme.colorScheme.onSurface,
  onPressed: () { /* action */ },
)
```

`CustomButton` is 45px tall, full-width, with 10px border radius. If you need a compact or icon button, use Material's `IconButton`, `TextButton`, or `ElevatedButton` with the project's standard styling:

```dart
ElevatedButton.styleFrom(
  backgroundColor: theme.colorScheme.primary,
  foregroundColor: theme.colorScheme.onPrimary,
  padding: const EdgeInsets.symmetric(vertical: 16),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  elevation: 2,
)
```

**Input fields — follow the established `TextFormField` pattern:**

```dart
TextFormField(
  controller: _controller,
  decoration: InputDecoration(
    filled: true,
    fillColor: theme.colorScheme.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
)
```

Always define all three border states (border, enabledBorder, focusedBorder). Use 8px border radius for inputs. Add a label `Text` widget above the field (not `labelText` in decoration) with `titleMedium` bold style — this is how the project does labeled fields.

For search bars, reference `AdvertiserSearchFilterBar` which uses `TextField` (not `TextFormField`) with `InputBorder.none` inside a custom `Container` with 12px radius.

### Step 3: Wire Up Localization

Every user-visible string must go through localization. Add entries to all 3 ARB files:

- `lib/l10n/app_en.arb` (English)
- `lib/l10n/app_es.arb` (Spanish — this is the primary language)
- `lib/l10n/app_pt.arb` (Portuguese)

**ARB entry format:**
```json
"myWidgetTitle": "The title text",
"@myWidgetTitle": {
  "description": "Title displayed in the MyWidget component"
}
```

Use `camelCase` for keys. Group new entries at the end of the file or near related entries. After adding ARB entries, run code generation:

```bash
flutter gen-l10n
```

Then access strings via:
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.myWidgetTitle)
```

### Step 4: Create Providers (If Needed)

If the widget needs to fetch, transform, or share data, create a Riverpod provider.

**For shared/cross-feature data** → `lib/shared/providers/`
**For feature-specific data** → `lib/features/<feature>/presentation/providers/`

Provider patterns used in this project:

```dart
// Simple computed value
final myDataProvider = Provider<MyType>((ref) {
  final upstream = ref.watch(someOtherProvider);
  return transform(upstream);
});

// Async data fetch
final myAsyncProvider = FutureProvider.autoDispose<MyType>((ref) async {
  final useCase = ref.watch(myUseCaseProvider);
  return await useCase();
});

// Parameterized fetch
final itemByIdProvider = FutureProvider.autoDispose
    .family<Item?, String>((ref, id) async {
  final useCase = ref.watch(getItemUseCaseProvider);
  return await useCase(id);
});

// Mutable state with notifier
final myStateProvider = StateNotifierProvider<MyNotifier, AsyncValue<List<Item>>>((ref) {
  final useCase = ref.watch(myUseCaseProvider);
  return MyNotifier(useCase);
});
```

If the provider is shared, export it from `lib/shared/providers/providers.dart`.

### Step 5: Update Barrel Exports

Add the new widget to `lib/shared/shared.dart`:

```dart
export 'widgets/my_widget.dart';
```

This lets other files import it via `import 'package:promoruta/shared/shared.dart';`

## Theming Reference

- **Material 3** with `useMaterial3: true`
- Theme is seeded dynamically based on user role
- Access colors via `theme.colorScheme` (primary, secondary, surface, outline, error, etc.)
- Access text styles via `theme.textTheme` (headlineLarge, titleMedium, bodyMedium, etc.)
- Project-specific colors in `AppColors` from `core/constants/colors.dart` — use for status indicators (completedGreenColor, canceledRedColor, pendingOrangeColor)
- Cards use 16px border radius (`AppCard`), inputs use 8px, buttons use 10px

## Composition Patterns

- Wrap content in `AppCard` for card-style containers
- Use private `_HelperWidget` classes for sub-components within the same file
- Use `const` constructors wherever possible
- Dispose controllers in `StatefulWidget.dispose()`
- Check `context.mounted` after async operations before using context
- Check `mounted` in StateNotifiers before updating state

## Common Mistakes to Avoid

- Hardcoding colors or strings (use theme and l10n)
- Forgetting to add strings to ALL 3 ARB files
- Using `Key? key` instead of `super.key`
- Not disposing TextEditingControllers
- Missing `context.mounted` checks after await
- Creating a new button style when `CustomButton` works
- Using `labelText` in InputDecoration instead of a separate label Text widget above the field
