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

    _reqSub = repo.watchRequests().listen(
      (data) {
        emit(state.copyWith(requests: data, error: null));
      },
      onError: (_) => _reconnect(),
      onDone: () => _reconnect(),
    );

    _userSub = repo.watchUsers().listen((data) {
      emit(
        state.copyWith(
          users: data,
          isLoadingUsers: false, // 🔥 مهم جدًا
          error: null,
        ),
      );
    }, onError: (_) => _reconnect());
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

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoadingRequests: true, isLoadingUsers: true));

    try {
      final requests = await repo.getAllRequests();
      final users = await repo.getAllUsers();

      emit(
        state.copyWith(
          isLoadingRequests: false,
          isLoadingUsers: false,
          requests: requests,
          users: users,
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

  void setFilterDay(DateTime? day) {
    emit(state.copyWith(selectedDay: day));
  }

  Future<void> approve(String requestId, String userId) async {
    emit(state.copyWith(isLoadingUsers: true));

    try {
      await repo.approveRequest(requestId, userId);
    } catch (e) {
      final err = ErrorMapper.map(e);
      emit(state.copyWith(isLoadingUsers: false, error: err.message));
    }
  }

  // Future<void> filterRequestsByDay(DateTime day) async {
  //   emit(state.copyWith(isLoadingRequests: true));
  //
  //   if (!await NetworkGuard.hasInternet()) {
  //     emit(state.copyWith(isLoadingRequests: false, error: "❌ مفيش إنترنت"));
  //     return;
  //   }
  //
  //   try {
  //     final requests = await repo.getRequestsByDay(day);
  //
  //     emit(state.copyWith(isLoadingRequests: false, requests: requests));
  //   } catch (e) {
  //     final err = ErrorMapper.map(e);
  //
  //     emit(
  //       state.copyWith(
  //         isLoadingRequests: false,
  //         error: err.message,
  //         errorType: err.type,
  //       ),
  //     );
  //   }
  // }

  @override
  Future<void> close() {
    _reqSub?.cancel();
    _userSub?.cancel();
    return super.close();
  }
}
