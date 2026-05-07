import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'exceptions.dart';

class ErrorMapper {
  static AppException map(dynamic error) {
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
    print("❌ RAW TYPE: ${error.runtimeType}");
    print("❌ RAW ERROR: $error");

    // ---------------- NETWORK ----------------
    if (error is SocketException) {
      print("🌐 NETWORK ERROR");
      print("💬 No internet connection");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return NetworkAppException("No internet connection");
    }

    if (error is TimeoutException) {
      print("⏱ TIMEOUT ERROR");
      print("💬 Request timeout");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return NetworkAppException("Request timeout");
    }

    // ---------------- AUTH ----------------
    if (error is supabase.AuthException || error is supabase.AuthApiException) {
      print("🔐 AUTH ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapAuth(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return AuthAppException(msg);
    }

    // ---------------- DATABASE ----------------
    if (error is supabase.PostgrestException) {
      print("🗄 DATABASE ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapPostgrest(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return DatabaseAppException(msg);
    }

    // ---------------- STORAGE ----------------
    if (error is supabase.StorageException) {
      print("📦 STORAGE ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapStorage(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return StorageAppException(msg);
    }

    // ---------------- UNKNOWN ----------------
    print("❓ UNKNOWN ERROR");
    print("💬 ${error.toString()}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return AppException("Unexpected error occurred", ErrorType.unknown);
  }

  // ================= AUTH MAPPING =================
  static String _mapAuth(String msg) {
    final m = msg.toLowerCase().trim();

    // ==================================================
    // LOGIN
    // ==================================================

    if (m.contains("invalid login credentials")) {
      return "البريد الإلكتروني أو كلمة المرور غير صحيحة";
    }

    if (m.contains("invalid credentials")) {
      return "بيانات تسجيل الدخول غير صحيحة";
    }

    if (m.contains("user not found")) {
      return "المستخدم غير موجود";
    }

    if (m.contains("invalid email")) {
      return "البريد الإلكتروني غير صالح";
    }

    if (m.contains("email address") && m.contains("invalid")) {
      return "صيغة البريد الإلكتروني غير صحيحة";
    }

    if (m.contains("anonymous sign-ins are disabled")) {
      return "تسجيل الدخول غير متاح حالياً";
    }

    // ==================================================
    // REGISTER
    // ==================================================

    if (m.contains("user already registered")) {
      return "هذا البريد الإلكتروني مستخدم بالفعل";
    }

    if (m.contains("signup is disabled")) {
      return "إنشاء الحسابات متوقف حالياً";
    }

    if (m.contains("password should be at least")) {
      return "كلمة المرور يجب ألا تقل عن 6 أحرف";
    }

    if (m.contains("weak password")) {
      return "كلمة المرور ضعيفة";
    }

    if (m.contains("password is too short")) {
      return "كلمة المرور قصيرة جداً";
    }

    if (m.contains("same password")) {
      return "يجب إدخال كلمة مرور مختلفة";
    }

    // ==================================================
    // EMAIL CONFIRMATION
    // ==================================================

    if (m.contains("email not confirmed")) {
      return "يجب تأكيد البريد الإلكتروني أولاً";
    }

    if (m.contains("signup requires a valid password")) {
      return "يرجى إدخال كلمة مرور صحيحة";
    }

    // ==================================================
    // PASSWORD RESET
    // ==================================================

    if (m.contains("expired")) {
      return "انتهت صلاحية الرابط";
    }

    if (m.contains("otp expired")) {
      return "انتهت صلاحية رمز التحقق";
    }

    if (m.contains("invalid token")) {
      return "الرابط غير صالح";
    }

    if (m.contains("token has expired")) {
      return "انتهت صلاحية الجلسة";
    }

    if (m.contains("session expired")) {
      return "انتهت صلاحية الجلسة، سجل الدخول مرة أخرى";
    }

    if (m.contains("same_password")) {
      return "لا يمكن استخدام نفس كلمة المرور القديمة";
    }

    // ==================================================
    // GOOGLE AUTH
    // ==================================================

    if (m.contains("provider is not enabled")) {
      return "تسجيل الدخول بجوجل غير مفعل";
    }

    if (m.contains("oauth")) {
      return "حدث خطأ أثناء تسجيل الدخول بجوجل";
    }

    if (m.contains("identity not linked")) {
      return "هذا الحساب غير مرتبط";
    }

    // ==================================================
    // PERMISSIONS
    // ==================================================

    if (m.contains("permission denied")) {
      return "ليس لديك صلاحية للوصول";
    }

    if (m.contains("access denied")) {
      return "تم رفض الوصول";
    }

    if (m.contains("not authorized")) {
      return "غير مصرح لك بتنفيذ هذا الإجراء";
    }

    // ==================================================
    // RATE LIMIT
    // ==================================================

    if (m.contains("rate limit")) {
      return "عدد المحاولات كبير جداً، حاول لاحقاً";
    }

    if (m.contains("too many requests")) {
      return "تم إرسال طلبات كثيرة، حاول لاحقاً";
    }

    if (m.contains("security purposes")) {
      return "تم إيقاف الطلب مؤقتاً لأسباب أمنية";
    }

    // ==================================================
    // NETWORK
    // ==================================================

    if (m.contains("network")) {
      return "تحقق من اتصال الإنترنت";
    }

    if (m.contains("socket")) {
      return "لا يوجد اتصال بالإنترنت";
    }

    if (m.contains("timeout")) {
      return "انتهت مهلة الاتصال، حاول مرة أخرى";
    }

    // ==================================================
    // SERVER
    // ==================================================

    if (m.contains("internal server error")) {
      return "حدث خطأ في الخادم";
    }

    if (m.contains("database error")) {
      return "حدث خطأ في قاعدة البيانات";
    }

    if (m.contains("unexpected_failure")) {
      return "حدث خطأ غير متوقع";
    }

    // ==================================================
    // DEFAULT
    // ==================================================

    return "حدث خطأ غير متوقع";
  }

  // ================= DATABASE MAPPING =================
  static String _mapPostgrest(String msg) {
    final m = msg.toLowerCase();

    if (m.contains("duplicate")) {
      return "This item already exists";
    }

    if (m.contains("permission")) {
      return "You don't have permission";
    }

    if (m.contains("row-level security")) {
      return "Access denied";
    }

    return msg;
  }

  // ================= STORAGE MAPPING =================
  static String _mapStorage(String msg) {
    final m = msg.toLowerCase();

    if (m.contains("not found")) {
      return "File not found";
    }

    if (m.contains("size")) {
      return "File is too large";
    }

    return msg;
  }
}
