import 'dart:async';
import 'package:flutter/material.dart';
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

@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase signIn;
  final SignInWithGoogleUseCase signInWithGoogle;
  final SignUpUseCase signUp;
  final SendResetPasswordUseCase sendResetPassword;
  final UpdatePasswordUseCase updatePassword;
  final CheckAuthUseCase checkAuth;
  final SignOutUseCase signOut;

  AuthCubit({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.sendResetPassword,
    required this.checkAuth,
    required this.signInWithGoogle,
    required this.updatePassword,
  }) : super(AuthInitial());

  final _client = supabase.Supabase.instance.client;

  StreamSubscription? _authSub;
  bool isDeepLinkFlow = false;
  AuthState? _lastEmitted;
  bool _handledRecovery = false;

  void _emitOnce(AuthState state) {
    if (state.runtimeType == _lastEmitted.runtimeType) return;

    _lastEmitted = state;
    emit(state);
  }

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
    _authSub?.cancel(); // مهم
    _authSub = _client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      debugPrint("🔔 AUTH EVENT: $event");

      // ❌ مهم جدًا: تجاهل initialSession في Google flow
      if (event == supabase.AuthChangeEvent.initialSession) {
        debugPrint("⛔ IGNORING initialSession (handled in Splash)");
        return;
      }

      if (event == supabase.AuthChangeEvent.passwordRecovery) {
        if (_handledRecovery) return;
        debugPrint("🔑 RECOVERY EVENT");
        _handledRecovery = true;
        _emitOnce(AuthPasswordRecovery());
        return;
      }

      if (session == null) {
        _emitOnce(AuthLoggedOut());
        return;
      }

      final role = await _getRole(session.user.id);

      _emitOnce(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    });
  }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    debugPrint("🔐 LOGIN START");
    debugPrint("📧 EMAIL: $email");

    emit(AuthLoading());

    try {
      await signIn(email, password);

      debugPrint("✅ SIGN IN DONE");

      final user = _client.auth.currentUser;

      debugPrint("👤 CURRENT USER: ${user?.id}");

      if (user == null) {
        debugPrint("❌ NO USER AFTER LOGIN");
        emit(AuthError(message: "User not found", type: ErrorType.auth));
        return;
      }

      debugPrint("⏳ FETCH ROLE...");

      final role = await _getRole(user.id);

      debugPrint("🎯 ROLE: $role");

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());

      debugPrint("🏁 LOGIN FLOW DONE");
    } catch (e) {
      debugPrint("❌ LOGIN ERROR: $e");
      emit(_mapError(e));
    }
  }

  // ================= GOOGLE LOGIN =================
  Future<void> loginWithGoogle() async {
    if (state is AuthGoogleLoading) return;

    emit(AuthGoogleLoading());

    try {
      await signInWithGoogle();

      debugPrint("🚀 Google login initiated");

      // ❌ ممنوع emit state هنا
      // خليه كله من listener فقط
    } catch (e) {
      emit(_mapError(e));
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

  // ================= RESET PASSWORD =================

  bool _isResetSent = false;

  Future<void> sendResetPass(String email) async {
    if (_isResetSent) return;

    _isResetSent = true;
    emit(AuthLoading());

    try {
      await sendResetPassword(email);
      emit(AuthPasswordSent());
    } catch (e) {
      _isResetSent = false;
      emit(_mapError(e));
    }
  }

  // ================= UPDATE PASSWORD =================
  Future<void> updatePass(String password) async {
    emit(AuthLoading());

    try {
      await updatePassword(password);
      emit(AuthSuccess());

      await signOut();
    } catch (e) {
      emit(_mapError(e));
    }
  }

  // ================= CHECK LOGIN =================
  // Future<void> checkLogin() async {
  //   debugPrint("🔎 CHECK LOGIN START");
  //
  //   try {
  //     final session = _client.auth.currentSession;
  //
  //     debugPrint("🧾 SESSION: $session");
  //
  //     if (session == null) {
  //       debugPrint("🚪 NO SESSION → LOGGED OUT");
  //
  //       _emitOnce(AuthLoggedOut()); // 🔥 بدل emit
  //       return;
  //     }
  //
  //     debugPrint("👤 USER ID: ${session.user.id}");
  //     debugPrint("⏳ FETCH ROLE...");
  //
  //     final role = await _getRole(session.user.id);
  //
  //     debugPrint("🎯 ROLE: $role");
  //
  //     _emitOnce(
  //       role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser(),
  //     ); // 🔥 بدل emit
  //
  //     debugPrint("🏁 CHECK LOGIN DONE");
  //   } catch (e) {
  //     debugPrint("❌ CHECK LOGIN ERROR: $e");
  //     _emitOnce(AuthLoggedOut()); // 🔥 مهم جدًا
  //   }
  // }

  // ================= LOGOUT =================
  Future<void> logout() async {
    debugPrint("🚨 LOGOUT CALLED");
    _handledRecovery = false;
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
    // لو هو already AppException متعيديش mapping
    if (e is AppException) {
      return AuthError(message: e.message, type: e.type);
    }

    final err = ErrorMapper.map(e);

    return AuthError(message: err.message, type: err.type);
  }

  // ================= START =================
  void start() {
    _handledRecovery = false; // 👈 مهم جدًا
    final session = _client.auth.currentSession;

    if (session == null) {
      emit(AuthLoggedOut());
      return;
    }

    final user = session.user;

    _getRole(user.id).then((role) {
      if (role == 'admin') {
        emit(AuthLoggedInAdmin());
      } else {
        emit(AuthLoggedInUser());
      }
    });
  }

  @override
  Future<void> close() {
    _authSub?.cancel();
    return super.close();
  }
}
