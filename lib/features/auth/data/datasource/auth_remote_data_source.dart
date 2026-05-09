import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supaBase;

@singleton
class AuthRemoteDataSource {
  final supabase = supaBase.Supabase.instance.client;

  Future<supaBase.User> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (response.session == null && user == null) {
        throw Exception("Signup failed");
      }

      return user!;
    } on supaBase.AuthException catch (e) {
      throw e;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      supaBase.OAuthProvider.google,
      redirectTo: 'com.example.green://login-callback',
      authScreenLaunchMode: supaBase.LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> sendResetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.green://reset-callback',
    );
  }

  Future<void> updatePassword(String password) async {
    final res = await supabase.auth.updateUser(
      supaBase.UserAttributes(password: password),
    );

    if (res.user == null) {
      throw Exception("Password update failed");
    }
  }

  bool isLoggedIn() => supabase.auth.currentUser != null;

  supaBase.User? getCurrentUser() => supabase.auth.currentUser;
}
