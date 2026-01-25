import 'package:flutter_test/flutter_test.dart';
import 'package:finding_out/features/auth/domain/entities/user.dart';
import 'package:finding_out/features/auth/domain/repositories/auth_repository.dart';
import 'package:finding_out/features/auth/domain/usecases/sign_out.dart';

// Mock manual del AuthRepository
class MockAuthRepository implements AuthRepository {
  bool signOutCalled = false;
  Exception? exceptionToThrow;

  @override
  Future<void> signOut() async {
    signOutCalled = true;

    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> signUp({required String email, required String password, String? displayName}) {
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
  group('SignOut', () {
    late SignOut signOut;
    late MockAuthRepository mockRepository;

    setUp(() {
      mockRepository = MockAuthRepository();
      signOut = SignOut(mockRepository);
    });

    test('debe llamar al método signOut del repositorio', () async {
      await signOut();

      expect(mockRepository.signOutCalled, isTrue);
    });

    test('debe completar sin errores cuando el logout es exitoso', () async {
      expect(() => signOut(), returnsNormally);
    });

    test('debe propagar la excepción cuando el logout falla', () async {
      mockRepository.exceptionToThrow = Exception('Error de red');

      expect(
        () => signOut(),
        throwsException,
      );
    });

    test('debe poder llamarse múltiples veces', () async {
      await signOut();
      expect(mockRepository.signOutCalled, isTrue);

      mockRepository.signOutCalled = false;
      await signOut();
      expect(mockRepository.signOutCalled, isTrue);
    });
  });
}
