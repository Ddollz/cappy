// lib/splash_screen.dart
import 'package:flutter/material.dart';
import '../services/token.dart';
import 'auth.dart';
import 'home.dart';

/// Shown briefly at launch. Checks for a saved token and routes
/// the user to HomeScreen (already logged in) or AuthScreen (not logged in).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _bg = Color(0xFF0D0D0D);
  static const _accent = Color(0xFFD4FF58);

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    // Small delay so the splash is visible
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final hasToken = await TokenService.hasToken();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => hasToken ? const HomeScreen() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    color: _bg,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
            ),
          ],
        ),
      ),
    );
  }
}
