import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/network_guard.dart';
import '../../domain/repo/request_repo.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final RequestRepository repo;

  ProfileCubit(this.repo) : super(const ProfileState());

  Future<void> loadProfile(String userId) async {
    emit(state.copyWith(isLoading: true));

    if (!await NetworkGuard.hasInternet()) {
      emit(state.copyWith(isLoading: false, error: "❌ مفيش إنترنت"));
      return;
    }

    try {
      final user = await repo.getProfile(userId);

      emit(state.copyWith(isLoading: false, user: user));
    } catch (e) {
      final err = ErrorMapper.map(e);

      emit(state.copyWith(
        isLoading: false,
        error: err.message,
        errorType: err.type,
      ));
    }
  }


}
