import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";

  
// --- REGISTER USER ---
  static Future<bool> registerUser(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role, 
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        print(" Registration Blocked: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Registration Exception: $e");
      return false;
    }
  }

  static Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/check-email?email=$email'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] == true;
      }
      return false; 
    } catch (e) {
      print("Check Email Exception: $e");
      return false;
    }
  }

static Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        // 1. Tell Python this is an old-school form, NOT JSON
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        // 2. Do NOT use jsonEncode here! Pass it as a raw Map.
        // 3. You MUST use the exact key 'username', even though it is an email!
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the token and optionally save it to SharedPreferences if needed
        return data['access_token'];
      } else {
        print("Login Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Login Exception: $e");
      return null;
    }
  }


  static Future<bool> createProfile({
    required String token,
    required String fullName,
    required int age,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', 
        },
        body: jsonEncode({
          'full_name': fullName,
          'age': age,
          'gender': gender,
          'weight_kg': 70.0, 
          'height_cm': 170.0,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print("Profile Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Profile Exception: $e");
      return false;
    }
  }
}