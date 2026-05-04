import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class AuthRemoteDataSource {
  final supabase = Supabase.instance.client;

  Future<User> signUp({required String email, required String password}) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception("User not created");
    }

    return user;
  }

  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'com.example.green://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  // ================= PHONE AUTH =================

  Future<void> sendOtp({required String phone}) async {
    await supabase.auth.signInWithOtp(
      phone: phone,
    );
  }

  Future<void> verifyOtp({
    required String phone,
    required String token,
  }) async {
    await supabase.auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: token,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.green://reset-callback',
    );
  }

  bool isLoggedIn() => supabase.auth.currentUser != null;

  User? getCurrentUser() => supabase.auth.currentUser;
}
