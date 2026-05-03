import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/network_guard.dart';
import '../../domain/usecases/check_auth.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final ResetPasswordUseCase resetPassword;
  final CheckAuthUseCase checkAuth;
  final SignOutUseCase signOut;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.resetPassword,
    required this.checkAuth,
  }) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    if (!await NetworkGuard.hasInternet()) {
      emit(AuthError(message: "❌ مفيش إنترنت", type: ErrorType.network));
      return;
    }

    try {
      await signIn(email, password);

      final user = supabase.Supabase.instance.client.auth.currentUser;
      if (user == null) {
        emit(AuthError(message: "User not found", type: ErrorType.server));
        return;
      }

      final profile = await supabase.Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = profile?['role']?.toString().toLowerCase();

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());

    if (!await NetworkGuard.hasInternet()) {
      emit(AuthError(message: "❌ مفيش إنترنت", type: ErrorType.network));
      return;
    }

    try {
      await signUp(email, password);
      emit(AuthSuccess());
    } catch (e) {
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());

    try {
      await resetPassword(email);
      emit(AuthPasswordSent());
    } catch (e) {
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  void checkLogin() async {
    try {
      if (!checkAuth()) {
        emit(AuthLoggedOut());
        return;
      }

      final user = supabase.Supabase.instance.client.auth.currentUser;

      final profile = await supabase.Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user!.id)
          .single();

      final role = profile['role'];

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (_) {
      emit(AuthLoggedOut());
    }
  }

  Future<void> logout() async {
    await signOut();
    emit(AuthInitial());
  }
}
