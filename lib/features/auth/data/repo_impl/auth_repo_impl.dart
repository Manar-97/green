import 'package:injectable/injectable.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/repo/auth_repo.dart';
import '../datasource/auth_remote_data_source.dart';

@Injectable(as: AuthRepository)
class AuthRepoImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepoImpl(this.remote);

  @override
  Future<void> signIn(String email, String password) async {
    try {
      await remote.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await remote.signInWithGoogle();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    try {
      await remote.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.signOut();
    } catch (e) {
      rethrow;
    }
  }

  @override
  bool isLoggedIn() => remote.isLoggedIn();

  @override
  Future<void> sendResetPassword(String email) async {
    try {
      await remote.sendResetPassword(email);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updatePassword(String password) async {
    try {
      await remote.updatePassword(password);
    } catch (e) {
      rethrow;
    }
  }
}
