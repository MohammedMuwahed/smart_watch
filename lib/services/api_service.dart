import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ⚠️ REPLACE with your PC's IP if using a real phone (e.g., http://192.168.1.15:8000)
  // Use http://10.0.2.2:8000 if using Android Emulator
  // Use http://127.0.0.1:8000 if using iOS Simulator
  static const String baseUrl = 'http://10.0.2.2:8000';

  // --- Device Control ---

  Future<bool> toggleLights(bool turnOn) async {
    final action = turnOn ? 'on' : 'off';
    // Your API expects a query parameter: /device/lights?action=on
    final url = Uri.parse('$baseUrl/device/lights?action=$action');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print("Lights toggled: $action");
        return true;
      } else {
        print("Failed to toggle lights: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error connecting to API: $e");
      return false;
    }
  }

  Future<bool> openCurtains() async {
    // Your API expects query parameter: /device/curtain?action=open
    final url = Uri.parse('$baseUrl/device/curtain?action=open');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print("Curtains opened");
        return true;
      }
      return false;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  // --- Sleep State Updates ---

  Future<void> updateSleepState(String state) async {
    // Your API expects JSON body: { "state": "sleeping" }
    final url = Uri.parse('$baseUrl/state/update');

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode({"state": state}));

      if (response.statusCode == 200) {
        print("Server state updated to: $state");
      } else {
        print("Server rejected state update: ${response.body}");
      }
    } catch (e) {
      print("Error updating state: $e");
    }
  }
}
