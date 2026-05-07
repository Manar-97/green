import '../../../user/data/models/request_dm.dart';
import '../../../user/data/models/user_dm.dart';

abstract class AdminRepository {
  // 🔵 one-time fetch (initial load)
  Future<List<RequestModel>> getAllRequests();
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> getProfile(String userId);
  Future<void> deleteRequest(String requestId);
  // 🟢 realtime streams (LIVE updates)
  Stream<List<RequestModel>> watchRequests();
  Stream<List<UserModel>> watchUsers();

  // 🟡 actions (write operations)
  Future<void> approveRequest(String requestId, String userId);

  Future<List<RequestModel>> getRequestsByDay(DateTime day);
}
