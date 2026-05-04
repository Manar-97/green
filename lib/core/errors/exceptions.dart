enum ErrorType {
  network,
  timeout,
  auth,
  database,
  storage,
  functions,
  realtime,
  validation,
  unknown,
}

class AppException {
  final String message;
  final ErrorType type;

  AppException(this.message, this.type);
}

class NetworkException extends AppException {
  NetworkException([String message = "No internet connection"])
    : super(message, ErrorType.network);
}

class AuthException extends AppException {
  AuthException([String message = "Authentication error"])
    : super(message, ErrorType.auth);
}

class DatabaseException extends AppException {
  DatabaseException([String message = "Database error"])
    : super(message, ErrorType.database);
}

class StorageException extends AppException {
  StorageException([String message = "Storage error"])
    : super(message, ErrorType.storage);
}
