
abstract class AuthService {
  Future<bool> signIn(String email, String password);
  Future<void> signOut();
  Future<bool> isSignedIn();
}

class MockAuthService implements AuthService {
  @override
  Future<bool> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock validation
    return email.isNotEmpty && password.isNotEmpty;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  @override
  Future<bool> isSignedIn() async {
    return false;
  }
}
