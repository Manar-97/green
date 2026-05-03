import 'network_guard.dart';

class SafeStream {
  static Stream<T> wrap<T>(Stream<T> stream) {
    return stream.handleError((error) {
      print("Realtime error ignored: $error");
    });
  }
}

Future<T> safeCall<T>(Future<T> Function() action) async {
  final hasNet = await NetworkGuard.hasInternet();

  if (!hasNet) {
    throw Exception("NO_INTERNET");
  }

  return await action();
}
