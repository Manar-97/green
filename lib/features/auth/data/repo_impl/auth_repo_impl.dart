import 'package:injectable/injectable.dart';
import '../../domain/repo/auth_repo.dart';
import '../datasource/auth_remote_data_source.dart';

@Injectable(as: AuthRepository)
class AuthRepoImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepoImpl(this.remote);

  @override
  Future<void> signIn(String email, String password) {
    return remote.signIn(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password) {
    return remote.signUp(email: email, password: password);
  }

  @override
  Future<void> resetPassword(String email) {
    return remote.resetPassword(email);
  }

  @override
  Future<void> signOut() {
    return remote.signOut();
  }

  @override
  bool isLoggedIn() {
    return remote.isLoggedIn();
  }
}
