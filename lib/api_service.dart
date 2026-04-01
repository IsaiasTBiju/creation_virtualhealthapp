import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Use 127.0.0.1 for web/Chrome. If using an Android Emulator later, change to 10.0.2.2
  static const String baseUrl = "http://127.0.0.1:8000";

  
  static Future<bool> registerUser(String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Registration Error: $e");
      return false;
    }
  }

  
  static Future<String?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {
          'username': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];
        
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        
        return token;
      }
      return null;
    } catch (e) {
      print("Login Error: $e");
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