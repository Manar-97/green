import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class SendResetPasswordUseCase {
  final AuthRepository repository;

  SendResetPasswordUseCase(this.repository);

  Future<void> call(String email) {
    return repository.sendResetPassword(email);
  }
}

@injectable
class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call(String newPassword) {
    return repository.updatePassword(newPassword);
  }
}
