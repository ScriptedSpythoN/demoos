// lib/screens/change_password_screen.dart
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'forgot_password_screen.dart' show FpGlassField, FpActionButton;
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  final String uniqueId;
  const ChangePasswordScreen({super.key, required this.uniqueId});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with TickerProviderStateMixin {

  // ── Controllers ───────────────────────────────────────────────
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _submitting = false;

  // ── Animations ────────────────────────────────────────────────
  late AnimationController _orbCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _shakeCtrl;
  late AnimationController _successCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _glow;
  late Animation<double> _shake;
  late Animation<double> _successScale;
  late Animation<double> _successFade;

  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))
      ..repeat();

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));

    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));

    _cardFade = CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut));

    _cardSlide = Tween<Offset>(
            begin: const Offset(0, 0.07), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.72,
                curve: Curves.easeOutCubic)));

    _glow = Tween<double>(begin: 0.28, end: 0.55).animate(
        CurvedAnimation(
            parent: _glowCtrl, curve: Curves.easeInOut));

    _shake = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: -9.0), weight: 1),
      TweenSequenceItem(
          tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: 9.0, end: -6.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(
          tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));

    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut));

    _successFade = CurvedAnimation(
        parent: _successCtrl, curve: Curves.easeOut);

    // Re-validate password strength whenever new pass changes
    _newPassCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Password validation helpers ────────────────────────────────
  bool get _hasMinLen   => _newPassCtrl.text.length >= 8;
  bool get _hasUpper    => _newPassCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber   => _newPassCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial  => _newPassCtrl.text
      .contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));
  bool get _passValid =>
      _hasMinLen && _hasUpper && _hasNumber && _hasSpecial;

  /// 0–4 strength score
  int get _strengthScore {
    int s = 0;
    if (_hasMinLen)  s++;
    if (_hasUpper)   s++;
    if (_hasNumber)  s++;
    if (_hasSpecial) s++;
    return s;
  }

  Color get _strengthColor {
    switch (_strengthScore) {
      case 0: return AppTheme.textMuted;
      case 1: return AppTheme.accentPink;
      case 2: return AppTheme.accentAmber;
      case 3: return const Color(0xFF60C8F5); // light blue
      case 4: return AppTheme.accentTeal;
      default: return AppTheme.textMuted;
    }
  }

  String get _strengthLabel {
    switch (_strengthScore) {
      case 0: return '';
      case 1: return 'Weak';
      case 2: return 'Fair';
      case 3: return 'Good';
      case 4: return 'Strong';
      default: return '';
    }
  }

  // ── Submit handler ─────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    final current  = _currentPassCtrl.text;
    final newPass  = _newPassCtrl.text;
    final confirm  = _confirmPassCtrl.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _triggerShake();
      _snack('All fields are required.', isError: true);
      return;
    }
    if (!_passValid) {
      _triggerShake();
      _snack(
          'Password must be 8+ chars with uppercase, number & special char.',
          isError: true);
      return;
    }
    if (newPass != confirm) {
      _triggerShake();
      _snack('New password and confirm password do not match.',
          isError: true);
      return;
    }

    setState(() => _submitting = true);
    // TODO: Replace with actual API call:
    // await ApiService.changePassword(
    //   uniqueId: widget.uniqueId,
    //   currentPassword: current,
    //   newPassword: newPass,
    // );
    await Future.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;

    setState(() { _submitting = false; _showSuccess = true; });
    _successCtrl.forward();

    // Redirect to LoginScreen after brief success display
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  void _triggerShake() {
    _shakeCtrl.reset();
    _shakeCtrl.forward();
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white, size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(msg,
                  style: AppTheme.dmSans(
                      fontSize: 13, color: Colors.white))),
        ]),
        backgroundColor: isError
            ? AppTheme.accentPink.withOpacity(0.94)
            : AppTheme.accentTeal.withOpacity(0.94),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ));
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: Stack(children: [
          _buildOrbs(),
          SafeArea(
            child: Column(children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: AnimatedBuilder(
                        animation: _shake,
                        builder: (_, child) => Transform.translate(
                          offset: Offset(_shake.value, 0),
                          child: child,
                        ),
                        child: _buildCard(),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          // ── Success overlay ─────────────────────────────────
          if (_showSuccess) _buildSuccessOverlay(),
        ]),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.14)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textSecondary, size: 17),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('Change Your Password',
                style: AppTheme.sora(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Set a new secure password',
                style: AppTheme.dmSans(
                    fontSize: 12, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  // ── Main card ──────────────────────────────────────────────────
  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary.withOpacity(0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color: Colors.white.withOpacity(0.10), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.accentViolet.withOpacity(0.12),
                  blurRadius: 48,
                  offset: const Offset(0, 16)),
            ],
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            _buildHeader(),
            const SizedBox(height: 28),

            // ── Current password ───────────────────────────
            FpGlassField(
              controller: _currentPassCtrl,
              label: 'Current Password',
              hint: 'Enter current password',
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              exampleHint: 'e.g. John@2018',
            ),
            const SizedBox(height: 16),

            // ── New password ───────────────────────────────
            FpGlassField(
              controller: _newPassCtrl,
              label: 'New Password',
              hint: 'Enter new password',
              icon: Icons.lock_reset_rounded,
              isPassword: true,
              exampleHint: 'e.g. John@2018',
            ),

            // Strength bar (only shows when user starts typing)
            if (_newPassCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildStrengthBar(),
            ],
            const SizedBox(height: 16),

            // ── Confirm password ───────────────────────────
            FpGlassField(
              controller: _confirmPassCtrl,
              label: 'Confirm Password',
              hint: 'Confirm new password',
              icon: Icons.lock_person_outlined,
              isPassword: true,
              exampleHint: 'e.g. John@2018',
            ),
            const SizedBox(height: 20),

            // ── Password rules info text ───────────────────
            _buildRulesRow(),
            const SizedBox(height: 26),

            // ── Submit button ──────────────────────────────
            FpActionButton(
              label: 'Submit',
              loading: _submitting,
              accent: AppTheme.accentViolet,
              onTap: _handleSubmit,
            ),
          ]),
        ),
      ),
    );
  }

  // ── Header icon ────────────────────────────────────────────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Column(children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.accentViolet.withOpacity(0.22),
              AppTheme.accentViolet.withOpacity(0.03),
            ]),
            border: Border.all(
                color: AppTheme.accentViolet.withOpacity(0.40),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.accentViolet
                      .withOpacity(_glow.value * 0.52),
                  blurRadius: 32),
            ],
          ),
          child: const Icon(Icons.key_rounded,
              color: AppTheme.accentViolet, size: 30),
        ),
        const SizedBox(height: 14),
        Text('Set New Password',
            textAlign: TextAlign.center,
            style: AppTheme.sora(
                fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text('Choose a strong, unique password',
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5)),
      ]),
    );
  }

  // ── Password strength bar ──────────────────────────────────────
  Widget _buildStrengthBar() {
    return Row(children: [
      // 4 segments
      Expanded(
        child: Row(
          children: List.generate(4, (i) {
            final filled = i < _strengthScore;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: filled
                      ? _strengthColor
                      : Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: filled
                      ? [
                          BoxShadow(
                              color: _strengthColor.withOpacity(0.40),
                              blurRadius: 6)
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ),
      const SizedBox(width: 10),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Text(
          _strengthLabel,
          key: ValueKey(_strengthLabel),
          style: AppTheme.dmSans(
              fontSize: 11,
              color: _strengthColor,
              fontWeight: FontWeight.w700),
        ),
      ),
    ]);
  }

  // ── Validation rules row ───────────────────────────────────────
  Widget _buildRulesRow() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _ruleChip('8+ chars', _hasMinLen),
        _ruleChip('Uppercase', _hasUpper),
        _ruleChip('Number', _hasNumber),
        _ruleChip('Special char', _hasSpecial),
      ],
    );
  }

  Widget _ruleChip(String label, bool met) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding:
          const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: met
            ? AppTheme.accentTeal.withOpacity(0.12)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: met
              ? AppTheme.accentTeal.withOpacity(0.40)
              : Colors.white.withOpacity(0.10),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          met
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: met
              ? AppTheme.accentTeal
              : AppTheme.textMuted.withOpacity(0.50),
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(label,
            style: AppTheme.dmSans(
                fontSize: 11,
                color: met
                    ? AppTheme.accentTeal
                    : AppTheme.textMuted.withOpacity(0.55),
                fontWeight: FontWeight.w500)),
      ]),
    );
  }

  // ── Success overlay ────────────────────────────────────────────
  Widget _buildSuccessOverlay() {
    return Positioned.fill(
      child: FadeTransition(
        opacity: _successFade,
        child: Container(
          color: AppTheme.bgPrimary.withOpacity(0.85),
          child: Center(
            child: ScaleTransition(
              scale: _successScale,
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.accentTeal.withOpacity(0.28),
                      AppTheme.accentTeal.withOpacity(0.04),
                    ]),
                    border: Border.all(
                        color: AppTheme.accentTeal.withOpacity(0.60),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.accentTeal.withOpacity(0.40),
                          blurRadius: 40),
                    ],
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppTheme.accentTeal, size: 44),
                ),
                const SizedBox(height: 20),
                Text('Password Changed!',
                    style: AppTheme.sora(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text('Redirecting to login…',
                    style: AppTheme.dmSans(
                        fontSize: 14,
                        color: AppTheme.textSecondary)),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Orb background ─────────────────────────────────────────────
  Widget _buildOrbs() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          final t  = _orbCtrl.value * 2 * math.pi;
          final sz = MediaQuery.of(context).size;
          return Stack(children: [
            Positioned(
              left: -55 + 38 * math.sin(t * 0.55),
              top:   90 + 50 * math.cos(t * 0.42),
              child:
                  _orb(210, AppTheme.accentViolet.withOpacity(0.18)),
            ),
            Positioned(
              right: -45 + 32 * math.cos(t * 0.48),
              top:   -25 + 42 * math.sin(t * 0.38),
              child: _orb(185, AppTheme.accentBlue.withOpacity(0.14)),
            ),
            Positioned(
              left:   sz.width * 0.28 + 20 * math.sin(t * 0.65),
              bottom: 30 + 36 * math.cos(t * 0.52),
              child: _orb(165, AppTheme.accentPink.withOpacity(0.10)),
            ),
          ]);
        },
      ),
    );
  }

  Widget _orb(double size, Color color) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color, Colors.transparent],
              stops: const [0.0, 1.0]),
        ),
      );
}