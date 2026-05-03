enum ErrorType { network, auth, server, unknown }

class AppException implements Exception {
  final String message;
  final ErrorType type;

  AppException(this.message, this.type);
}

class NetworkException extends AppException {
  NetworkException() : super("No internet connection", ErrorType.network);
}

class ServerException extends AppException {
  ServerException([String msg = "Server error"]) : super(msg, ErrorType.server);
}

class AuthException extends AppException {
  AuthException([String msg = "Authentication error"])
    : super(msg, ErrorType.auth);
}
