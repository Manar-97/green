import 'package:injectable/injectable.dart';
import '../repo/auth_repo.dart';

@injectable
class CheckAuthUseCase {
  final AuthRepository repo;

  CheckAuthUseCase(this.repo);

  bool call() {
    return repo.isLoggedIn();
  }
}
