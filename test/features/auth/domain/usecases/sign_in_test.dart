import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/auth/domain/entities/user.dart';
import 'package:finding_out/features/auth/domain/repositories/auth_repository.dart';
import 'package:finding_out/features/auth/domain/usecases/sign_in.dart';

// Mock manual del AuthRepository
class MockAuthRepository implements AuthRepository {
  AppUser? userToReturn;
  Exception? exceptionToThrow;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    lastEmail = email;
    lastPassword = password;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return userToReturn!;
  }

  @override
  Future<AppUser> signUp({required String email, required String password, String? displayName}) {
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
  Future<void> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithApple() {
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
  group('SignIn', () {
    late SignIn signIn;
    late MockAuthRepository mockRepository;

    final testUser = AppUser(
      id: 'user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      createdAt: DateTime(2024, 1, 1),
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      signIn = SignIn(mockRepository);
    });

    test('debe llamar al repositorio con email y password correctos', () async {
      mockRepository.userToReturn = testUser;

      await signIn(email: 'test@example.com', password: 'password123');

      expect(mockRepository.lastEmail, 'test@example.com');
      expect(mockRepository.lastPassword, 'password123');
    });

    test('debe retornar el usuario cuando el login es exitoso', () async {
      mockRepository.userToReturn = testUser;

      final result = await signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, testUser);
      expect(result.id, 'user-123');
      expect(result.email, 'test@example.com');
    });

    test('debe propagar la excepción cuando el login falla', () async {
      mockRepository.exceptionToThrow = Exception('Credenciales inválidas');

      expect(
        () => signIn(email: 'test@example.com', password: 'wrongpassword'),
        throwsException,
      );
    });

    test('debe manejar emails con diferentes formatos', () async {
      mockRepository.userToReturn = testUser;

      await signIn(email: 'USER@EXAMPLE.COM', password: 'password123');
      expect(mockRepository.lastEmail, 'USER@EXAMPLE.COM');

      await signIn(email: 'user.name+tag@example.com', password: 'password123');
      expect(mockRepository.lastEmail, 'user.name+tag@example.com');
    });
  });
}
