import '../../data/models/request_dm.dart';
import '../../data/models/user_dm.dart';

abstract class RequestRepository {
  Future<void> submitRequest({
    required String userId,
    required String wasteType,
    required String name,
    required String phone,
    required String nationalId,
    required String address,
  });
  Future<List<RequestModel>> getMyRequests(String userId);
  Future<UserModel> getProfile(String userId);
}
