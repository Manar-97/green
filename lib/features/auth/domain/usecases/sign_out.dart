import 'package:injectable/injectable.dart';

import '../repo/auth_repo.dart';

@injectable
class SignOutUseCase {
  final AuthRepository repo;

  SignOutUseCase(this.repo);

  Future<void> call() {
    return repo.signOut();
  }
}