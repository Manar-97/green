part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthPasswordSent extends AuthState {}

class AuthLoggedOut extends AuthState {}

class AuthLoggedInAdmin extends AuthState {}

class AuthLoggedInUser extends AuthState {}

class AuthOtpSent extends AuthState {}

class AuthOtpVerified extends AuthState {}

class AuthOtpLoading extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final ErrorType type;

  AuthError({required this.message, required this.type});
}
