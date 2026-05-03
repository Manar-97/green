import '../../../../core/errors/exceptions.dart';
import '../../data/models/request_dm.dart';

class RequestState {
  final bool isLoading;
  final bool isSubmitting;
  final bool success;

  final String? error;
  final ErrorType? errorType;

  final List<RequestModel> requests;

  const RequestState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.success = false,
    this.error,
    this.errorType,
    this.requests = const [],
  });

  RequestState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    bool? success,
    String? error,
    ErrorType? errorType,
    List<RequestModel>? requests,
    bool clearError = false, // 🔥 مهم
  }) {
    return RequestState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      error: clearError ? null : (error ?? this.error),
      errorType: clearError ? null : (errorType ?? this.errorType),
      requests: requests ?? this.requests,
    );
  }
}
