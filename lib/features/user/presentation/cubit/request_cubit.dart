import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/network_guard.dart';
import '../../domain/repo/request_repo.dart';
import 'request_state.dart';

@injectable
class RequestCubit extends Cubit<RequestState> {
  final RequestRepository requestRepo;

  RequestCubit(this.requestRepo) : super(const RequestState());

  Future<void> fetchRequests(String userId) async {
    emit(state.copyWith(isLoading: true));

    if (!await NetworkGuard.hasInternet()) {
      emit(state.copyWith(isLoading: false, error: "❌ مفيش إنترنت"));
      return;
    }

    try {
      final data = await requestRepo.getMyRequests(userId);

      emit(state.copyWith(isLoading: false, requests: data));
    } catch (e) {
      final err = ErrorMapper.map(e);

      emit(state.copyWith(
        isLoading: false,
        error: err.message,
        errorType: err.type,
      ));
    }
  }

  Future<void> submitRequest({
    required String wasteType,
    required String name,
    required String phone,
    required String nationalId,
    required String address,
  }) async {
    emit(state.copyWith(isSubmitting: true));

    if (!await NetworkGuard.hasInternet()) {
      emit(state.copyWith(isSubmitting: false, error: "❌ مفيش إنترنت"));
      return;
    }

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        emit(state.copyWith(isSubmitting: false, error: "لازم تسجيل دخول"));
        return;
      }

      final canSend = await canSendRequest(user.id);

      if (!canSend) {
        emit(state.copyWith(
          isSubmitting: false,
          error: "❌ مسموح بطلب واحد فقط في اليوم",
        ));
        return;
      }

      await requestRepo.submitRequest(
        userId: user.id,
        wasteType: wasteType,
        name: name,
        phone: phone,
        nationalId: nationalId,
        address: address,
      );

      final updated = await requestRepo.getMyRequests(user.id);

      emit(state.copyWith(
        isSubmitting: false,
        success: true,
        requests: updated,
      ));
    } catch (e) {
      final err = ErrorMapper.map(e);

      emit(state.copyWith(
        isSubmitting: false,
        error: err.message,
        errorType: err.type,
      ));
    }
  }

  Future<bool> canSendRequest(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('requests')
          .select('request_date')
          .eq('user_id', userId)
          .order('request_date', ascending: false)
          .limit(1);

      if (data.isEmpty) return true;

      final last = DateTime.parse(data.first['request_date']);
      final now = DateTime.now();

      return !(last.year == now.year &&
          last.month == now.month &&
          last.day == now.day);
    } catch (_) {
      return true;
    }
  }
}
