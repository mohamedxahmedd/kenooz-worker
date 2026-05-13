import 'dart:convert';
import 'package:http/http.dart' as http;

class IPGeolocationService {
  /// Get public IP address
  static Future<String?> getPublicIP() async {
    try {
      final response = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['ip'];
      }
    } catch (e) {
      // Timeout or network error - return null
    }
    return null;
  }

  /// Get country from IP address
  static Future<String?> getCountryFromIP(String ip) async {
    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/$ip'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['country'];
      }
    } catch (e) {
      // Timeout or network error - return null
    }
    return null;
  }

  /// Combined method
  static Future<String?> getUserCountry() async {
    final ip = await getPublicIP();
    if (ip != null) {
      return await getCountryFromIP(ip);
    }
    return null;
  }
}
