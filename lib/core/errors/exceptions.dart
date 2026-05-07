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

// ================= NETWORK =================

class NetworkAppException extends AppException {
  NetworkAppException([String message = "No internet connection"])
    : super(message, ErrorType.network);
}

// ================= AUTH =================

class AuthAppException extends AppException {
  AuthAppException([String message = "Authentication error"])
    : super(message, ErrorType.auth);
}

// ================= DATABASE =================

class DatabaseAppException extends AppException {
  DatabaseAppException([String message = "Database error"])
    : super(message, ErrorType.database);
}

// ================= STORAGE =================

class StorageAppException extends AppException {
  StorageAppException([String message = "Storage error"])
    : super(message, ErrorType.storage);
}
