import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/app_user.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _currentUserKey = 'educano.current_user';
  static const _tokenKey = 'educano.auth_token';
  static const _refreshTokenKey = 'educano.refresh_token';
  static const _sidebarExpandedKey = 'educano.sidebar_expanded';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<AppUser?> loadCurrentUser() async {
    final encodedUser = await _preferences.getString(_currentUserKey);
    if (encodedUser == null) return null;
    final decoded = jsonDecode(encodedUser);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Dados locais da conta inválidos.');
    }
    return AppUser.fromJson(decoded);
  }

  Future<void> saveCurrentUser(AppUser user) async {
    await _preferences.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearCurrentUser() async {
    await _preferences.remove(_currentUserKey);
    await _preferences.remove(_tokenKey);
    await _preferences.remove(_refreshTokenKey);
  }

  Future<String?> loadToken() => _preferences.getString(_tokenKey);

  Future<void> saveToken(String token) =>
      _preferences.setString(_tokenKey, token);

  Future<String?> loadRefreshToken() =>
      _preferences.getString(_refreshTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _preferences.setString(_refreshTokenKey, token);

  Future<bool?> loadSidebarExpanded() =>
      _preferences.getBool(_sidebarExpandedKey);

  Future<void> saveSidebarExpanded(bool expanded) =>
      _preferences.setBool(_sidebarExpandedKey, expanded);
}