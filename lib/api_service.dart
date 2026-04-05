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

  /// Fetch the logged-in user's profile (returns full_name, age, etc.)
  static Future<Map<String, dynamic>?> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      // 404 = no profile yet, that's normal for new users
      return null;
    } catch (e) {
      return null;
    }
  }

  // send a message to the AI chatbot
  static Future<Map<String, dynamic>?> chatbot(String token, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chatbot'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'user_message': message}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Chatbot Exception: $e");
      return null;
    }
  }

  // load past chatbot conversations
  static Future<List<dynamic>> chatbotHistory(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chatbot/history'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Chatbot History Exception: $e");
      return [];
    }
  }

  // get gamification stats
  static Future<Map<String, dynamic>?> getGamification(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gamification'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Gamification Exception: $e");
      return null;
    }
  }

  // get leaderboard
  static Future<List<dynamic>> getLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/leaderboard'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Leaderboard Exception: $e");
      return [];
    }
  }

  // get earned badges
  static Future<List<dynamic>> getBadges(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/badges'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Badges Exception: $e");
      return [];
    }
  }

  // generic authenticated GET helper
  static Future<List<dynamic>> getList(String token, String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
      return [];
    } catch (e) {
      // network errors on web are common, don't spam console
      return [];
    }
  }

  // authenticated GET that returns a single object (not a list)
  static Future<Map<String, dynamic>?> getMap(String token, String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("GET $endpoint Exception: $e");
      return null;
    }
  }

  // generic authenticated POST helper
  static Future<Map<String, dynamic>?> postData(String token, String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // generic authenticated PUT helper
  static Future<Map<String, dynamic>?> putData(String token, String endpoint, [Map<String, dynamic>? body]) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body != null ? jsonEncode(body) : null,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("PUT $endpoint Exception: $e");
      return null;
    }
  }

  // generic authenticated DELETE helper
  static Future<bool> deleteData(String token, String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("DELETE $endpoint Exception: $e");
      return false;
    }
  }
}