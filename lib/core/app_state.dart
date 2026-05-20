import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_api.dart';

class AppState {
  static const _loggedInKey = 'loggedIn';
  static const _userInfoKey = 'userInfoDone';

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loggedInKey) ?? false;
  }

  static Future<bool> hasUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_userInfoKey) ?? false;
  }

  static Future<void> setLoggedIn(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loggedInKey, v);
  }

  static Future<void> setUserInfoDone(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_userInfoKey, v);
  }

  static const _usernameKey = 'username';

  // 🧪 TESTER VERIFICATION (PERSISTED)
  static const _testerVerifiedKey = 'testerVerified';
  static const _lastVerifiedCodeKey = 'lastVerifiedCode';

  static Future<bool> isTesterVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_testerVerifiedKey) ?? false;
  }

  static Future<void> setTesterVerified(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_testerVerifiedKey, v);
  }

  static Future<String?> getLastVerifiedCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastVerifiedCodeKey);
  }

  static Future<void> setLastVerifiedCode(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_lastVerifiedCodeKey);
    } else {
      await prefs.setString(_lastVerifiedCodeKey, code);
    }
  }

  // 👤 USERNAME
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<void> setUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, name);
  }

  // 📧 EMAIL
  static const _emailKey = 'email';
  static Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // 🔔 REMINDERS
  static const _reminderPrefix = 'reminder_';
  
  static Future<String?> getReminderTime(String mealKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_reminderPrefix$mealKey');
  }

  static Future<void> setReminderTime(String mealKey, String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_reminderPrefix$mealKey', time);
  }

  static Future<bool> isReminderEnabled(String mealKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_reminderPrefix}enabled_$mealKey') ?? false;
  }

  static Future<void> setReminderEnabled(String mealKey, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_reminderPrefix}enabled_$mealKey', enabled);
  }

  // 🎨 THEME
  static const _themeKey = 'currentTheme';

  static Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'default';
  }

  static Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  static Future<void> logout() async {
    // 🧪 Release code if verified
    try {
      final code = await getLastVerifiedCode();
      if (code != null) {
        // 🆕 Add timeout to prevent hanging
        await UserApi.releaseTesterCode(code).timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            print('Logout API timeout - proceeding with local logout');
          },
        );
      }
    } catch (e) {
      // ⚠️ Ignore network errors, prioritize local logout
      print('Logout API error: $e');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // This clears everything including verified status
  }
}
