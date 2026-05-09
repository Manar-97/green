import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/error_mapper.dart';
import '../models/request_dm.dart';
import '../models/user_dm.dart';
import '../../domain/repo/request_repo.dart';

@LazySingleton(as: RequestRepository)
class RequestRepositoryImpl implements RequestRepository {
  final supabase = Supabase.instance.client;

  @override
  Future<void> submitRequest({
    required String userId,
    required String wasteType,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final now = DateTime.now();

      final requestData = {
        "user_id": userId,
        "waste_type": wasteType,
        "status": "pending",
        "request_date": now.toIso8601String(),
        "request_day": now.toIso8601String().split("T")[0],
        "name": name,
        "phone": phone,
        "address": address,
      };

      await supabase.from('requests').insert(requestData);

      final profile = await supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        await supabase.from('profiles').insert({
          "id": userId,
          "name": name,
          "phone": phone,
          "address": address,
          "score": 0,
        });
      } else {
        await supabase.from('profiles').update({"score": 0}).eq('id', userId);
      }
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<List<RequestModel>> getMyRequests(String userId) async {
    try {
      final data = await supabase
          .from('requests')
          .select()
          .eq('user_id', userId)
          .order('request_date', ascending: false);

      return (data as List).map((e) => RequestModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> getProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
