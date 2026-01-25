import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:promoruta/core/models/user.dart';
import 'package:promoruta/features/auth/data/models/registration_models.dart';
import 'package:promoruta/features/auth/domain/repositories/auth_repository.dart';
import 'package:promoruta/features/auth/domain/use_cases/registration_use_cases.dart';

// Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('RegisterUseCase', () {
    late RegisterUseCase useCase;

    setUp(() {
      useCase = RegisterUseCase(mockRepository);
    });

    group('validation', () {
      test('should throw exception when name is empty', () async {
        expect(
          () => useCase.call(
            name: '',
            email: 'test@example.com',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Name is required'),
          )),
        );

        verifyNever(() => mockRepository.register(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              passwordConfirmation: any(named: 'passwordConfirmation'),
              role: any(named: 'role'),
            ));
      });

      test('should throw exception when name is only whitespace', () async {
        expect(
          () => useCase.call(
            name: '   ',
            email: 'test@example.com',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Name is required'),
          )),
        );
      });

      test('should throw exception when email is empty', () async {
        expect(
          () => useCase.call(
            name: 'John Doe',
            email: '',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email is required'),
          )),
        );
      });

      test('should throw exception when email is invalid', () async {
        expect(
          () => useCase.call(
            name: 'John Doe',
            email: 'invalid-email',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Enter a valid email address'),
          )),
        );
      });

      test('should throw exception when email lacks domain', () async {
        expect(
          () => useCase.call(
            name: 'John Doe',
            email: 'test@',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Enter a valid email address'),
          )),
        );
      });

      test('should throw exception when password is less than 8 characters',
          () async {
        expect(
          () => useCase.call(
            name: 'John Doe',
            email: 'test@example.com',
            password: 'pass',
            passwordConfirmation: 'pass',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Password must be at least 8 characters'),
          )),
        );
      });

      test('should throw exception when passwords do not match', () async {
        expect(
          () => useCase.call(
            name: 'John Doe',
            email: 'test@example.com',
            password: 'password123',
            passwordConfirmation: 'differentpassword',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Passwords do not match'),
          )),
        );
      });
    });

    group('repository interaction', () {
      test('should call repository with trimmed name and lowercase email on success',
          () async {
        const response = RegistrationResponse(
          message: 'Registration successful',
          requiresVerification: true,
          email: 'test@example.com',
        );

        when(() => mockRepository.register(
              name: 'John Doe',
              email: 'test@example.com',
              password: 'password123',
              passwordConfirmation: 'password123',
              role: 'promotor',
            )).thenAnswer((_) async => response);

        final result = await useCase.call(
          name: '  John Doe  ',
          email: 'TEST@EXAMPLE.COM',
          password: 'password123',
          passwordConfirmation: 'password123',
          role: UserRole.promoter,
        );

        expect(result, equals(response));
        expect(result.requiresVerification, isTrue);

        verify(() => mockRepository.register(
              name: 'John Doe',
              email: 'test@example.com',
              password: 'password123',
              passwordConfirmation: 'password123',
              role: 'promotor',
            )).called(1);
      });

      test('should propagate repository exceptions', () async {
        when(() => mockRepository.register(
              name: any(named: 'name'),
              email: any(named: 'email'),
              password: any(named: 'password'),
              passwordConfirmation: any(named: 'passwordConfirmation'),
              role: any(named: 'role'),
            )).thenThrow(Exception('Email already taken'));

        expect(
          () => useCase.call(
            name: 'John Doe',
            email: 'test@example.com',
            password: 'password123',
            passwordConfirmation: 'password123',
            role: UserRole.promoter,
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email already taken'),
          )),
        );
      });

      test('should work with advertiser role', () async {
        const response = RegistrationResponse(
          message: 'Registration successful',
          requiresVerification: true,
        );

        when(() => mockRepository.register(
              name: 'Jane Doe',
              email: 'jane@example.com',
              password: 'password123',
              passwordConfirmation: 'password123',
              role: 'advertiser',
            )).thenAnswer((_) async => response);

        final result = await useCase.call(
          name: 'Jane Doe',
          email: 'jane@example.com',
          password: 'password123',
          passwordConfirmation: 'password123',
          role: UserRole.advertiser,
        );

        expect(result, equals(response));

        verify(() => mockRepository.register(
              name: 'Jane Doe',
              email: 'jane@example.com',
              password: 'password123',
              passwordConfirmation: 'password123',
              role: 'advertiser',
            )).called(1);
      });
    });
  });

  group('VerifyEmailUseCase', () {
    late VerifyEmailUseCase useCase;

    setUp(() {
      useCase = VerifyEmailUseCase(mockRepository);
    });

    group('validation', () {
      test('should throw exception when email is empty', () async {
        expect(
          () => useCase.call(email: '', code: '123456'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email is required'),
          )),
        );

        verifyNever(() => mockRepository.verifyEmail(
              email: any(named: 'email'),
              code: any(named: 'code'),
            ));
      });

      test('should throw exception when email is only whitespace', () async {
        expect(
          () => useCase.call(email: '   ', code: '123456'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email is required'),
          )),
        );
      });

      test('should throw exception when code is empty', () async {
        expect(
          () => useCase.call(email: 'test@example.com', code: ''),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Verification code is required'),
          )),
        );
      });

      test('should throw exception when code is only whitespace', () async {
        expect(
          () => useCase.call(email: 'test@example.com', code: '   '),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Verification code is required'),
          )),
        );
      });
    });

    group('repository interaction', () {
      test('should call repository with lowercase email and trimmed code',
          () async {
        final user = User(
          id: '1',
          name: 'John Doe',
          email: 'test@example.com',
          role: UserRole.promoter,
          emailVerifiedAt: DateTime.now(),
        );

        when(() => mockRepository.verifyEmail(
              email: 'test@example.com',
              code: '123456',
            )).thenAnswer((_) async => user);

        final result = await useCase.call(
          email: 'TEST@EXAMPLE.COM',
          code: '  123456  ',
        );

        expect(result, equals(user));
        expect(result.email, equals('test@example.com'));

        verify(() => mockRepository.verifyEmail(
              email: 'test@example.com',
              code: '123456',
            )).called(1);
      });

      test('should propagate repository exceptions', () async {
        when(() => mockRepository.verifyEmail(
              email: any(named: 'email'),
              code: any(named: 'code'),
            )).thenThrow(Exception('Invalid verification code'));

        expect(
          () => useCase.call(email: 'test@example.com', code: '000000'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid verification code'),
          )),
        );
      });

      test('should propagate expired code exception', () async {
        when(() => mockRepository.verifyEmail(
              email: any(named: 'email'),
              code: any(named: 'code'),
            )).thenThrow(Exception('Verification code has expired'));

        expect(
          () => useCase.call(email: 'test@example.com', code: '123456'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Verification code has expired'),
          )),
        );
      });
    });
  });

  group('ResendVerificationCodeUseCase', () {
    late ResendVerificationCodeUseCase useCase;

    setUp(() {
      useCase = ResendVerificationCodeUseCase(mockRepository);
    });

    group('validation', () {
      test('should throw exception when email is empty', () async {
        expect(
          () => useCase.call(''),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email is required'),
          )),
        );

        verifyNever(
            () => mockRepository.resendVerificationCode(any()));
      });

      test('should throw exception when email is only whitespace', () async {
        expect(
          () => useCase.call('   '),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Email is required'),
          )),
        );
      });
    });

    group('repository interaction', () {
      test('should call repository with lowercase email', () async {
        when(() => mockRepository.resendVerificationCode('test@example.com'))
            .thenAnswer((_) async => 'Verification code sent');

        final result = await useCase.call('TEST@EXAMPLE.COM');

        expect(result, equals('Verification code sent'));

        verify(() => mockRepository.resendVerificationCode('test@example.com'))
            .called(1);
      });

      test('should propagate repository exceptions', () async {
        when(() => mockRepository.resendVerificationCode(any()))
            .thenThrow(Exception('Too many requests. Please try again later.'));

        expect(
          () => useCase.call('test@example.com'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Too many requests'),
          )),
        );
      });
    });
  });
}
