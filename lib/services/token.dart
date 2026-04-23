// lib/services/token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  // ── Save ────────────────────────────────────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  // ── Read ────────────────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  static Future<String?> getUser() async {
    return _storage.read(key: _userKey);
  }

  static Future<bool> hasToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Delete (logout) ─────────────────────────────────────────────────────────
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
