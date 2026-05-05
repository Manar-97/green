import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/check_auth.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignInWithGoogleUseCase signInWithGoogle;
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
    required this.signInWithGoogle,
  }) : super(AuthInitial());

  final _client = supabase.Supabase.instance.client;

  StreamSubscription? _authSub;
  AuthState? _lastState;
  DateTime? _lastResetRequest;
  bool isDeepLinkFlow = false;

  // ================= ROLE =================
  Future<String> _getRole(String userId) async {
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    return profile?['role']?.toString().toLowerCase() ?? 'user';
  }

  // ================= AUTH LISTENER =================
  void listenToAuthChanges() {
    _authSub?.cancel();
    _authSub = _client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      if (session == null) {
        emit(AuthLoggedOut());
        return;
      }
      if (isDeepLinkFlow) return; // 🔥 مهم جدًا

      final user = session.user;

      try {
        final role = await _getRole(user.id);

        if (role == 'admin') {
          if (_lastState is AuthLoggedInAdmin) return;
          _lastState = AuthLoggedInAdmin();
          emit(AuthLoggedInAdmin());
        } else {
          if (_lastState is AuthLoggedInUser) return;
          _lastState = AuthLoggedInUser();
          emit(AuthLoggedInUser());
        }
      } catch (e) {
        emit(AuthError(message: e.toString(), type: ErrorType.auth));
      }
    });
  }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      await signIn(email, password);

      final user = _client.auth.currentUser;
      if (user == null) {
        emit(AuthError(message: "User not found", type: ErrorType.auth));
        return;
      }

      final role = await _getRole(user.id);
      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());

    try {
      await signInWithGoogle();

      // ❗ استنى الـ session يتحدث بدل currentUser
      final completer = Completer();

      final sub = _client.auth.onAuthStateChange.listen((data) async {
        final session = data.session;

        if (session == null) return;

        final user = session.user;

        if (!completer.isCompleted) {
          completer.complete(user);
        }
      });

      final user = await completer.future;
      await sub.cancel();

      // check profile
      final profile = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        await _client.from('profiles').insert({'id': user.id, 'role': 'user'});
      }

      final updated = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = updated?['role'] ?? 'user';

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      emit(AuthError(message: e.toString(), type: ErrorType.auth));
    }
  }

  // ================= REGISTER =================
  Future<void> register(String email, String password) async {
    emit(AuthLoading());

    try {
      await signUp(email, password);
      emit(AuthSuccess());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword(String email) async {
    final now = DateTime.now();

    if (_lastResetRequest != null &&
        now.difference(_lastResetRequest!) < const Duration(minutes: 1)) {
      emit(
        AuthError(message: "❌ استنى شوية قبل طلب جديد", type: ErrorType.auth),
      );
      return;
    }

    _lastResetRequest = now;

    if (email.trim().isEmpty) {
      emit(AuthError(message: "الايميل مطلوب", type: ErrorType.auth));
      return;
    }

    emit(AuthLoading());

    try {
      await resetPassword(email.trim());
      emit(AuthPasswordSent());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  // ================= CHECK LOGIN =================
  Future<void> checkLogin() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        emit(AuthLoggedOut());
        return;
      }

      final role = await _getRole(user.id);
      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (_) {
      emit(AuthLoggedOut());
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    emit(AuthLoading());

    try {
      await signOut();
      emit(AuthLoggedOut());
    } catch (e) {
      emit(_mapError(e));
    }
  }

  // ================= ERROR MAPPER =================
  AuthError _mapError(dynamic e) {
    final err = ErrorMapper.map(e);
    return AuthError(message: err.message, type: err.type);
  }

  // ================= START =================
  void start() {
    listenToAuthChanges();
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
