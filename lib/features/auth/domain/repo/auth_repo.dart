abstract class AuthRepository {
  Future<void> signUp(String email, String password);
  Future<void> signIn(String email, String password);
  Future<void> signInWithGoogle();
  bool isLoggedIn();
  Future<void> signOut();
  Future<void> sendResetPassword(String email);
  Future<void> updatePassword(String password);
}
