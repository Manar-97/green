import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class SignInWithGoogleUseCase {
  final AuthRepository repo;

  SignInWithGoogleUseCase(this.repo);

  Future<void> call() {
    return repo.signInWithGoogle();
  }
}