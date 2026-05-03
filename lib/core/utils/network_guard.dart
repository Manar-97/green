import 'dart:io';
import 'package:http/http.dart' as http;

class NetworkGuard {
  static Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        final response = await http
            .get(Uri.parse("https://clients3.google.com/generate_204"))
            .timeout(const Duration(seconds: 3));

        return response.statusCode == 204;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}
