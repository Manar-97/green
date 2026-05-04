abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> sendOtp(String phone);
  Future<void> verifyOtp(String phone, String token);
  Future<void> resetPassword(String email);
  bool isLoggedIn();
  Future<void> signOut();
}
