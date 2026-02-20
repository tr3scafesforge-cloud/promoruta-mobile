import 'package:dio/dio.dart';
import 'package:promoruta/core/core.dart';
import 'package:promoruta/core/utils/logger.dart';

import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/models/two_factor_models.dart';
import '../../models/registration_models.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final AuthLocalDataSource _localDataSource;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required AuthLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  String? _extractFirstErrorMessage(dynamic responseData) {
    if (responseData is Map && responseData.containsKey('errors')) {
      final errors = responseData['errors'] as Map?;
      if (errors != null && errors.isNotEmpty) {
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
    }
    return null;
  }

  bool _isNoAccountFoundMessage(String? message) {
    if (message == null) return false;
    return message.trim().toLowerCase() ==
        'no account found with this email.'.toLowerCase();
  }

  @override
  Future<User> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if 2FA is required
        if (data['requires_2fa'] == true) {
          // Throw special exception to indicate 2FA is required
          throw TwoFactorRequiredException(
            email: data['email'] as String,
            message: data['message'] as String,
          );
        }

        final userData = data['user'];
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = data['refresh_expires_in'] != null
            ? DateTime.now()
                .add(Duration(seconds: data['refresh_expires_in'] as int))
            : null;

        return User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerifiedAt:
              null, // API doesn't provide email_verified_at on login
          role: UserRole.fromString(userData['role']),
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : null,
          updatedAt: null, // API doesn't provide updated_at on login
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          refreshToken: data['refresh_token'],
          refreshExpiresIn: refreshExpiresIn,
          username: userData['name'],
          photoUrl: null, // API doesn't provide photoUrl
          twoFactorEnabled: userData['two_factor_enabled'] as bool? ?? false,
          twoFactorConfirmedAt: userData['two_factor_confirmed_at'] != null
              ? DateTime.parse(userData['two_factor_confirmed_at'])
              : null,
        );
      } else {
        throw Exception('Login failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Login failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 302:
            // Server redirects typically indicate invalid credentials
            throw Exception('invalidCredentials');
          case 401:
            throw Exception('invalidCredentials');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('invalidCredentials');
          case 429:
            throw Exception('tooManyLoginAttempts');
          default:
            throw Exception('loginFailed');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<User> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final user = await _localDataSource.getUser();
        if (user == null) throw Exception('No user logged in');
        final expiresIn = data['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = data['refresh_expires_in'] != null
            ? DateTime.now()
                .add(Duration(seconds: data['refresh_expires_in'] as int))
            : null;

        final refreshedUser = User(
          id: user.id,
          name: user.name,
          email: user.email,
          emailVerifiedAt: user.emailVerifiedAt,
          role: user.role,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          accessToken: data['access_token'],
          tokenExpiry: tokenExpiry,
          refreshToken: data['refresh_token'],
          refreshExpiresIn: refreshExpiresIn,
          username: user.username,
          photoUrl: user.photoUrl,
        );

        // Update local storage with new token
        await _localDataSource.saveUser(refreshedUser);

        return refreshedUser;
      } else {
        throw Exception('Token refresh failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword,
      String newPasswordConfirmation) async {
    try {
      await dio.post(
        '/auth/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPasswordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Change password failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      // Handle different error codes with user-friendly messages
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            // Handle validation errors
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception(
                'Invalid password format. Please check your input.');
          case 500:
            throw Exception('serverErrorPasswordChange');
          default:
            throw Exception(
                'Unable to change password. Please try again later.');
        }
      } else {
        // Network or other Dio errors
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<String> requestPasswordResetCode(String email) async {
    try {
      final response = await dio.post(
        '/auth/mobile/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['message'] ?? 'Password reset code sent to your email';
      } else if (response.statusCode == 422) {
        final data = response.data;
        final errorMessage = _extractFirstErrorMessage(data);
        if (_isNoAccountFoundMessage(errorMessage)) {
          throw Exception('noAccountFoundWithEmail');
        }
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Exception(errorMessage);
        }
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 429) {
        throw Exception('Too many requests. Please try again in a minute.');
      } else {
        throw Exception('An error occurred');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Request password reset failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            final errorMessage = _extractFirstErrorMessage(responseData);
            if (_isNoAccountFoundMessage(errorMessage)) {
              throw Exception('noAccountFoundWithEmail');
            }
            if (errorMessage != null && errorMessage.isNotEmpty) {
              throw Exception(errorMessage);
            }
            throw Exception('Invalid email format. Please check your input.');
          case 429:
            throw Exception('Too many requests. Please try again in a minute.');
          default:
            throw Exception(
                'Unable to request password reset. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<String> resetPasswordWithCode({
    required String email,
    required String code,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        '/auth/mobile/reset-password',
        data: {
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['message'] ?? 'Your password has been reset!';
      } else if (response.statusCode == 422) {
        final data = response.data;
        final errors = data['errors'] as Map?;
        if (errors != null && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          }
        }
        throw Exception(data['message'] ?? 'Validation error');
      } else if (response.statusCode == 429) {
        throw Exception('Too many attempts. Please try again later.');
      } else {
        throw Exception('An error occurred');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Reset password failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception(
                'Invalid code or password format. Please check your input.');
          case 429:
            throw Exception('Too many attempts. Please try again later.');
          default:
            throw Exception(
                'Unable to reset password. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  // Two-Factor Authentication methods

  @override
  Future<TwoFactorEnableResponse> enable2FA() async {
    try {
      final response = await dio.post(
        '/auth/2fa/enable',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return TwoFactorEnableResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to enable 2FA: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Enable 2FA failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw Exception('Unauthorized. Please log in again.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Validation error. Please try again.');
          default:
            throw Exception('Unable to enable 2FA. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<TwoFactorConfirmResponse> confirm2FA(
      String secret, String code) async {
    try {
      final response = await dio.post(
        '/auth/2fa/confirm',
        data: {
          'secret': secret,
          'code': code,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update local user to reflect 2FA is now enabled
        final user = await _localDataSource.getUser();
        if (user != null) {
          final updatedUser = user.copyWith(
            twoFactorEnabled: true,
            twoFactorConfirmedAt: DateTime.now(),
          );
          await _localDataSource.saveUser(updatedUser);
        }

        return TwoFactorConfirmResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to confirm 2FA: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Confirm 2FA failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw Exception('Unauthorized. Please log in again.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid verification code. Please try again.');
          default:
            throw Exception('Unable to confirm 2FA. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<String> disable2FA(String password) async {
    try {
      final response = await dio.post(
        '/auth/2fa/disable',
        data: {'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Update local user to reflect 2FA is now disabled
        final user = await _localDataSource.getUser();
        if (user != null) {
          final updatedUser = user.copyWith(
            twoFactorEnabled: false,
            twoFactorConfirmedAt: null,
          );
          await _localDataSource.saveUser(updatedUser);
        }

        final data = response.data;
        return data['message'] ??
            'Two-factor authentication has been disabled.';
      } else {
        throw Exception('Failed to disable 2FA: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Disable 2FA failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 401:
            throw Exception('Unauthorized. Please log in again.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid password. Please try again.');
          default:
            throw Exception('Unable to disable 2FA. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<User> verify2FACode({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'email': email,
        'password': password,
      };

      if (code != null) {
        data['code'] = code;
      } else if (recoveryCode != null) {
        data['recovery_code'] = recoveryCode;
      } else {
        throw Exception('Either code or recovery code must be provided');
      }

      final response = await dio.post(
        '/auth/2fa/verify',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        final userData = responseData['user'];
        final expiresIn = responseData['expires_in'] as int;
        final tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
        final refreshExpiresIn = responseData['refresh_expires_in'] != null
            ? DateTime.now().add(
                Duration(seconds: responseData['refresh_expires_in'] as int))
            : null;

        return User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          emailVerifiedAt: userData['email_verified_at'] != null
              ? DateTime.parse(userData['email_verified_at'])
              : null,
          role: UserRole.fromString(userData['role']),
          createdAt: userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : null,
          updatedAt: userData['updated_at'] != null
              ? DateTime.parse(userData['updated_at'])
              : null,
          accessToken: responseData['access_token'],
          tokenExpiry: tokenExpiry,
          refreshToken: responseData['refresh_token'],
          refreshExpiresIn: refreshExpiresIn,
          username: userData['name'],
          photoUrl: null,
          twoFactorEnabled: true, // User has 2FA enabled if they got here
          twoFactorConfirmedAt: userData['two_factor_confirmed_at'] != null
              ? DateTime.parse(userData['two_factor_confirmed_at'])
              : null,
        );
      } else {
        throw Exception('2FA verification failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Verify 2FA code failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 403:
            throw Exception(
                'Email not verified. Please verify your email first.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception(
                'Invalid verification code or credentials. Please try again.');
          case 429:
            throw Exception('Too many attempts. Please try again later.');
          default:
            throw Exception(
                'Unable to verify 2FA code. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<RecoveryCodesResponse> getRecoveryCodes() async {
    try {
      final response = await dio.get(
        '/auth/2fa/recovery-codes',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return RecoveryCodesResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to get recovery codes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Get recovery codes failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;

        switch (statusCode) {
          case 400:
            throw Exception(
                'Two-factor authentication is not enabled for your account.');
          case 401:
            throw Exception('Unauthorized. Please log in again.');
          default:
            throw Exception(
                'Unable to retrieve recovery codes. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<RecoveryCodesResponse> regenerateRecoveryCodes(String password) async {
    try {
      final response = await dio.post(
        '/auth/2fa/recovery-codes/regenerate',
        data: {'password': password},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return RecoveryCodesResponse.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to regenerate recovery codes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Regenerate recovery codes failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            throw Exception(
                'Two-factor authentication is not enabled for your account.');
          case 401:
            throw Exception('Unauthorized. Please log in again.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid password. Please try again.');
          default:
            throw Exception(
                'Unable to regenerate recovery codes. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  // Registration methods

  @override
  Future<RegistrationResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RegistrationResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Registration failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                // Check for email already taken error
                if (errors.containsKey('email')) {
                  final emailErrors = errors['email'];
                  if (emailErrors is List && emailErrors.isNotEmpty) {
                    throw Exception(emailErrors.first.toString());
                  }
                }
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception(
                'Invalid registration data. Please check your input.');
          case 429:
            throw Exception('Too many attempts. Please try again later.');
          default:
            throw Exception('Unable to register. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<VerifyEmailResponse> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        '/auth/verify-email-code',
        data: {
          'email': email,
          'code': code,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return VerifyEmailResponse.fromJson(response.data);
      } else {
        throw Exception('Email verification failed: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Email verification failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 400:
            throw Exception('Invalid or expired verification code.');
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            if (responseData is Map && responseData.containsKey('message')) {
              throw Exception(responseData['message'] as String);
            }
            throw Exception('Invalid verification code. Please try again.');
          case 429:
            throw Exception('Too many attempts. Please try again later.');
          default:
            throw Exception('Unable to verify email. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }

  @override
  Future<String> resendVerificationCode(String email) async {
    try {
      final response = await dio.post(
        '/auth/email/verification-notification',
        data: {'email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['message'] ?? 'Verification code sent';
      } else {
        throw Exception('Failed to resend code: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.auth.e(
          'Resend verification code failed: ${e.response?.statusCode} - ${e.response?.data} - ${e.message}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        switch (statusCode) {
          case 422:
            if (responseData is Map && responseData.containsKey('errors')) {
              final errors = responseData['errors'] as Map?;
              if (errors != null && errors.isNotEmpty) {
                final firstError = errors.values.first;
                if (firstError is List && firstError.isNotEmpty) {
                  throw Exception(firstError.first.toString());
                }
              }
            }
            throw Exception('Invalid email. Please check your input.');
          case 429:
            throw Exception(
                'Too many requests. Please wait before requesting a new code.');
          default:
            throw Exception('Unable to resend code. Please try again later.');
        }
      } else {
        throw Exception(
            'Network error. Please check your connection and try again.');
      }
    }
  }
}
