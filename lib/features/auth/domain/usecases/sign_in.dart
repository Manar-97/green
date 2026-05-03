import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class SignInUseCase {
  final AuthRepository repo;

  SignInUseCase(this.repo);

  Future<void> call(String email, String password) {
    return repo.signIn(email, password);
  }
}
