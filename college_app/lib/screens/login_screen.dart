// lib/screens/login_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'hod_dashboard_screen.dart';
import 'student_dashboard_screen.dart';
import 'teacher_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  String _selectedRole = 'Student';
  final List<String> _roles = ['Student', 'Faculty', 'HOD'];

  // Animation controllers
  late AnimationController _orbController;
  late AnimationController _cardEntryController;
  late AnimationController _shakeController;
  late AnimationController _glowPulseController;

  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _shakeAnim;
  late Animation<double> _glowAnim;

  Color get _roleAccent {
    switch (_selectedRole) {
      case 'Faculty': return AppTheme.accentTeal;
      case 'HOD':     return AppTheme.accentViolet;
      default:        return AppTheme.accentBlue;
    }
  }

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();

    _cardEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _glowPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _cardFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardEntryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _cardSlideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardEntryController, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );

    // Start entry
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardEntryController.forward();
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _cardEntryController.dispose();
    _shakeController.dispose();
    _glowPulseController.dispose();
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _triggerShake();
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    final success = await ApiService.login(
      _userController.text.trim(),
      _passController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final role = ApiService.userRole ?? 'STUDENT';
      Widget next;
      switch (role) {
        case 'HOD':
          next = const HoDDashboardScreen(departmentId: 'CSE'); break;
        case 'TEACHER':
          next = const TeacherDashboardScreen(); break;
        default:
          next = const StudentDashboardScreen();
      }
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => next,
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      _triggerShake();
      _showError('Invalid credentials. Please try again.');
    }
  }

  void _triggerShake() {
    _shakeController.reset();
    _shakeController.forward();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: AppTheme.accentPink.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset link will be sent to your registered email'),
        backgroundColor: AppTheme.accentBlue.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _handleRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration feature coming soon!'),
        backgroundColor: AppTheme.accentViolet.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Stack(
        children: [
          // Animated orb background
          _buildOrbBackground(),
          // Noise overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/2/25/Abstract_noise.svg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          // Main content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) {
                    final shakeOffset = math.sin(_shakeAnim.value * math.pi * 6) *
                        (_shakeAnim.value > 0 ? 10.0 : 0.0) *
                        (1 - _shakeAnim.value);
                    return Transform.translate(
                      offset: Offset(shakeOffset, 0),
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _cardFadeAnim,
                    child: SlideTransition(
                      position: _cardSlideAnim,
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Orb background ──────────────────────────────────────────────
  Widget _buildOrbBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          final t = _orbController.value * 2 * math.pi;
          final size = MediaQuery.of(context).size;

          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0A0A0F),
                      Color(0xFF0D0D1A),
                      Color(0xFF0E0E22),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Orb 1 - Role accent
              Positioned(
                left: -80 + 50 * math.sin(t * 0.6),
                top: 60 + 80 * math.cos(t * 0.4),
                child: _glowOrb(280, _roleAccent.withOpacity(0.22)),
              ),
              // Orb 2 - Violet
              Positioned(
                right: -60 + 40 * math.cos(t * 0.5),
                bottom: size.height * 0.35 + 60 * math.sin(t * 0.3),
                child: _glowOrb(320, AppTheme.accentViolet.withOpacity(0.14)),
              ),
              // Orb 3 - Teal
              Positioned(
                left: size.width * 0.3 + 30 * math.sin(t * 0.7),
                bottom: 40 + 50 * math.cos(t * 0.5),
                child: _glowOrb(200, AppTheme.accentTeal.withOpacity(0.10)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  // ── Login card ──────────────────────────────────────────────────
  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.07),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFFFFFFF).withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildRoleSelector(),
              const SizedBox(height: 24),
              _buildInput(
                controller: _userController,
                label: _inputLabel,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildPasswordInput(),
              const SizedBox(height: 8),
              _buildForgotPassword(),
              const SizedBox(height: 24),
              _buildLoginButton(),
              const SizedBox(height: 20),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildRegisterRow(),
            ],
          ),
        ),
      ),
    );
  }

  String get _inputLabel {
    switch (_selectedRole) {
      case 'Faculty': return 'Employee ID';
      case 'HOD':     return 'Employee ID';
      default:        return 'Roll Number / Regd. No.';
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Animated glow logo
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, _) => Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _roleAccent.withOpacity(0.12),
              border: Border.all(color: _roleAccent.withOpacity(0.30), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _roleAccent.withOpacity(_glowAnim.value),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Icon(Icons.school_rounded, color: _roleAccent, size: 36),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Department Nuclei',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Secure Login Portal',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary.withOpacity(0.50),
            fontSize: 13,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Role selector pills ─────────────────────────────────────────
  Widget _buildRoleSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.08)),
          ),
          child: Row(
            children: _roles.map((role) => _buildRolePill(role)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRolePill(String role) {
    final isSelected = _selectedRole == role;
    final accent = _accentForRole(role);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? accent.withOpacity(0.20) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: accent.withOpacity(0.50))
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: accent.withOpacity(0.25), blurRadius: 12)]
                : null,
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? accent : AppTheme.textPrimary.withOpacity(0.45),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'Faculty': return AppTheme.accentTeal;
      case 'HOD':     return AppTheme.accentViolet;
      default:        return AppTheme.accentBlue;
    }
  }

  // ── Glass input field ───────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return _GlassTextField(
      controller: controller,
      label: label,
      prefixIcon: icon,
      accentColor: _roleAccent,
    );
  }

  Widget _buildPasswordInput() {
    return _GlassTextField(
      controller: _passController,
      label: 'Password',
      prefixIcon: Icons.lock_outline_rounded,
      obscureText: !_isPasswordVisible,
      accentColor: _roleAccent,
      suffix: IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppTheme.textPrimary.withOpacity(0.45),
          size: 20,
        ),
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _handleForgotPassword,
        child: Text(
          'Forgot Password?',
          style: TextStyle(
            color: _roleAccent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _roleAccent,
              _roleAccent.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: _roleAccent.withOpacity(0.40),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: const Color(0xFFFFFFFF).withOpacity(0.08)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'OR',
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.30),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: const Color(0xFFFFFFFF).withOpacity(0.08)),
        ),
      ],
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: AppTheme.textPrimary.withOpacity(0.50),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _handleRegister,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _roleAccent.withOpacity(0.50)),
            ),
            child: Text(
              'Register',
              style: TextStyle(
                color: _roleAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Glass text field widget ───────────────────────────────────────
class _GlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData prefixIcon;
  final bool obscureText;
  final Color accentColor;
  final Widget? suffix;

  const _GlassTextField({
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.accentColor,
    this.obscureText = false,
    this.suffix,
  });

  @override
  State<_GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<_GlassTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusCtrl;
  late Animation<double> _borderGlow;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _borderGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut),
    );
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _focusCtrl.forward();
      } else {
        _focusCtrl.reverse();
      }
    });
  }

  @override
  void dispose() {
    _focusCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _borderGlow,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF).withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Color.lerp(
                    const Color(0xFFFFFFFF).withOpacity(0.10),
                    widget.accentColor.withOpacity(0.60),
                    _borderGlow.value,
                  )!,
                  width: 1 + _borderGlow.value * 0.5,
                ),
                boxShadow: [
                  if (_borderGlow.value > 0.1)
                    BoxShadow(
                      color: widget.accentColor.withOpacity(0.12 * _borderGlow.value),
                      blurRadius: 16,
                    ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                obscureText: widget.obscureText,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(
                    color: AppTheme.textPrimary.withOpacity(
                      _borderGlow.value > 0.5 ? 0.85 : 0.45,
                    ),
                    fontSize: 14,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: widget.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    widget.prefixIcon,
                    color: Color.lerp(
                      AppTheme.textPrimary.withOpacity(0.35),
                      widget.accentColor,
                      _borderGlow.value,
                    ),
                    size: 20,
                  ),
                  suffixIcon: widget.suffix,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16,
                  ),
                ),
                cursorColor: widget.accentColor,
              ),
            ),
          ),
        );
      },
    );
  }
}