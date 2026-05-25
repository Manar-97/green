import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/network_guard.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/repo/admin_repo.dart';
import 'admin_state.dart';

@injectable
class AdminCubit extends Cubit<AdminState> {
  final AdminRepository repo;

  StreamSubscription? _reqSub;
  StreamSubscription? _userSub;
  bool _reconnecting = false;

  AdminCubit(this.repo) : super(const AdminState());

  void startRealtime() async {
    if (!await NetworkGuard.hasInternet()) {
      emit(state.copyWith(error: "❌ مفيش إنترنت"));
      return;
    }
    _subscribe();
  }

  void _subscribe() {
    _reqSub?.cancel();
    _userSub?.cancel();

    _reqSub = repo.watchRequests().listen((data) {
      emit(
        state.copyWith(
          requests: List.from(data),
          isLoadingRequests: false,
          error: null,
        ),
      );
    }, onError: (_) => _reconnect());
    _userSub = repo.watchUsers().listen((data) {
      data.sort((a, b) => b.score.compareTo(a.score));

      emit(state.copyWith(users: data, isLoadingUsers: false, error: null));
    }, onError: (_) => _reconnect());
  }

  void setFilterDay(DateTime? day) {
    emit(state.copyWith(selectedDay: day));
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoadingRequests: true, isLoadingUsers: true));

    try {
      final requests = await repo.getAllRequests();
      final users = await repo.getAllUsers();

      users.sort((a, b) => b.score.compareTo(a.score));

      emit(
        state.copyWith(
          requests: requests,
          users: users,
          isLoadingRequests: false,
          isLoadingUsers: false,
          error: null,
        ),
      );
    } catch (e) {
      final err = ErrorMapper.map(e);

      emit(
        state.copyWith(
          isLoadingRequests: false,
          isLoadingUsers: false,
          error: err.message,
        ),
      );
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      await repo.deleteRequest(requestId);
    } catch (e) {
      emit(state.copyWith(error: ErrorMapper.map(e).message));
    }
  }

  Future<void> approve(String requestId, String userId) async {
    try {
      // add loading
      final newLoading = Set<String>.from(state.loadingIds)..add(requestId);
      emit(state.copyWith(loadingIds: newLoading));
      await repo.approveRequest(requestId, userId);
      // remove loading
      final updated = Set<String>.from(state.loadingIds)..remove(requestId);
      emit(state.copyWith(loadingIds: updated));
    } catch (e) {
      emit(state.copyWith(error: ErrorMapper.map(e).message));
    }
  }

  void _reconnect() async {
    if (_reconnecting) return;
    _reconnecting = true;

    await Future.delayed(const Duration(seconds: 3));

    if (await NetworkGuard.hasInternet()) {
      _subscribe();
    } else {
      emit(state.copyWith(error: "❌ مفيش إنترنت"));
    }

    _reconnecting = false;
  }

  @override
  Future<void> close() {
    _reqSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
