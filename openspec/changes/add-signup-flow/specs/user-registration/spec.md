# Capability: User Registration

## Overview
Enable new users to create accounts and verify their email address before accessing the Promoruta platform.

---

## ADDED Requirements

### Requirement: Sign-Up Access
The app SHALL provide navigation from the login page to the sign-up page and back.

#### Scenario: User taps sign-up link on login page
**Given** the user is on the login page
**When** the user taps "Don't have an account? Sign up"
**Then** the app navigates to the sign-up page

#### Scenario: User returns to login from sign-up
**Given** the user is on the sign-up page
**When** the user taps "Already have an account? Log in"
**Then** the app navigates back to the login page

---

### Requirement: Registration Form
The app SHALL display a registration form with required fields for name, email, password, password confirmation, and role selection.

#### Scenario: User views registration form
**Given** the user is on the sign-up page
**Then** the user sees input fields for:
- Full name
- Email address
- Password
- Confirm password
- Role selection (Promoter / Advertiser)

#### Scenario: User selects promoter role
**Given** the user is on the sign-up page
**When** the user selects "Promoter" role
**Then** the promoter option is visually selected
**And** advertiser option is deselected

#### Scenario: User selects advertiser role
**Given** the user is on the sign-up page
**When** the user selects "Advertiser" role
**Then** the advertiser option is visually selected
**And** promoter option is deselected

---

### Requirement: Form Validation
The app SHALL validate all registration form inputs before submission and display appropriate error messages.

#### Scenario: Empty name validation
**Given** the user is on the sign-up page
**When** the user leaves the name field empty
**And** attempts to submit the form
**Then** an error message "Name is required" is displayed

#### Scenario: Invalid email validation
**Given** the user is on the sign-up page
**When** the user enters an invalid email format
**And** attempts to submit the form
**Then** an error message "Enter a valid email address" is displayed

#### Scenario: Password too short validation
**Given** the user is on the sign-up page
**When** the user enters a password shorter than 8 characters
**And** attempts to submit the form
**Then** an error message "Password must be at least 8 characters" is displayed

#### Scenario: Password mismatch validation
**Given** the user is on the sign-up page
**When** the user enters different values in password and confirm password fields
**And** attempts to submit the form
**Then** an error message "Passwords do not match" is displayed

#### Scenario: No role selected validation
**Given** the user is on the sign-up page
**When** the user does not select a role
**And** attempts to submit the form
**Then** an error message "Please select a role" is displayed

---

### Requirement: Account Creation
The app SHALL submit valid registration data to the backend and handle success and error responses appropriately.

#### Scenario: Successful registration
**Given** the user has filled all fields correctly
**When** the user taps the "Sign Up" button
**Then** a loading indicator is displayed
**And** the account is created on the server
**And** the user is navigated to the email verification page

#### Scenario: Duplicate email error
**Given** the user enters an email that already exists
**When** the user taps the "Sign Up" button
**Then** an error message "This email is already registered" is displayed
**And** the user remains on the sign-up page

#### Scenario: Network error during registration
**Given** the device has no network connectivity
**When** the user taps the "Sign Up" button
**Then** an error message indicating network issue is displayed
**And** the user can retry submission

---

### Requirement: Email Verification
The app SHALL require users to verify their email address via a code before granting access to the platform.

#### Scenario: User views verification page
**Given** the user has just registered
**Then** the user sees the email verification page with:
- Message indicating a code was sent to their email
- Input field for verification code
- "Verify" button
- "Resend code" link

#### Scenario: Successful email verification
**Given** the user is on the email verification page
**When** the user enters the correct verification code
**And** taps the "Verify" button
**Then** the email is verified
**And** the user is logged in
**And** the user is navigated to their role-specific home page

#### Scenario: Invalid verification code
**Given** the user is on the email verification page
**When** the user enters an incorrect verification code
**And** taps the "Verify" button
**Then** an error message "Invalid verification code" is displayed
**And** the user can retry

#### Scenario: Expired verification code
**Given** the user is on the email verification page
**When** the user enters an expired verification code
**And** taps the "Verify" button
**Then** an error message "Code has expired. Please request a new one" is displayed

#### Scenario: Resend verification code
**Given** the user is on the email verification page
**When** the user taps "Resend code"
**Then** a new verification code is sent to the user's email
**And** a success message "Verification code sent" is displayed

#### Scenario: Resend cooldown
**Given** the user has requested a code resend
**When** the user tries to resend again within 60 seconds
**Then** the resend button is disabled
**And** a countdown timer is displayed

---

### Requirement: Localization
The app SHALL provide all registration UI text in English, Spanish, and Portuguese.

#### Scenario: Sign-up page in Spanish
**Given** the app language is set to Spanish
**When** the user views the sign-up page
**Then** all labels, buttons, and error messages are in Spanish

#### Scenario: Sign-up page in Portuguese
**Given** the app language is set to Portuguese
**When** the user views the sign-up page
**Then** all labels, buttons, and error messages are in Portuguese

#### Scenario: Sign-up page in English
**Given** the app language is set to English
**When** the user views the sign-up page
**Then** all labels, buttons, and error messages are in English

---

## Cross-References
- Login flow: `lib/features/auth/presentation/pages/login_page.dart`
- Auth repository: `lib/features/auth/domain/repositories/auth_repository.dart`
- User model: `lib/core/models/user.dart`
- Routes: `lib/app/routes/app_router.dart`
