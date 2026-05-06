import '../../../../core/errors/exceptions.dart';
import '../../../user/data/models/request_dm.dart';
import '../../../user/data/models/user_dm.dart';

class AdminState {
  final bool isLoadingRequests;
  final bool isLoadingUsers;

  final String? error;
  final ErrorType? errorType;

  final List<RequestModel> requests;
  final List<UserModel> users;
  final DateTime? selectedDay; // 👈 الفلتر

  const AdminState({
    this.isLoadingRequests = false,
    this.isLoadingUsers = false,
    this.error,
    this.errorType,
    this.requests = const [],
    this.users = const [],
    this.selectedDay,
  });

  AdminState copyWith({
    bool? isLoadingRequests,
    bool? isLoadingUsers,
    String? error,
    ErrorType? errorType,
    List<RequestModel>? requests,
    List<UserModel>? users,
    bool clearError = false,
    DateTime? selectedDay,
  }) {
    return AdminState(
      isLoadingRequests: isLoadingRequests ?? this.isLoadingRequests,
      isLoadingUsers: isLoadingUsers ?? this.isLoadingUsers,
      error: clearError ? null : (error ?? this.error),
      errorType: clearError ? null : (errorType ?? this.errorType),
      requests: requests ?? this.requests,
      users: users ?? this.users,
      selectedDay: selectedDay,
    );
  }
}
