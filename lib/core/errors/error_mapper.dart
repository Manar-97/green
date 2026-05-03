import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'exceptions.dart';

class ErrorMapper {
  static AppException map(dynamic error) {
    if (error is SocketException) {
      return NetworkException();
    }

    if (error is TimeoutException) {
      return NetworkException();
    }

    if (error is supabase.AuthApiException) {
      return AuthException(error.message);
    }

    if (error is supabase.PostgrestException) {
      return ServerException(error.message);
    }

    return AppException("Unexpected error", ErrorType.unknown);
  }
}
