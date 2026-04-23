// lib/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/auth.dart';
import '../services/token.dart';
import '../services/api_client.dart';
import 'auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _bg = Color(0xFF0D0D0D);
  static const _surface = Color(0xFF161616);
  static const _accent = Color(0xFFD4FF58);
  static const _textPrimary = Color(0xFFF0F0F0);
  static const _textSecondary = Color(0xFF888888);
  static const _border = Color(0xFF2A2A2A);

  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userJson = await TokenService.getUser();
    if (userJson != null) {
      setState(() => _user = jsonDecode(userJson) as Map<String, dynamic>);
    }
  }

  Future<void> _logout() async {
    await AuthService.logout(); // clears token + user from secure storage
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  /// Example: calling a protected API endpoint using ApiClient.
  /// The token is attached automatically — you never touch it manually.
  Future<void> _fetchProfile() async {
    final response = await ApiClient.get('/user/profile');

    if (!mounted) return;

    if (response.isUnauthorized) {
      // Token expired or invalid — log out and redirect
      await AuthService.logout();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.message),
        backgroundColor: response.success ? _accent : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56),

              // ── Header ─────────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'A',
                        style: TextStyle(
                          color: _bg,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Logout button
                  GestureDetector(
                    onTap: _logout,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _border),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // ── Welcome ────────────────────────────────────────────────────
              Text(
                'Hello,',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                _user?['name'] ?? 'User',
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _user?['email'] ?? '',
                style: const TextStyle(color: _textSecondary, fontSize: 14),
              ),

              const SizedBox(height: 48),

              // ── Example: call a protected endpoint ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _fetchProfile,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: _surface,
                  ),
                  child: const Text(
                    'Fetch Protected Profile',
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
