import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/error_mapper.dart';

@singleton
class AuthRemoteDataSource {
  final supabase = Supabase.instance.client;

  Future<User> signUp({required String email, required String password}) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        throw Exception("User not created");
      }

      return user;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'myapp://reset-password',
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  bool isLoggedIn() => supabase.auth.currentUser != null;

  User? getCurrentUser() => supabase.auth.currentUser;
}
