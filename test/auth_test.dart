import 'package:takemynotes/services/auth/auth_exceptions.dart';
import 'package:takemynotes/services/auth/auth_provider.dart';
import 'package:takemynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();

    test('Should not be initialized', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(provider.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to initialize', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test('Initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    if (email == 'foo@bar.com') {
      throw UserNotFoundAuthException();
    }
    if (password == 'foobar') {
      throw WrongPasswordAuthException();
    }

    const user =
        AuthUser(id: 'myid', isEmailVerified: false, email: 'foo@bar.com');
    _user = user;

    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    if (_user == null) {
      throw UserNotFoundAuthException();
    }

    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    }
    const newUser =
        AuthUser(id: 'my_id', isEmailVerified: true, email: 'foo@bar.com');
    _user = newUser;
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    if (!_isInitialized) {
      throw NotInitializedException();
    }
    throw UnimplementedError();
  }
}
