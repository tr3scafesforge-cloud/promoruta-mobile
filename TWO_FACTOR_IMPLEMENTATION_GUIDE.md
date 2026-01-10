# Two-Factor Authentication (2FA) Implementation Guide

## ✅ Completed Implementation

### Backend (PHP Laravel) - 100% Complete

All backend components have been fully implemented and tested:

1. ✅ **Database Schema**
   - Migration created: `2026_01_09_025401_add_two_factor_columns_to_users_table.php`
   - Columns: `two_factor_secret`, `two_factor_recovery_codes`, `two_factor_confirmed_at`
   - Migration run successfully

2. ✅ **Service Layer**
   - `TwoFactorAuthenticationService` with full TOTP support
   - QR code generation (SVG format)
   - Recovery codes management
   - Secure encryption of secrets

3. ✅ **API Endpoints** (7 endpoints)
   - `POST /api/auth/2fa/enable` - Generate QR code
   - `POST /api/auth/2fa/confirm` - Enable 2FA
   - `POST /api/auth/2fa/disable` - Disable 2FA
   - `POST /api/auth/2fa/verify` - Verify code during login
   - `GET /api/auth/2fa/recovery-codes` - View recovery codes
   - `POST /api/auth/2fa/recovery-codes/regenerate` - Generate new codes

4. ✅ **Modified Login Flow**
   - Detects 2FA-enabled users
   - Returns `requires_2fa: true` response

5. ✅ **Localization**
   - English and Spanish translations
   - Files: `lang/en/auth.php`, `lang/es/auth.php`

6. ✅ **Documentation**
   - Complete API documentation
   - Testing instructions
   - User flow examples

### Flutter (Mobile App) - 75% Complete

#### ✅ Completed Components:

1. **Data Models**
   - ✅ Updated `User` model with `twoFactorEnabled` and `twoFactorConfirmedAt`
   - ✅ Created `TwoFactorEnableResponse`, `TwoFactorConfirmResponse`, `RecoveryCodesResponse`
   - ✅ Created `TwoFactorRequiredException` for login flow

2. **Database (Drift)**
   - ✅ Added `twoFactorEnabled` and `twoFactorConfirmedAt` columns to `Users` table
   - ✅ Incremented schema version to 6
   - ✅ Created migration from schema 5 to 6
   - ✅ Run build_runner successfully

3. **Domain Layer**
   - ✅ Added 2FA methods to `AuthRepository` interface (6 methods)
   - ✅ Added 2FA methods to `AuthRemoteDataSource` interface

4. **Data Layer**
   - ✅ Implemented all 6 2FA methods in `AuthRemoteDataSourceImpl`:
     - `enable2FA()` - Calls `/auth/2fa/enable`
     - `confirm2FA()` - Calls `/auth/2fa/confirm`
     - `disable2FA()` - Calls `/auth/2fa/disable`
     - `verify2FACode()` - Calls `/auth/2fa/verify`
     - `getRecoveryCodes()` - Calls `/auth/2fa/recovery-codes`
     - `regenerateRecoveryCodes()` - Calls `/auth/2fa/recovery-codes/regenerate`
   - ✅ Updated local storage to cache 2FA status
   - ✅ Modified `login()` to throw `TwoFactorRequiredException` when needed

5. **Repository Implementation**
   - ✅ Implemented all 6 2FA methods in `AuthRepositoryImpl`
   - ✅ Added offline/connectivity checks
   - ✅ Proper error handling

---

## 📋 Remaining Implementation Tasks

### 1. Create Use Cases (30 mins)

Create file: `lib/features/auth/domain/use_cases/two_factor_use_cases.dart`

```dart
import 'package:promoruta/core/core.dart';
import 'package:promoruta/shared/use_cases/base_use_case.dart';
import '../models/two_factor_models.dart';
import '../repositories/auth_repository.dart';

// Enable 2FA Use Case
class Enable2FAUseCase implements UseCase<TwoFactorEnableResponse, NoParams> {
  final AuthRepository _repository;

  Enable2FAUseCase(this._repository);

  @override
  Future<TwoFactorEnableResponse> call(NoParams params) async {
    return await _repository.enable2FA();
  }
}

// Confirm 2FA Use Case
class Confirm2FAUseCase implements UseCase<TwoFactorConfirmResponse, Confirm2FAParams> {
  final AuthRepository _repository;

  Confirm2FAUseCase(this._repository);

  @override
  Future<TwoFactorConfirmResponse> call(Confirm2FAParams params) async {
    return await _repository.confirm2FA(params.secret, params.code);
  }
}

class Confirm2FAParams {
  final String secret;
  final String code;

  Confirm2FAParams({required this.secret, required this.code});
}

// Disable 2FA Use Case
class Disable2FAUseCase implements UseCase<String, Disable2FAParams> {
  final AuthRepository _repository;

  Disable2FAUseCase(this._repository);

  @override
  Future<String> call(Disable2FAParams params) async {
    return await _repository.disable2FA(params.password);
  }
}

class Disable2FAParams {
  final String password;

  Disable2FAParams({required this.password});
}

// Verify 2FA Code Use Case
class Verify2FACodeUseCase implements UseCase<User, Verify2FACodeParams> {
  final AuthRepository _repository;

  Verify2FACodeUseCase(this._repository);

  @override
  Future<User> call(Verify2FACodeParams params) async {
    return await _repository.verify2FACode(
      email: params.email,
      password: params.password,
      code: params.code,
      recoveryCode: params.recoveryCode,
    );
  }
}

class Verify2FACodeParams {
  final String email;
  final String password;
  final String? code;
  final String? recoveryCode;

  Verify2FACodeParams({
    required this.email,
    required this.password,
    this.code,
    this.recoveryCode,
  });
}

// Get Recovery Codes Use Case
class GetRecoveryCodesUseCase implements UseCase<RecoveryCodesResponse, NoParams> {
  final AuthRepository _repository;

  GetRecoveryCodesUseCase(this._repository);

  @override
  Future<RecoveryCodesResponse> call(NoParams params) async {
    return await _repository.getRecoveryCodes();
  }
}

// Regenerate Recovery Codes Use Case
class RegenerateRecoveryCodesUseCase implements UseCase<RecoveryCodesResponse, RegenerateRecoveryCodesParams> {
  final AuthRepository _repository;

  RegenerateRecoveryCodesUseCase(this._repository);

  @override
  Future<RecoveryCodesResponse> call(RegenerateRecoveryCodesParams params) async {
    return await _repository.regenerateRecoveryCodes(params.password);
  }
}

class RegenerateRecoveryCodesParams {
  final String password;

  RegenerateRecoveryCodesParams({required this.password});
}

class NoParams {}
```

---

### 2. Register Providers (15 mins)

Add to `lib/shared/providers/providers.dart`:

```dart
// 2FA Use Case Providers
final enable2FAUseCaseProvider = Provider<Enable2FAUseCase>((ref) {
  return Enable2FAUseCase(ref.watch(authRepositoryProvider));
});

final confirm2FAUseCaseProvider = Provider<Confirm2FAUseCase>((ref) {
  return Confirm2FAUseCase(ref.watch(authRepositoryProvider));
});

final disable2FAUseCaseProvider = Provider<Disable2FAUseCase>((ref) {
  return Disable2FAUseCase(ref.watch(authRepositoryProvider));
});

final verify2FACodeUseCaseProvider = Provider<Verify2FACodeUseCase>((ref) {
  return Verify2FACodeUseCase(ref.watch(authRepositoryProvider));
});

final getRecoveryCodesUseCaseProvider = Provider<GetRecoveryCodesUseCase>((ref) {
  return GetRecoveryCodesUseCase(ref.watch(authRepositoryProvider));
});

final regenerateRecoveryCodesUseCaseProvider = Provider<RegenerateRecoveryCodesUseCase>((ref) {
  return RegenerateRecoveryCodesUseCase(ref.watch(authRepositoryProvider));
});
```

---

### 3. Add Required Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  qr_flutter: ^4.1.0  # For displaying QR codes
  flutter_svg: ^2.0.9  # For rendering SVG QR codes
```

Run: `flutter pub get`

---

### 4. Create UI Pages (2-3 hours)

#### A. QR Code Display Page

Create: `lib/features/auth/presentation/pages/enable_2fa_qr_page.dart`

This page should:
- Display the QR code returned from the backend (SVG format)
- Show the secret key as text (for manual entry)
- Have a "Continue" button that navigates to confirmation page
- Show loading indicator while fetching QR code

Use `flutter_svg` to render the SVG QR code:
```dart
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.string(
  qrCodeSvg,
  width: 250,
  height: 250,
)
```

#### B. Confirm 2FA Page

Create: `lib/features/auth/presentation/pages/confirm_2fa_page.dart`

This page should:
- Display 6-digit code input field
- Call `confirm2FA` use case when user submits
- Navigate to recovery codes page on success
- Show error message if code is invalid

Use a PIN code input widget or 6 separate text fields.

#### C. Recovery Codes Display Page

Create: `lib/features/auth/presentation/pages/recovery_codes_page.dart`

This page should:
- Display the 8 recovery codes in a grid/list
- Have "Copy All" button
- Have "Download" or "Print" option
- Warning message to save codes securely
- "Done" button that closes the flow

#### D. 2FA Verification Page (Login)

Create: `lib/features/auth/presentation/pages/verify_2fa_page.dart`

This page should:
- Accept email and password as parameters
- Display 6-digit code input
- Have "Use recovery code instead" button
- Call `verify2FACode` use case
- Navigate to home on success
- Handle TwoFactorRequiredException

#### E. Update existing Two Factor Auth Page

Update: `lib/features/profile/presentation/pages/two_factor_auth_page.dart`

Current status: Has UI but no functionality

Changes needed:
- Wire up the switch to call `enable2FA` or `disable2FA`
- Show current 2FA status from user model
- Navigate to QR page when enabling
- Prompt for password when disabling
- Add "View Recovery Codes" option
- Add "Regenerate Recovery Codes" option

---

### 5. Update Login Flow (30 mins)

Modify: `lib/features/auth/presentation/pages/login_page.dart` (or wherever login is handled)

Add try-catch for `TwoFactorRequiredException`:

```dart
try {
  final user = await ref.read(authStateProvider.notifier).login(email, password);
  // Navigate based on role
} on TwoFactorRequiredException catch (e) {
  // Navigate to 2FA verification page
  context.push('/verify-2fa', extra: {
    'email': e.email,
    'password': password, // Pass password for 2FA verification
  });
} catch (e) {
  // Show error
}
```

---

### 6. Add Navigation Routes (15 mins)

Add to `lib/app/routes/app_router.dart`:

```dart
@TypedGoRoute<Enable2FAQRRoute>(path: '/enable-2fa-qr')
class Enable2FAQRRoute extends GoRouteData {
  const Enable2FAQRRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const Enable2FAQRPage();
  }
}

@TypedGoRoute<Confirm2FARoute>(path: '/confirm-2fa')
class Confirm2FARoute extends GoRouteData {
  final String secret;

  const Confirm2FARoute({required this.secret});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Confirm2FAPage(secret: secret);
  }
}

@TypedGoRoute<RecoveryCodesRoute>(path: '/recovery-codes')
class RecoveryCodesRoute extends GoRouteData {
  final List<String> codes;

  const RecoveryCodesRoute({required this.codes});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return RecoveryCodesPage(codes: codes);
  }
}

@TypedGoRoute<Verify2FARoute>(path: '/verify-2fa')
class Verify2FARoute extends GoRouteData {
  final String email;
  final String password;

  const Verify2FARoute({required this.email, required this.password});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return Verify2FAPage(email: email, password: password);
  }
}
```

---

## 📝 Implementation Priority

### Must Complete (Core Functionality):
1. ✅ Use Cases - Required for business logic
2. ✅ Providers - Required for dependency injection
3. ✅ Verify 2FA Page - Required for login flow
4. ✅ Update Login Flow - Required for 2FA to work

### Should Complete (Full Feature):
5. ✅ QR Code Display Page - For enabling 2FA
6. ✅ Recovery Codes Page - For account recovery
7. ✅ Update Two Factor Auth Page - For managing 2FA

### Nice to Have (Polish):
8. ⬜ Confirm 2FA Page - Can be combined with QR page
9. ⬜ Add animations and better UX
10. ⬜ Add biometric authentication as alternative

---

## 🧪 Testing Checklist

### Backend Testing:
- ✅ Migration runs successfully
- ✅ All endpoints return correct responses
- ✅ QR code generation works
- ✅ Recovery codes are encrypted
- ✅ Login flow detects 2FA users

### Flutter Testing:
- ⬜ User model serialization with new fields
- ⬜ Database migration works
- ⬜ Enable 2FA flow end-to-end
- ⬜ Login with 2FA code works
- ⬜ Login with recovery code works
- ⬜ Disable 2FA works
- ⬜ Regenerate recovery codes works
- ⬜ Offline handling (graceful errors)

---

## 🔧 Troubleshooting

### Common Issues:

1. **Build Runner Errors**
   - Solution: Run `dart run build_runner clean && dart run build_runner build --delete-conflicting-outputs`

2. **QR Code Not Displaying**
   - Check SVG string is valid
   - Ensure `flutter_svg` is added to pubspec.yaml
   - Use `SvgPicture.string()` not `SvgPicture.network()`

3. **2FA Required Exception Not Caught**
   - Make sure you're catching `TwoFactorRequiredException` specifically
   - Check that login method properly throws this exception

4. **Recovery Codes Not Saving**
   - Verify backend encryption is working
   - Check that codes are properly decrypted when retrieved

---

## 📚 Additional Resources

### Backend Documentation:
- Full API docs: `D:\WORK\PROYECTOS\PHP\promoruta_backend\promoruta-backend\docs\TWO_FACTOR_AUTHENTICATION.md`

### Flutter Patterns:
- Follow existing auth pattern in `lib/features/auth/`
- Use Riverpod for state management
- Follow Clean Architecture layers

### Libraries Used:
- **Backend**: `pragmarx/google2fa-laravel`
- **Flutter**: `qr_flutter`, `flutter_svg`

---

## 🎯 Summary

**Backend:** ✅ 100% Complete
**Flutter Data Layer:** ✅ 100% Complete
**Flutter Use Cases/Providers:** ⬜ 0% Complete (next step)
**Flutter UI:** ⬜ 0% Complete (requires use cases first)
**Overall Progress:** 75% Complete

**Estimated Time to Complete:** 4-5 hours
- Use Cases & Providers: 45 mins
- UI Pages: 2-3 hours
- Login Flow Updates: 30 mins
- Testing & Polish: 1 hour

The foundation is solid! All the complex backend logic and data layer are done. Now it's just about building the UI components and wiring them up with the existing providers.
