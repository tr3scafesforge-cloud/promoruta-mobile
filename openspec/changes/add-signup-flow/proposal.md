# Proposal: Add Sign-Up Flow

## Change ID
`add-signup-flow`

## Summary
Implement user registration functionality allowing new users to create accounts with email/password, select their role (promoter or advertiser), and verify their email before accessing the app.

## Motivation
Currently, the app only supports login for existing users. New users have no way to create accounts through the mobile app, requiring manual backend account creation. This blocks organic user acquisition and self-service onboarding.

## Scope

### In Scope
- Registration form with name, email, password, and role selection
- Email verification flow (code-based)
- Integration with existing backend registration endpoint
- Navigation from login page to sign-up and back
- Form validation matching backend requirements
- Localization for EN, ES, PT languages
- Error handling for duplicate emails, weak passwords, etc.

### Out of Scope
- Social login (Google, Apple, Facebook) - future enhancement
- Phone number collection
- Profile photo upload during registration
- Terms of service acceptance UI (may add if backend requires)
- Admin registration

## Requirements Summary

### User Registration
- REQ-1: User can access sign-up from login page
- REQ-2: User provides name, email, password, and selects role
- REQ-3: Password confirmation field with matching validation
- REQ-4: Form validates inputs before submission
- REQ-5: Handles duplicate email error gracefully

### Email Verification
- REQ-6: After registration, user is directed to email verification screen
- REQ-7: User enters verification code sent to their email
- REQ-8: User can request code resend
- REQ-9: Successful verification logs user in and navigates to role-specific home

## Technical Approach

### Architecture
Follows existing feature-first clean architecture:
```
lib/features/auth/
├── data/
│   ├── datasources/remote/  # Add register, verify endpoints
│   └── repositories/        # Add registration methods
├── domain/
│   ├── models/             # Registration request/response models
│   ├── repositories/       # Add repository interface methods
│   └── use_cases/          # RegisterUseCase, VerifyEmailUseCase
└── presentation/
    ├── pages/              # SignUpPage, EmailVerificationPage
    ├── widgets/            # Reusable form components
    └── providers/          # Registration state management
```

### API Integration
Backend endpoints (assumed based on Laravel conventions):
- `POST /auth/register` - Create account
- `POST /auth/email/verify` - Verify email with code
- `POST /auth/email/resend` - Resend verification code

### Routes
- `/sign-up` - Registration form
- `/verify-email` - Email verification screen

### State Management
- New `registrationProvider` for form state and submission
- New `emailVerificationProvider` for verification flow
- Integration with existing `authStateProvider` post-verification

## Dependencies
- Backend registration endpoint must be functional
- Email service must be configured on backend
- No new Flutter packages required

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Backend endpoint contract mismatch | Verify endpoint schema before implementation |
| Email delivery delays | Add resend option, clear user messaging |
| Verification code expiry | Handle expiry error, allow resend |

## Affected Specs
- `specs/user-registration/spec.md` (NEW)

## Related Changes
- None (standalone feature)

## Acceptance Criteria
1. User can successfully create a new account
2. User receives and can enter verification code
3. User can resend verification code
4. Verified user is logged in and navigated to role-specific home
5. All screens localized in EN, ES, PT
6. Form validation prevents invalid submissions
7. Error states are clearly communicated
