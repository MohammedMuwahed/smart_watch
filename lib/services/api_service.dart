import 'dart:convert';
import 'dart:developer' as developer; // Import developer for logging
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ CRITICAL FIX:
  // - If using Android Emulator: Use 'http://10.0.2.2:8000'
  // - If using Real Device: Use your PC's IP (e.g., 'http://192.168.1.15:8000')
  // - '0.0.0.0' WILL NOT WORK on the emulator or phone.
  static const String baseUrl = 'http://10.0.2.2:8000';
  // static const String baseUrl = 'https://smartwatch-university-project.web.app';

  // --- Device Control ---

  Future<bool> isSleeping() async {
    final url = Uri.parse('$baseUrl/state/is-sleeping');

    try {
      final response = await http.get(url);

      developer.log("📥 Raw Server Response Code: ${response.statusCode}", name: 'ApiService');
      developer.log("📦 Raw Server Body: ${response.body}", name: 'ApiService');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final bool status = data['isSleeping'] ?? false;

        developer.log("Fetched Sleep Status: $status", name: 'ApiService');
        return status;
      } else {
        developer.log("Server Error: ${response.statusCode}", name: 'ApiService', error: response.body);
        return false;
      }
    } catch (e) {
      developer.log("Error connecting to API", name: 'ApiService', error: e);
      return false;
    }
  }

  Future<void> sleepingSetting(String device, String setting, bool value) async {
    final url = Uri.parse('$baseUrl/device/update-setting');

    try {
      final response = await http.post(url,
          headers: {"Content-Type": "application/json"}, body: jsonEncode({"device": device, "setting": setting, "value": value}));

      if (response.statusCode == 200) {
        developer.log("Server device setting updated to: $setting to $value", name: 'ApiService');
      } else {
        developer.log("Server rejected device setting update: ${response.body}", name: 'ApiService');
      }
    } catch (e) {
      developer.log("Error in sleepingSetting", name: 'ApiService', error: e);
    }
  }
}
