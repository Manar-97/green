import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/safe_stream.dart';
import '../../../user/data/models/request_dm.dart';
import '../../../user/data/models/user_dm.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/repo/admin_repo.dart';

@LazySingleton(as: AdminRepository)
class AdminRepoImpl implements AdminRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<List<RequestModel>> getAllRequests() async {
    try {
      final res = await supabase.from('requests').select();

      return (res as List).map((e) => RequestModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> approveRequest(String requestId, String userId) async {
    try {
      await supabase
          .from('requests')
          .update({'status': 'approved'})
          .eq('id', requestId);

      await supabase.rpc(
        'increment_score',
        params: {'uid': userId, 'value': 10},
      );
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final res = await supabase.from('profiles').select().eq('role', 'user');

      return (res as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final res = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(res);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Stream<List<RequestModel>> watchRequests() {
    late Stream<List<RequestModel>> stream;

    stream = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((e) => RequestModel.fromJson(e)).toList())
        .handleError((error) {
          print("Realtime error: $error");

          // ❗ هنا مش بنكسر الستريم
        });

    return stream;
  }

  @override
  Stream<List<UserModel>> watchUsers() {
    final stream = supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('role', 'user')
        .map((data) {
          final users = data.map((e) => UserModel.fromJson(e)).toList();

          users.sort((a, b) => b.score.compareTo(a.score));

          return users;
        });

    return SafeStream.wrap(stream);
  }

  @override
  Future<List<RequestModel>> getRequestsByDay(DateTime day) async {
    try {
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));

      final res = await supabase
          .from('requests')
          .select()
          .gte('request_date', start.toIso8601String())
          .lt('request_date', end.toIso8601String());

      return (res as List).map((e) => RequestModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
