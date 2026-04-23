// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'token.dart';

class AuthResult {
  final bool success;
  final String message;
  final List? errors;
  final Map<String, dynamic>? data;
  final String? token;

  const AuthResult({
    required this.success,
    required this.message,
    this.errors,
    this.data,
    this.token,
  });
}

class AuthService {
  // ── Change to your machine's IP when testing on a physical device ─────────
  // Android emulator  → http://10.0.2.2:3000
  // iOS simulator     → http://localhost:3000
  // Physical device   → http://YOUR_LOCAL_IP:3000
  static final _baseUrl = "${Config.apiUrl}/auth";
  static const _headers = {'Content-Type': 'application/json'};

  // ── Register ──────────────────────────────────────────────────────────────
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return _post('/register', {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('/login', {
      'email': email,
      'password': password,
    });

    // Save token immediately after successful login
    if (result.success && result.token != null) {
      await TokenService.saveToken(result.token!);
      if (result.data?['user'] != null) {
        await TokenService.saveUser(jsonEncode(result.data?['user']));
      }
    }

    return result;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await TokenService.clearAll();
  }
  
  // ── Private helper ────────────────────────────────────────────────────────
  static Future<AuthResult> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl$path"),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final List errors = data['errors'] ?? [];
      return AuthResult(
        success: data['success'] == true,
        message: data['message'] as String? ?? 'There is an error in the form',
        errors: errors as List?,
        data: data['data'] as Map<String, dynamic>?,
        token: data['token'] as String?,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }
}
