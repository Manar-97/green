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

  // Future<Map<String, dynamic>?> getProfile(String userId) async {
  //   try {
  //     final res = await _client
  //         .from('profiles')
  //         .select()
  //         .eq('id', userId)
  //         .limit(1);
  //
  //     if (res.isEmpty) return null;
  //
  //     return res.first;
  //   } catch (e) {
  //     if (e is supabase.PostgrestException && e.code == 'PGRST116') {
  //       return null;
  //     }
  //     rethrow;
  //   }
  // }
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      debugPrint("🔎 [PROFILE] getProfile for $userId");

      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint("📦 raw response = $res");

      if (res == null) return null;
      debugPrint("⚠️ profile NOT FOUND");

      return res;
    } catch (e, st) {
      debugPrint("❌ getProfile ERROR = $e");
      debugPrint("📌 STACK = $st");
      rethrow;
    }
  } // ================= ROLE =================

  Future<String> _getRole(String userId) async {
    try {
      debugPrint("━━━━━━━━ GET ROLE START ━━━━━━━━");
      debugPrint("👤 USER ID => $userId");

      final res = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .limit(1);

      debugPrint("📦 ROLE RAW => $res");

      if (res.isEmpty) {
        debugPrint("⚠️ NO ROLE FOUND → default user");
        return 'user';
      }

      final role = res.first['role'];
      debugPrint("🎯 ROLE FOUND => $role");

      return (role ?? 'user').toString().toLowerCase();
    } catch (e) {
      debugPrint("━━━━━━━━ GET ROLE ERROR ━━━━━━━━");
      debugPrint("❌ ERROR => $e");
      return 'user';
    }
  }
  // Future<String> _getRole(String userId) async {
  //   try {
  //     final res = await _client
  //         .from('profiles')
  //         .select('role')
  //         .eq('id', userId)
  //         .limit(1);
  //
  //     if (res.isEmpty) return 'user';
  //
  //     return (res.first['role'] ?? 'user').toString().toLowerCase();
  //   } catch (e) {
  //     return 'user';
  //   }
  // }

  // ================= AUTH LISTENER =================
  void listenToAuthChanges() {
    _authSub?.cancel();

    debugPrint("🚀 AUTH LISTENER STARTED");

    _authSub = _client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;

      debugPrint("📡 EVENT: ${data.event}");
      debugPrint("👤 USER: ${session?.user.id}");

      if (session == null) {
        emit(AuthLoggedOut());
        return;
      }

      final user = session.user;

      final profile = await getProfile(user.id);

      if (profile == null) {
        debugPrint("⚠️ creating profile...");

        await _client.from('profiles').upsert({
          "id": user.id,
          "email": user.email ?? "",
          "name": user.userMetadata?['full_name'] ?? "",
          "phone": "",
          "address": "",
          "score": 0,
          "role": "user",
        });
      }

      final role = await _getRole(user.id);

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
    });
  }
  // void listenToAuthChanges() {
  //   _authSub?.cancel(); // مهم
  //   try {
  //     _authSub = _client.auth.onAuthStateChange.listen((data) async {
  //       final event = data.event;
  //       final session = data.session;
  //
  //       debugPrint("🔔 AUTH EVENT: $event");
  //
  //       // ❌ مهم جدًا: تجاهل initialSession في Google flow
  //       if (event == supabase.AuthChangeEvent.initialSession) {
  //         debugPrint("⛔ IGNORING initialSession (handled in Splash)");
  //         return;
  //       }
  //
  //       if (event == supabase.AuthChangeEvent.passwordRecovery) {
  //         if (_handledRecovery) return;
  //         debugPrint("🔑 RECOVERY EVENT");
  //         _handledRecovery = true;
  //         _emitOnce(AuthPasswordRecovery());
  //         return;
  //       }
  //
  //       if (session == null) {
  //         _emitOnce(AuthLoggedOut());
  //         return;
  //       }
  //
  //       final role = await _getRole(session.user.id);
  //
  //       _emitOnce(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
  //     });
  //   } catch (e) {
  //     debugPrint("❌ listener error: $e");
  //     emit(AuthLoggedInUser()); // fallback مهم جدًا
  //   }
  // }

  // ================= LOGIN =================
  Future<void> login(String email, String password) async {
    debugPrint("━━━━━━━━ LOGIN START ━━━━━━━━");
    debugPrint("📧 EMAIL => $email");

    emit(AuthLoading());

    try {
      await signIn(email, password);

      debugPrint("✅ SIGN IN SUCCESS");

      final user = _client.auth.currentUser;

      debugPrint("👤 CURRENT USER => ${user?.id}");

      if (user == null) {
        debugPrint("❌ USER IS NULL AFTER LOGIN");
        emit(AuthError(message: "User not found", type: ErrorType.auth));
        return;
      }

      final role = await _getRole(user.id);

      debugPrint("🎯 ROLE AFTER LOGIN => $role");

      emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());

      debugPrint("🏁 LOGIN DONE");
    } catch (e) {
      debugPrint("❌ LOGIN ERROR => $e");
      emit(_mapError(e));
    }
  }
  // Future<void> login(String email, String password) async {
  //   debugPrint("🔐 LOGIN START");
  //   debugPrint("📧 EMAIL: $email");
  //
  //   emit(AuthLoading());
  //
  //   try {
  //     await signIn(email, password);
  //
  //     debugPrint("✅ SIGN IN DONE");
  //
  //     final user = _client.auth.currentUser;
  //
  //     debugPrint("👤 CURRENT USER: ${user?.id}");
  //
  //     if (user == null) {
  //       debugPrint("❌ NO USER AFTER LOGIN");
  //       emit(AuthError(message: "User not found", type: ErrorType.auth));
  //       return;
  //     }
  //
  //     debugPrint("⏳ FETCH ROLE...");
  //
  //     final role = await _getRole(user.id);
  //
  //     debugPrint("🎯 ROLE: $role");
  //
  //     emit(role == 'admin' ? AuthLoggedInAdmin() : AuthLoggedInUser());
  //
  //     debugPrint("🏁 LOGIN FLOW DONE");
  //   } catch (e) {
  //     debugPrint("❌ LOGIN ERROR: $e");
  //     emit(_mapError(e));
  //   }
  // }

  // ================= GOOGLE LOGIN =================
  Future<void> loginWithGoogle() async {
    debugPrint("🟡 GOOGLE LOGIN START");

    emit(AuthGoogleLoading());
    await signInWithGoogle();

    try {
      await signInWithGoogle();

      debugPrint("🚀 OAuth launched");

      // ❌ ممنوع تعتمد على currentUser هنا
      debugPrint("⏳ waiting for auth listener...");
    } catch (e, st) {
      debugPrint("❌ GOOGLE ERROR: $e");
      debugPrint("STACK: $st");
      emit(_mapError(e));
    }
  }

  Future<void> register(String email, String password) async {
    emit(AuthLoading());

    try {
      final cleanEmail = email.trim().toLowerCase();
      // ✅ check if email already exists
      final existing = await _client
          .from('profiles')
          .select('email')
          .eq('email', cleanEmail)
          .maybeSingle();

      if (existing != null) {
        emit(
          AuthError(
            message: "هذا البريد الإلكتروني مستخدم بالفعل",
            type: ErrorType.auth,
          ),
        );
        return;
      }
      await signUp(cleanEmail, password);
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
    final msg = e.toString();

    if (msg.contains("EMAIL_EXISTS") ||
        msg.contains("email") && msg.contains("exist")) {
      return AuthError(
        message: "هذا البريد الإلكتروني مستخدم بالفعل",
        type: ErrorType.auth,
      );
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
