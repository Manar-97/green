import '../../data/models/request_dm.dart';
import '../repo/request_repo.dart';

class GetMyRequests {
  final RequestRepository repo;

  GetMyRequests(this.repo);

  Future<List<RequestModel>> call(String userId) {
    return repo.getMyRequests(userId);
  }
}
