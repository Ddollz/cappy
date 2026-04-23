// lib/auth_screen.dart

import 'package:flutter/material.dart';
import '../services/auth.dart';
import 'home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  static const _bg = Color(0xFF0D0D0D);
  static const _surface = Color(0xFF161616);
  static const _accent = Color(0xFFD4FF58);
  static const _accentDim = Color(0xFF8FAA2A);
  static const _textPrimary = Color(0xFFF0F0F0);
  static const _textSecondary = Color(0xFF888888);
  static const _border = Color(0xFF2A2A2A);
  static const _errorColor = Color(0xFFFF5757);

  // ── API field errors (cleared on every new submit attempt) ─────────────────
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animController.reset();
    setState(() {
      _isLogin = !_isLogin;
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });
    _animController.forward();
    _formKey.currentState?.reset();
    _emailCtrl.clear();
    _passwordCtrl.clear();
    _confirmCtrl.clear();
    _nameCtrl.clear();
  }

  void _applyApiErrors(List<dynamic> errors) {
    _nameError = errors.firstWhere(
      (u) => u['path'] == 'name',
      orElse: () => {},
    )['msg'];
    _emailError = errors.firstWhere(
      (u) => u['path'] == 'email',
      orElse: () => {},
    )['msg'];
    _passwordError = errors.firstWhere(
      (u) => u['path'] == 'password',
      orElse: () => {},
    )['msg'];
    _confirmError = errors.firstWhere(
      (u) => u['path'] == 'confirmPassword',
      orElse: () => {},
    )['msg'];
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
    });

    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final AuthResult result;
    if (_isLogin) {
      result = await AuthService.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      result = await AuthService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
    }

    setState(() => _isLoading = false);
    if (!mounted) return;
    if (result.success) {
      _showSnackbar(
        _isLogin
            ? '✓ Welcome back, ${result.data?['user']?['name'] ?? ''}!'
            : '✓ Account created!',
        isError: false,
      );
      if(!_isLogin){
        _toggleMode();
      }
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _applyApiErrors(result.errors!));
      _formKey.currentState!.validate();
      _showSnackbar(result.message, isError: true);
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? _errorColor : _accent,
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : _bg,
            fontWeight: FontWeight.w700,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BgPainter())),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 56),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildToggleTabs(),
                  const SizedBox(height: 36),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildForm(),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildSubmitButton(),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 40),
                  _buildFooterToggle(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          _isLogin ? 'Welcome\nback.' : 'Create your\naccount.',
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isLogin
              ? 'Sign in to continue where you left off.'
              : 'Join thousands of users today.',
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [_tab('Login', _isLogin), _tab('Register', !_isLogin)],
      ),
    );
  }

  Widget _tab(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if ((label == 'Login') != _isLogin) _toggleMode();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? _accent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? _bg : _textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!_isLogin) ...[
            _field(
              ctrl: _nameCtrl,
              label: 'Full Name',
              hint: 'John Doe',
              icon: Icons.person_outline_rounded,
              onChanged: (_) {
                if (_nameError != null) {
                  setState(() => _nameError = null);
                  _formKey.currentState!.validate();
                }
              },
              validator: (v) {
                if (_nameError != null) return _nameError;
                if (v == null || v.trim().isEmpty) return 'Name is required';
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          _field(
            ctrl: _emailCtrl,
            label: 'Email Address',
            hint: 'you@example.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) {
              if (_emailError != null) {
                setState(() => _emailError = null);
                _formKey.currentState!.validate();
              }
            },
            validator: (v) {
              if (_emailError != null) return _emailError;
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _field(
            ctrl: _passwordCtrl,
            label: 'Password',
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            onChanged: (_) {
              if (_passwordError != null) {
                setState(() => _passwordError = null);
                _formKey.currentState!.validate();
              }
            },
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (_passwordError != null) return _passwordError;
              if (v == null || v.isEmpty) return 'Password is required';
              if (v.length < 6) return 'At least 6 characters';
              return null;
            },
          ),
          if (!_isLogin) ...[
            const SizedBox(height: 16),
            _field(
              ctrl: _confirmCtrl,
              label: 'Confirm Password',
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              onChanged: (_) {
                if (_confirmError != null) {
                  setState(() => _confirmError = null);
                  _formKey.currentState!.validate();
                }
              },
              obscure: _obscureConfirm,
              suffix: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) {
                if (_confirmError != null) return _confirmError;
                if (v == null || v.isEmpty) return 'Please confirm password';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),
          ],
          if (_isLogin) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(color: _textPrimary, fontSize: 15),
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF444444), fontSize: 15),
            prefixIcon: Icon(icon, color: _textSecondary, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: _surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _errorColor, width: 1.5),
            ),
            errorStyle: const TextStyle(color: _errorColor, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: _bg,
          disabledBackgroundColor: _accentDim,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: _bg),
              )
            : Text(
                _isLogin ? 'Sign In' : 'Create Account',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: _border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: TextStyle(color: _textSecondary, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: _border, thickness: 1)),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      children: [
        Expanded(child: _socialBtn('Google', Icons.language_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _socialBtn('Apple', Icons.apple)),
      ],
    );
  }

  Widget _socialBtn(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: _textPrimary),
      label: Text(
        label,
        style: const TextStyle(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: _surface,
      ),
    );
  }

  Widget _buildFooterToggle() {
    return Center(
      child: GestureDetector(
        onTap: _toggleMode,
        child: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 14),
            children: [
              TextSpan(
                text: _isLogin
                    ? "Don't have an account? "
                    : 'Already have an account? ',
                style: const TextStyle(color: _textSecondary),
              ),
              TextSpan(
                text: _isLogin ? 'Register' : 'Sign in',
                style: const TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFFD4FF58).withOpacity(0.04);
    canvas.drawCircle(Offset(size.width + 60, -80), 220, paint);
    paint.color = const Color(0xFFD4FF58).withOpacity(0.025);
    canvas.drawCircle(Offset(-60, size.height + 60), 180, paint);
    final linePaint = Paint()
      ..color = const Color(0xFF1E1E1E)
      ..strokeWidth = 1;
    for (double y = 80; y < size.height; y += 80) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
