import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepository repo;

  ResetPasswordUseCase(this.repo);

  Future<void> call(String email) {
    return repo.resetPassword(email);
  }
}
