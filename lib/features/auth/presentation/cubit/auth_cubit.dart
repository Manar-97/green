import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/check_auth.dart';
import '../../domain/usecases/reset_password.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
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

  StreamSubscription? _authSub;
  AuthState? _lastState;
  DateTime? _lastResetRequest;
  final _client = supabase.Supabase.instance.client;

  Future<String?> _getRole(String userId) async {
    final profile = await _client
        .from('profiles')
        .select('role')
        .eq('id', userId)
        .maybeSingle();

    return profile?['role']?.toString().toLowerCase();
  }

  // ================= AUTH LISTENER =================
  void listenToAuthChanges() {
    _authSub?.cancel();

    _authSub = supabase.Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      print("🔥 AUTH EVENT: ${data.event}");
      print("🔥 SESSION: ${data.session}");

      final session = data.session;
      final event = data.event;

      if (event == supabase.AuthChangeEvent.passwordRecovery) {
        print("⚠️ PASSWORD RECOVERY EVENT - ignored in listener");
        return;
      }

      if (session == null) {
        print("🚪 USER LOGGED OUT");
        emit(AuthLoggedOut());
        return;
      }

      final user = session.user;
      print("👤 USER ID: ${user.id}");

      try {
        final profile = await supabase.Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        print("📦 PROFILE RESPONSE: $profile");

        final role = profile?['role']?.toString().toLowerCase();
        print("🎯 ROLE: $role");

        if (role == 'admin') {
          if (_lastState is AuthLoggedInAdmin) return;
          _lastState = AuthLoggedInAdmin();
          print("🟢 EMIT: ADMIN");
          emit(AuthLoggedInAdmin());
        } else {
          if (_lastState is AuthLoggedInUser) return;
          _lastState = AuthLoggedInUser();
          print("🟡 EMIT: USER");
          emit(AuthLoggedInUser());
        }
      } catch (e) {
        print("❌ ERROR in profile fetch: $e");
        emit(AuthError(message: e.toString(), type: ErrorType.auth));
      }
    });
  }

  @override
  Future<void> close() {
    print("🛑 AUTH CUBIT CLOSED");
    _authSub?.cancel();
    return super.close();
  }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    print("🔐 LOGIN START");
    print("📧 email: $email");
    print("🔑 password: ${password.isNotEmpty ? '***' : 'EMPTY'}");

    emit(AuthLoading());

    try {
      await signIn(email, password);
      print("✅ SIGN IN SUCCESS");

      final user = supabase.Supabase.instance.client.auth.currentUser;
      print("👤 CURRENT USER: $user");

      if (user == null) {
        print("❌ USER NULL AFTER LOGIN");
        emit(AuthError(message: "User not found", type: ErrorType.auth));
        return;
      }

      final profile = await supabase.Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      print("📦 PROFILE LOGIN: $profile");

      final role = profile?['role']?.toString().toLowerCase();
      print("🎯 ROLE LOGIN: $role");

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  // ================= LOGIN WITH GOOGLE=================
  Future<void> loginWithGoogle() async {
    print("🔵 GOOGLE LOGIN START");

    emit(AuthLoading());

    try {
      await signInWithGoogle();

      final user = _client.auth.currentUser;

      if (user == null) {
        print("❌ GOOGLE LOGIN FAILED: USER NULL");

        emit(AuthError(message: "Google login failed", type: ErrorType.auth));
        return;
      }

      print("👤 GOOGLE USER: ${user.id}");

      final role = await _getRole(user.id);

      print("🎯 GOOGLE ROLE: $role");

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      print("❌ GOOGLE LOGIN ERROR: $e");

      final err = ErrorMapper.map(e);

      emit(AuthError(message: err.message, type: err.type));
    }
  } // ================= REGISTER =================

  Future<void> register(String email, String password) async {
    print("📝 REGISTER START");
    print("📧 email: $email");

    emit(AuthLoading());

    try {
      await signUp(email, password);
      print("✅ REGISTER SUCCESS");
      emit(AuthSuccess());
    } catch (e) {
      print("❌ REGISTER ERROR: $e");
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword(String email) async {
    final now = DateTime.now();
    if (_lastResetRequest != null &&
        now.difference(_lastResetRequest!) < const Duration(minutes: 1)) {
      print("⛔ جربت اكتر من مره ");
      emit(
        AuthError(
          message: "❌ استنى شوية قبل ما تبعت طلب تاني",
          type: ErrorType.auth,
        ),
      );
      return;
    }

    _lastResetRequest = now;
    print("📩 FORGOT PASSWORD START");
    print("📧 email: $email");

    emit(AuthLoading());

    if (email.trim().isEmpty) {
      print("❌ EMAIL EMPTY");
      emit(AuthError(message: "الايميل مطلوب الاول", type: ErrorType.auth));
      return;
    }

    try {
      await resetPassword(email.trim());
      print("✅ RESET EMAIL SENT");
      emit(AuthPasswordSent());
    } catch (e, stack) {
      print("❌ RESET PASSWORD RAW ERROR: $e");
      print("📛 ERROR TYPE: ${e.runtimeType}");
      print("📚 STACKTRACE: $stack");

      if (e is AuthException) {
        print("🔴 SUPABASE MESSAGE: ${e.message}");
      }

      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  // ================= CHECK LOGIN =================
  Future<void> checkLogin() async {
    print("🔎 CHECK LOGIN");

    try {
      final user = supabase.Supabase.instance.client.auth.currentUser;
      print("👤 CURRENT USER: $user");

      if (user == null) {
        print("🚪 NO USER");
        emit(AuthLoggedOut());
        return;
      }

      final profile = await supabase.Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      print("📦 CHECK PROFILE: $profile");

      final role = profile?['role']?.toString().toLowerCase();
      print("🎯 CHECK ROLE: $role");

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    } catch (e) {
      print("❌ CHECK LOGIN ERROR: $e");
      emit(AuthLoggedOut());
    }
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    print("🚪 LOGOUT START");

    emit(AuthLoading());

    try {
      await signOut();
      print("✅ LOGOUT SUCCESS");
      emit(AuthLoggedOut());
    } catch (e) {
      print("❌ LOGOUT ERROR: $e");
      final err = ErrorMapper.map(e);
      emit(AuthError(message: err.message, type: err.type));
    }
  }

  // ================= sendOtp =================
  // Future<void> sendOtp(String phone) async {
  //   emit(AuthLoading());
  //   try {
  //     await sendOtpUseCase(phone);
  //     emit(AuthOtpSent());
  //   } catch (e) {
  //     final err = ErrorMapper.map(e);
  //     emit(AuthError(message: err.message, type: err.type));
  //   }
  // }
  //
  // Future<void> verifyOtp(String phone, String token) async {
  //   emit(AuthLoading());
  //   try {
  //     await verifyOtpUseCase(phone, token);
  //
  //     final user = supabase.Supabase.instance.client.auth.currentUser;
  //
  //     if (user == null) {
  //       emit(AuthError(message: "Login failed", type: ErrorType.auth));
  //       return;
  //     }
  //
  //     final role = await _getRole(user.id);
  //
  //     emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
  //   } catch (e) {
  //     final err = ErrorMapper.map(e);
  //     emit(AuthError(message: err.message, type: err.type));
  //   }
  // }

  void start() {
    print("🚀 AUTH CUBIT STARTED");
    listenToAuthChanges();
  }
}
