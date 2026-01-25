import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/auth/domain/entities/user.dart';
import 'package:finding_out/features/auth/domain/repositories/auth_repository.dart';
import 'package:finding_out/features/auth/domain/usecases/sign_up.dart';

// Mock manual del AuthRepository
class MockAuthRepository implements AuthRepository {
  AppUser? userToReturn;
  Exception? exceptionToThrow;
  String? lastEmail;
  String? lastPassword;
  String? lastDisplayName;

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    lastEmail = email;
    lastPassword = password;
    lastDisplayName = displayName;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return userToReturn!;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() {
    throw UnimplementedError();
  }

  @override
  Future<void> resetPassword(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> resendVerificationEmail(String email) {
    throw UnimplementedError();
  }

  @override
  Future<void> updatePassword(String newPassword) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateProfile({String? displayName, String? avatarUrl}) {
    throw UnimplementedError();
  }

  @override
  AppUser? getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Stream<AppUser?> get authStateChanges {
    throw UnimplementedError();
  }
}

void main() {
  group('SignUp', () {
    late SignUp signUp;
    late MockAuthRepository mockRepository;

    final testUser = AppUser(
      id: 'new-user-123',
      email: 'newuser@example.com',
      displayName: 'New User',
      createdAt: DateTime(2024, 1, 15),
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      signUp = SignUp(mockRepository);
    });

    test('debe llamar al repositorio con email, password y displayName', () async {
      mockRepository.userToReturn = testUser;

      await signUp(
        email: 'newuser@example.com',
        password: 'securePassword123',
        displayName: 'New User',
      );

      expect(mockRepository.lastEmail, 'newuser@example.com');
      expect(mockRepository.lastPassword, 'securePassword123');
      expect(mockRepository.lastDisplayName, 'New User');
    });

    test('debe permitir registro sin displayName', () async {
      mockRepository.userToReturn = testUser;

      await signUp(
        email: 'newuser@example.com',
        password: 'securePassword123',
      );

      expect(mockRepository.lastEmail, 'newuser@example.com');
      expect(mockRepository.lastDisplayName, isNull);
    });

    test('debe retornar el usuario cuando el registro es exitoso', () async {
      mockRepository.userToReturn = testUser;

      final result = await signUp(
        email: 'newuser@example.com',
        password: 'securePassword123',
        displayName: 'New User',
      );

      expect(result, testUser);
      expect(result.id, 'new-user-123');
      expect(result.email, 'newuser@example.com');
      expect(result.displayName, 'New User');
    });

    test('debe propagar la excepción cuando el registro falla', () async {
      mockRepository.exceptionToThrow = Exception('Email ya registrado');

      expect(
        () => signUp(
          email: 'existing@example.com',
          password: 'password123',
        ),
        throwsException,
      );
    });

    test('debe propagar excepción por password débil', () async {
      mockRepository.exceptionToThrow = Exception('Password muy débil');

      expect(
        () => signUp(
          email: 'newuser@example.com',
          password: '123',
        ),
        throwsException,
      );
    });
  });
}
