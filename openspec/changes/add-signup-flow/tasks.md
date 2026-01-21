# Tasks: Add Sign-Up Flow

## Overview
Implementation tasks for user registration and email verification features.

---

## Phase 1: Data Layer

### Task 1.1: Add registration models
**File:** `lib/features/auth/data/models/registration_models.dart`
- [ ] Create `RegistrationRequest` model (name, email, password, password_confirmation, role)
- [ ] Create `RegistrationResponse` model (user, message, requires_verification)
- [ ] Create `VerifyEmailRequest` model (email, code)
- [ ] Create `VerifyEmailResponse` model (user, access_token, refresh_token)
- [ ] Create `ResendVerificationRequest` model (email)

**Validation:** Models compile and serialize/deserialize correctly

---

### Task 1.2: Add registration endpoints to remote data source
**File:** `lib/features/auth/data/datasources/remote/auth_remote_data_source.dart`
- [ ] Add `register(RegistrationRequest)` method → POST `/auth/register`
- [ ] Add `verifyEmail(VerifyEmailRequest)` method → POST `/auth/email/verify`
- [ ] Add `resendVerificationCode(String email)` method → POST `/auth/email/resend`

**Validation:** Endpoints can be called (test with backend)

**Dependencies:** Backend endpoints must be available

---

### Task 1.3: Add registration methods to repository
**Files:**
- `lib/features/auth/domain/repositories/auth_repository.dart` (interface)
- `lib/features/auth/data/repositories/auth_repository_impl.dart` (implementation)

- [ ] Add `register(...)` method signature to interface
- [ ] Add `verifyEmail(...)` method signature to interface
- [ ] Add `resendVerificationCode(...)` method signature to interface
- [ ] Implement methods in `AuthRepositoryImpl`

**Validation:** Repository methods call data source correctly

---

## Phase 2: Domain Layer

### Task 2.1: Create registration use cases
**File:** `lib/features/auth/domain/use_cases/registration_use_cases.dart`
- [ ] Create `RegisterUseCase` with input validation
- [ ] Create `VerifyEmailUseCase`
- [ ] Create `ResendVerificationCodeUseCase`

**Validation:** Use cases handle success and error cases

---

### Task 2.2: Add providers for registration
**File:** `lib/shared/providers/providers.dart` or feature-specific provider file
- [ ] Add `registerUseCaseProvider`
- [ ] Add `verifyEmailUseCaseProvider`
- [ ] Add `resendVerificationCodeUseCaseProvider`

**Validation:** Providers are accessible in widgets

---

## Phase 3: Routing

### Task 3.1: Add sign-up and verification routes
**File:** `lib/app/routes/app_router.dart`
- [ ] Add `SignUpRoute` at `/sign-up`
- [ ] Add `VerifyEmailRoute` at `/verify-email` (accepts email parameter)
- [ ] Run code generation: `flutter pub run build_runner build -d`

**Validation:** Routes are navigable, generated files compile

---

## Phase 4: Localization

### Task 4.1: Add localization strings
**Files:**
- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_pt.arb`

- [ ] Add sign-up page strings (title, labels, buttons, hints)
- [ ] Add email verification page strings
- [ ] Add validation error messages
- [ ] Add success/error notification messages
- [ ] Run: `flutter gen-l10n`

**Validation:** All strings appear correctly in all languages

---

## Phase 5: Presentation Layer

### Task 5.1: Create sign-up page
**File:** `lib/features/auth/presentation/pages/sign_up_page.dart`
- [ ] Create `SignUpPage` widget
- [ ] Add form with name, email, password, confirm password fields
- [ ] Add role selection (promoter/advertiser toggle/chips)
- [ ] Add password visibility toggle
- [ ] Add form validation
- [ ] Add "Sign Up" button with loading state
- [ ] Add "Already have an account? Log in" link
- [ ] Connect to registration use case
- [ ] Handle success → navigate to verify email
- [ ] Handle errors → show toast/snackbar

**Validation:** Form submits and navigates correctly

---

### Task 5.2: Create email verification page
**File:** `lib/features/auth/presentation/pages/verify_email_page.dart`
- [ ] Create `VerifyEmailPage` widget
- [ ] Add verification code input (6 digits)
- [ ] Add "Verify" button with loading state
- [ ] Add "Resend code" link with cooldown timer
- [ ] Connect to verify/resend use cases
- [ ] Handle success → save user, navigate to home
- [ ] Handle errors → show appropriate message

**Validation:** Verification flow completes successfully

---

### Task 5.3: Update login page with sign-up navigation
**File:** `lib/features/auth/presentation/pages/login_page.dart`
- [ ] Replace TODO comment with actual navigation to SignUpRoute
- [ ] Ensure role is passed if selected on login page

**Validation:** Login page links to sign-up correctly

---

## Phase 6: Testing & Polish

### Task 6.1: Manual testing checklist
- [ ] Test registration with valid data
- [ ] Test all validation error cases
- [ ] Test duplicate email error
- [ ] Test network error handling
- [ ] Test verification code entry
- [ ] Test invalid code error
- [ ] Test resend code functionality
- [ ] Test resend cooldown timer
- [ ] Test in English, Spanish, Portuguese
- [ ] Test on Android
- [ ] Test on iOS

---

### Task 6.2: Unit tests (optional, recommended)
**Files:** `test/features/auth/...`
- [ ] Test `RegisterUseCase` with mock repository
- [ ] Test `VerifyEmailUseCase` with mock repository
- [ ] Test form validation logic

---

## Dependencies Graph

```
Phase 1 (Data) → Phase 2 (Domain) → Phase 3 (Routing)
                                         ↓
Phase 4 (Localization) ←────────→ Phase 5 (Presentation)
                                         ↓
                                  Phase 6 (Testing)
```

**Parallelizable:**
- Phase 4 (Localization) can run in parallel with Phase 3 (Routing)
- Task 5.1 and 5.2 can be developed in parallel once routing is ready

---

## Estimated Work Items
- **Data Layer:** 3 tasks
- **Domain Layer:** 2 tasks
- **Routing:** 1 task
- **Localization:** 1 task
- **Presentation:** 3 tasks
- **Testing:** 2 tasks

**Total:** 12 tasks
