// lib/screens/login_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../dashboards/hod_dashboard_screen.dart';
import '../dashboards/student_dashboard_screen.dart';
import '../dashboards/teacher_dashboard_screen.dart';
import 'registration_screen.dart';
import 'forgot_password_screen.dart';

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

  // Animation controllers — unchanged
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
      vsync: this, duration: const Duration(seconds: 14),
    )..repeat();

    _cardEntryController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );

    _shakeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );

    _glowPulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _cardFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardEntryController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );

    _cardSlideAnim = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardEntryController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _shakeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _glowAnim = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut),
    );

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

  // ── Logic — unchanged ─────────────────────────────────────────
  void _handleLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _triggerShake();
      _showError('Please fill in all fields');
      return;
    }
    setState(() => _isLoading = true);
    final success = await ApiService.login(
      _userController.text.trim(), _passController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      final role = ApiService.userRole ?? 'STUDENT';
      Widget next;
      switch (role) {
        case 'HOD':     next = const HoDDashboardScreen(departmentId: 'CSE'); break;
        case 'TEACHER': next = const TeacherDashboardScreen(); break;
        default:        next = const StudentDashboardScreen();
      }
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => next,
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: AppTheme.accentPink.withOpacity(0.92),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 4),
    ));
  }
  
  void _handleRegister() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => RegistrationScreen(role: _selectedRole),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        showOrb: false, // Custom orbs below
        child: Stack(
          children: [
            // Animated orbs on top of gradient
            _buildOrbBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: AnimatedBuilder(
                    animation: _shakeAnim,
                    builder: (context, child) {
                      final offset = math.sin(_shakeAnim.value * math.pi * 6) *
                          (_shakeAnim.value > 0 ? 10.0 : 0.0) *
                          (1 - _shakeAnim.value);
                      return Transform.translate(
                        offset: Offset(offset, 0),
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
      ),
    );
  }

  // ── Orb background — adapted for light theme ──────────────────
  Widget _buildOrbBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          final t = _orbController.value * 2 * math.pi;
          final size = MediaQuery.of(context).size;
          return Stack(
            children: [
              // Role-accent orb (top-left)
              Positioned(
                left: -60 + 40 * math.sin(t * 0.6),
                top: 40 + 60 * math.cos(t * 0.4),
                child: _glowOrb(260, _roleAccent.withOpacity(0.18)),
              ),
              // White orb (top-right) — matches image top-right glow
              Positioned(
                right: -40 + 30 * math.cos(t * 0.5),
                top: -20 + 40 * math.sin(t * 0.35),
                child: _glowOrb(220, Colors.white.withOpacity(0.55)),
              ),
              // Blue orb (bottom)
              Positioned(
                left: size.width * 0.25 + 25 * math.sin(t * 0.7),
                bottom: 30 + 40 * math.cos(t * 0.5),
                child: _glowOrb(200, AppTheme.accentBlue.withOpacity(0.22)),
              ),
              // Violet accent (mid-right)
              Positioned(
                right: -30 + 20 * math.cos(t * 0.4),
                top: size.height * 0.45 + 30 * math.sin(t * 0.6),
                child: _glowOrb(160, AppTheme.accentViolet.withOpacity(0.12)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _glowOrb(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );

  // ── Login card — white frosted glass ─────────────────────────
  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B7DE9).withOpacity(0.10),
                blurRadius: 48,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.80),
                blurRadius: 1,
                offset: const Offset(0, -1),
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

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _glowAnim,
          builder: (context, _) => Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_roleAccent.withOpacity(0.20), _roleAccent.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: _roleAccent.withOpacity(0.40), width: 1.5),
              boxShadow: [
                BoxShadow(color: _roleAccent.withOpacity(_glowAnim.value * 0.5), blurRadius: 28),
                const BoxShadow(color: Colors.white, blurRadius: 1, offset: Offset(0, -1)),
              ],
            ),
            child: Icon(Icons.school_rounded, color: _roleAccent, size: 36),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Department Nuclei',
          textAlign: TextAlign.center,
          style: AppTheme.sora(fontSize: 26, fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          'Secure Login Portal',
          textAlign: TextAlign.center,
          style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary,
              letterSpacing: 0.3),
        ),
      ],
    );
  }

  // ── Role selector ─────────────────────────────────────────────
  Widget _buildRoleSelector() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF1A6FE8).withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.60)),
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
            color: isSelected ? accent.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: accent.withOpacity(0.40))
                : null,
            boxShadow: isSelected
                ? [BoxShadow(color: accent.withOpacity(0.15), blurRadius: 10)]
                : null,
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? accent : AppTheme.textMuted,
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

  // ── Input fields ──────────────────────────────────────────────
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
          _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppTheme.textMuted, size: 20,
        ),
        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
  onTap: () => Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const ForgotPasswordScreen(),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
                begin: const Offset(0, 1), end: Offset.zero)
            .animate(CurvedAnimation(
                parent: anim, curve: Curves.easeOutCubic)),
        child: FadeTransition(opacity: anim, child: child),
      ),
    ),
  ),
  child: Text(
    'Forgot password?',
    style: AppTheme.dmSans(
      fontSize: 13,
      color: AppTheme.accentBlue,
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
            colors: [_roleAccent, Color.lerp(_roleAccent, const Color(0xFF0A4FBF), 0.3)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: _roleAccent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.40), blurRadius: 1, offset: const Offset(0, -1)),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('LOGIN', style: AppTheme.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 2.0)),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1,
            color: const Color(0xFF1A6FE8).withOpacity(0.12))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('OR', style: AppTheme.dmSans(
              fontSize: 11, color: AppTheme.textMuted,
              fontWeight: FontWeight.w600, letterSpacing: 1.5)),
        ),
        Expanded(child: Container(height: 1,
            color: const Color(0xFF1A6FE8).withOpacity(0.12))),
      ],
    );
  }

  Widget _buildRegisterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _handleRegister,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _roleAccent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _roleAccent.withOpacity(0.40)),
            ),
            child: Text('Register', style: AppTheme.dmSans(
                fontSize: 13, color: _roleAccent, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlassTextField — White-glass focus animation (light theme)
// ─────────────────────────────────────────────────────────────────
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
        vsync: this, duration: const Duration(milliseconds: 200));
    _borderGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _focusCtrl, curve: Curves.easeOut));
    _focusNode.addListener(() =>
        _focusNode.hasFocus ? _focusCtrl.forward() : _focusCtrl.reverse());
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
      builder: (context, _) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              // Light fill: white on white-blue bg — semi-transparent
              color: Colors.white.withOpacity(0.60 + 0.10 * _borderGlow.value),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withOpacity(0.70),
                  widget.accentColor.withOpacity(0.70),
                  _borderGlow.value,
                )!,
                width: 1.2 + _borderGlow.value * 0.5,
              ),
              boxShadow: [
                if (_borderGlow.value > 0.1)
                  BoxShadow(
                    color: widget.accentColor.withOpacity(0.10 * _borderGlow.value),
                    blurRadius: 14,
                  ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.60),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscureText,
              style: AppTheme.dmSans(
                  fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: AppTheme.dmSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary.withOpacity(
                      _borderGlow.value > 0.5 ? 0.80 : 0.45),
                ),
                floatingLabelStyle: AppTheme.dmSans(
                    fontSize: 12, color: widget.accentColor,
                    fontWeight: FontWeight.w600),
                prefixIcon: Icon(
                  widget.prefixIcon,
                  color: Color.lerp(
                    AppTheme.textMuted,
                    widget.accentColor,
                    _borderGlow.value,
                  ),
                  size: 20,
                ),
                suffixIcon: widget.suffix,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
              cursorColor: widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}