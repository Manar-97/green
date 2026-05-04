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
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      await remote.signInWithGoogle();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> signUp(String email, String password) async {
    try {
      await remote.signUp(email: email, password: password);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> sendOtp(String phone) async {
    try {
      await remote.sendOtp(phone: phone);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> verifyOtp(String phone, String token) async {
    try {
      await remote.verifyOtp(phone: phone, token: token);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await remote.resetPassword(email);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.signOut();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  bool isLoggedIn() => remote.isLoggedIn();
}
