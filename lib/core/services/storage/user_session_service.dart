import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

// UserSessionService provider
final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return UserSessionService(prefs: prefs);
});

class UserSessionService {
  final SharedPreferences _prefs;

  // Keys for storing user data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserName = 'user_name';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserNumber = 'user_number';
  static const String _keyUserProfilePicture = 'user_profile_picture';
  static const String _keyUserIsPremium = 'user_is_premium';

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  // Save user session after login
  Future<void> saveUserSession({
    required String userId,
    required String email,
    required String name,
    String? role,
    String? number,
    String? profilePicture,
    bool? isPremium,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyUserEmail, email);
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserRole, role ?? "");
    await _prefs.setString(_keyUserNumber, number ?? "");
    await _prefs.setBool(_keyUserIsPremium, isPremium ?? false);
    if (profilePicture != null) {
      await _prefs.setString(_keyUserProfilePicture, profilePicture);
    }
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _prefs.getString(_keyUserId);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _prefs.getString(_keyUserEmail);
  }

  // Get current user full name
  String? getCurrentUserFullName() {
    return _prefs.getString(_keyUserName);
  }

  // Get current user role
  String? getCurrentUserRole() {
    return _prefs.getString(_keyUserRole);
  }

  // Get current user phone number
  String? getCurrentUserPhoneNumber() {
    return _prefs.getString(_keyUserNumber);
  }

  // Get current user profile picture
  String? getCurrentUserProfilePicture() {
    return _prefs.getString(_keyUserProfilePicture);
  }

  bool getCurrentUserIsPremium() {
    return _prefs.getBool(_keyUserIsPremium) ?? false;
  }

  Future<void> setCurrentUserIsPremium(bool isPremium) async {
    await _prefs.setBool(_keyUserIsPremium, isPremium);
  }

  // Clear user session (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyUserEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyUserRole);
    await _prefs.remove(_keyUserNumber);
    await _prefs.remove(_keyUserProfilePicture);
    await _prefs.remove(_keyUserIsPremium);
  }
}
