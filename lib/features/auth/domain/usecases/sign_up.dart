import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class SignUpUseCase {
  final AuthRepository repo;

  SignUpUseCase(this.repo);

  Future<void> call(String email, String password) {
    return repo.signUp(email, password);
  }
}
