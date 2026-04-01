import 'package:shared_preferences/shared_preferences.dart';

/// Local session flags (no backend). Aligns with U-FR-1-1 role + sign-in UX.
class AppSession {
  static const String keyLoggedIn = 'loggedIn';
  static const String keyUserEmail = 'userEmail';
  static const String keyDisplayName = 'displayName';
  static const String keyUserRole = 'userRole';
  static const String keyRememberEmail = 'rememberEmail';
  static const String keyOnboardingComplete = 'onboardingComplete';

  /// Wellness app user vs healthcare professional (U-FR-1-1) vs admin (S-FR-5).
static const String roleMember = 'User';
  static const String roleHealthcareProfessional = 'Healthcare Professional';
  static const String roleAdmin = 'Admin';

  static String homeRouteForRole(String? role) {
    switch (role) {
      case roleAdmin:
        return '/admin';
      case roleHealthcareProfessional:
        return '/healthcare';
      default:
        return '/dashboard';
    }
  }

  static Future<void> saveSignIn({
    required String email,
    required String role,
    String? displayName,
    bool rememberEmail = true,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(keyLoggedIn, true);
    await p.setString(keyUserEmail, email.trim());
    await p.setString(keyUserRole, role);
    if (displayName != null && displayName.trim().isNotEmpty) {
      await p.setString(keyDisplayName, displayName.trim());
    }
    if (rememberEmail) {
      await p.setString(keyRememberEmail, email.trim());
    } else {
      await p.remove(keyRememberEmail);
    }
  }

  static Future<void> saveAfterOnboarding({
    required String email,
    required String displayName,
    required String role,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(keyOnboardingComplete, true);
    await p.setBool(keyLoggedIn, true);
    await p.setString(keyUserEmail, email.trim());
    await p.setString(keyDisplayName, displayName.trim());
    await p.setString(keyUserRole, role);
  }

  static Future<void> signOut() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(keyLoggedIn, false);
    await p.remove(keyUserEmail);
    await p.remove(keyDisplayName);
    await p.remove(keyUserRole);
  }

  static Future<String?> rememberedEmail() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(keyRememberEmail);
  }
}
