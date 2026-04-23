// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token.dart';

/// A thin wrapper around http that automatically:
///   1. Attaches `Authorization: Bearer <token>` to every request
///   2. Returns a decoded Map so callers never touch jsonDecode
///   3. Returns statusCode so callers can react to 401 / 403
class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // ── Public methods ──────────────────────────────────────────────────────────

  static Future<ApiResponse> get(String path) async {
    final headers = await _buildHeaders();
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  static Future<ApiResponse> post(
    String path,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final headers = await _buildHeaders(requiresAuth: requiresAuth);
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  static Future<ApiResponse> put(String path, Map<String, dynamic> body) async {
    final headers = await _buildHeaders();
    final response = await http
        .put(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  static Future<ApiResponse> delete(String path) async {
    final headers = await _buildHeaders();
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(const Duration(seconds: 10));
    return _parse(response);
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  static Future<Map<String, String>> _buildHeaders({
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await TokenService.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  static ApiResponse _parse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse(
        statusCode: response.statusCode,
        data: data,
        success: data['success'] == true,
        message: data['message']?.toString() ?? '',
      );
    } catch (_) {
      return ApiResponse(
        statusCode: response.statusCode,
        data: {},
        success: false,
        message: 'Failed to parse server response',
      );
    }
  }
}

class ApiResponse {
  final int statusCode;
  final Map<String, dynamic> data;
  final bool success;
  final String message;

  const ApiResponse({
    required this.statusCode,
    required this.data,
    required this.success,
    required this.message,
  });

  /// Convenience: true when the server returned 401 Unauthorized
  bool get isUnauthorized => statusCode == 401;
}
