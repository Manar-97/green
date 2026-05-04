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

      return NetworkException("No internet connection");
    }

    if (error is TimeoutException) {
      print("⏱ TIMEOUT ERROR");
      print("💬 Request timeout");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return NetworkException("Request timeout");
    }

    // ---------------- AUTH ----------------
    if (error is supabase.AuthException || error is supabase.AuthApiException) {
      print("🔐 AUTH ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapAuth(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return AuthException(msg);
    }

    // ---------------- DATABASE ----------------
    if (error is supabase.PostgrestException) {
      print("🗄 DATABASE ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapPostgrest(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return DatabaseException(msg);
    }

    // ---------------- STORAGE ----------------
    if (error is supabase.StorageException) {
      print("📦 STORAGE ERROR");
      print("💬 ORIGINAL: ${error.message}");

      final msg = _mapStorage(error.message);

      print("💡 MAPPED: $msg");
      print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      return StorageException(msg);
    }

    // ---------------- UNKNOWN ----------------
    print("❓ UNKNOWN ERROR");
    print("💬 ${error.toString()}");
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

    return AppException("Unexpected error occurred", ErrorType.unknown);
  }

  // ================= AUTH MAPPING =================
  static String _mapAuth(String msg) {
    final m = msg.toLowerCase();

    if (m.contains("invalid login")) {
      return "Email or password is incorrect";
    }

    if (m.contains("email not confirmed")) {
      return "Please confirm your email first";
    }

    if (m.contains("user already registered")) {
      return "User already exists";
    }

    return msg;
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
