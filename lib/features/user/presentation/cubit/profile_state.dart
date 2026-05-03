import '../../../../core/errors/exceptions.dart';
import '../../data/models/user_dm.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final ErrorType? errorType;
  final UserModel? user;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.errorType,
    this.user,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    ErrorType? errorType,
    UserModel? user,
    bool clearError = false, // 🔥 مهم
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      errorType: clearError ? null : (errorType ?? this.errorType),
      user: user ?? this.user,
    );
  }
}
