// lib/screens/forgot_password_screen.dart
//
// ══════════════════════════════════════════════════════════════
//  INTEGRATION GUIDE
// ══════════════════════════════════════════════════════════════
//  NEW FILES TO CREATE
//  ─────────────────────────────────────────────────────────────
//  • lib/screens/forgot_password_screen.dart   ← this file
//  • lib/screens/change_password_screen.dart   ← next file
//
//  EXISTING FILE TO EDIT
//  ─────────────────────────────────────────────────────────────
//  • lib/screens/login_screen.dart
//    Find the "Forgot password?" text widget and wrap it in a
//    GestureDetector (or TextButton) that navigates to this screen:
//
//      GestureDetector(
//        onTap: () => Navigator.push(
//          context,
//          MaterialPageRoute(
//            builder: (_) => const ForgotPasswordScreen())),
//        child: Text('Forgot password?', ...),
//      )
//
//  Also add this import to login_screen.dart:
//    import 'forgot_password_screen.dart';
//
//  NAVIGATION FLOW
//  ─────────────────────────────────────────────────────────────
//  LoginScreen ──► ForgotPasswordScreen ──► ChangePasswordScreen
//                                                   │
//                                                   ▼
//                                             LoginScreen
// ══════════════════════════════════════════════════════════════

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'change_password_screen.dart';

// ─────────────────────────────────────────────────────────────────
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {

  // ── Form controllers ──────────────────────────────────────────
  final _uniqueIdCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();

  // 4 separate controllers + focus nodes for OTP boxes
  final List<TextEditingController> _otpCtrl =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocus =
      List.generate(4, (_) => FocusNode());

  bool _otpSent   = false;
  bool _sending   = false;
  bool _verifying = false;

  // ── Animation controllers ─────────────────────────────────────
  late AnimationController _orbCtrl;
  late AnimationController _entryCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _otpRevealCtrl;
  late AnimationController _shakeCtrl;

  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _glow;
  late Animation<double> _otpFade;
  late Animation<Offset> _otpSlide;
  late Animation<double> _shake;

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

    _otpRevealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));

    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));

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

    _otpFade = CurvedAnimation(
        parent: _otpRevealCtrl, curve: Curves.easeOut);

    _otpSlide = Tween<Offset>(
            begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _otpRevealCtrl, curve: Curves.easeOutCubic));

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
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _otpRevealCtrl.dispose();
    _shakeCtrl.dispose();
    _uniqueIdCtrl.dispose();
    _emailCtrl.dispose();
    for (final c in _otpCtrl) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  // ── OTP handlers ──────────────────────────────────────────────

  Future<void> _handleGetOtp() async {
    final id    = _uniqueIdCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (id.isEmpty || email.isEmpty) {
      _triggerShake();
      _snack('Please fill in both Unique ID and Email.', isError: true);
      return;
    }
    if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.\w{2,}$').hasMatch(email)) {
      _triggerShake();
      _snack('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() => _sending = true);
    
    // REAL API CALL
    final success = await ApiService.requestPasswordReset(id);
    
    if (!mounted) return;

    if (success) {
      setState(() { _sending = false; _otpSent = true; });
      _otpRevealCtrl.forward();
      _snack('OTP sent to $email');

      await Future.delayed(const Duration(milliseconds: 560));
      if (mounted) _otpFocus[0].requestFocus();
    } else {
      setState(() => _sending = false);
      _triggerShake();
      _snack('Failed to send OTP. Check your ID.', isError: true);
    }
  }

  Future<void> _handleVerify() async {
    final otp = _otpCtrl.map((c) => c.text).join();
    if (otp.length < 4) {
      _triggerShake();
      _snack('Enter all 4 digits of the OTP.', isError: true);
      return;
    }

    setState(() => _verifying = true);
    final id = _uniqueIdCtrl.text.trim();
    
    // REAL API CALL
    final success = await ApiService.verifyOtp(id, otp);
    
    if (!mounted) return;
    setState(() => _verifying = false);

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 420),
          pageBuilder: (_, __, ___) =>
              ChangePasswordScreen(uniqueId: id, otp: otp), // Pass OTP to next screen!
          transitionsBuilder: (_, anim, __, child) => SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(1.0, 0), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: anim, curve: Curves.easeOutCubic)),
            child: FadeTransition(opacity: anim, child: child),
          ),
        ),
      );
    } else {
      _triggerShake();
      _snack('Invalid or expired OTP.', isError: true);
    }
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
        ]),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        _GlassIconBtn(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textSecondary, size: 17),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('Reset Your Password',
                style: AppTheme.sora(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            Text('Verify your identity to continue',
                style: AppTheme.dmSans(
                    fontSize: 12, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  // ── Main glass card ────────────────────────────────────────────
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
                  color: AppTheme.accentBlue.withOpacity(0.12),
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

            // Unique ID
            FpGlassField(
              controller: _uniqueIdCtrl,
              label: 'Unique ID',
              hint: 'Enter your roll no. / employee ID',
              icon: Icons.badge_outlined,
              enabled: !_otpSent,
            ),
            const SizedBox(height: 14),

            // Email
            FpGlassField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'Enter your registered email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              enabled: !_otpSent,
            ),
            const SizedBox(height: 24),

            // Button / OTP section
            if (!_otpSent)
              FpActionButton(
                label: 'Get OTP',
                loading: _sending,
                accent: AppTheme.accentBlue,
                onTap: _handleGetOtp,
              )
            else
              FadeTransition(
                opacity: _otpFade,
                child: SlideTransition(
                  position: _otpSlide,
                  child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [
                    _otpDivider(),
                    const SizedBox(height: 20),
                    _buildOtpBoxes(),
                    const SizedBox(height: 24),
                    FpActionButton(
                      label: 'Verify OTP',
                      loading: _verifying,
                      accent: AppTheme.accentTeal,
                      onTap: _handleVerify,
                      trailingIcon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 16),
                    _buildResendRow(),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _glow,
      builder: (_, __) => Column(children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              AppTheme.accentBlue.withOpacity(0.22),
              AppTheme.accentBlue.withOpacity(0.03),
            ]),
            border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.40),
                width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.accentBlue
                      .withOpacity(_glow.value * 0.52),
                  blurRadius: 32, spreadRadius: 0),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppTheme.accentBlue, size: 30),
        ),
        const SizedBox(height: 14),
        Text('Forgot Password?',
            textAlign: TextAlign.center,
            style: AppTheme.sora(
                fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _otpSent
                ? 'Enter the 4-digit OTP sent to your email'
                : 'Enter your ID & email to receive an OTP',
            key: ValueKey(_otpSent),
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5),
          ),
        ),
      ]),
    );
  }

  // ── OTP divider ────────────────────────────────────────────────
  Widget _otpDivider() {
    return Row(children: [
      Expanded(
          child: Divider(
              color: Colors.white.withOpacity(0.12), thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('Enter OTP',
            style: AppTheme.dmSans(
                fontSize: 11,
                color: AppTheme.textMuted,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500)),
      ),
      Expanded(
          child: Divider(
              color: Colors.white.withOpacity(0.12), thickness: 1)),
    ]);
  }

  // ── OTP boxes ─────────────────────────────────────────────────
  Widget _buildOtpBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, _buildOtpBox),
    );
  }

  Widget _buildOtpBox(int i) {
    return SizedBox(
      width: 62,
      height: 68,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withOpacity(0.16), width: 1.2),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.accentBlue.withOpacity(0.07),
                    blurRadius: 12),
              ],
            ),
            child: TextField(
              controller: _otpCtrl[i],
              focusNode: _otpFocus[i],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(1),
              ],
              style: AppTheme.mono(
                  fontSize: 24,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700),
              cursorColor: AppTheme.accentBlue,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                if (val.isNotEmpty && i < 3) {
                  _otpFocus[i + 1].requestFocus();
                } else if (val.isEmpty && i > 0) {
                  _otpFocus[i - 1].requestFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Resend row ─────────────────────────────────────────────────
  Widget _buildResendRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text("Didn't receive it? ",
          style: AppTheme.dmSans(
              fontSize: 13, color: AppTheme.textSecondary)),
      GestureDetector(
        onTap: () {
          for (final c in _otpCtrl) c.clear();
          setState(() => _otpSent = false);
          _otpRevealCtrl.reset();
          Future.delayed(
              const Duration(milliseconds: 120), _handleGetOtp);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppTheme.accentBlue.withOpacity(0.35)),
          ),
          child: Text('Resend OTP',
              style: AppTheme.dmSans(
                  fontSize: 13,
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    ]);
  }

  // ── Orbs background ────────────────────────────────────────────
  Widget _buildOrbs() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _orbCtrl,
        builder: (context, _) {
          final t  = _orbCtrl.value * 2 * math.pi;
          final sz = MediaQuery.of(context).size;
          return Stack(children: [
            Positioned(
              left: -60 + 40 * math.sin(t * 0.6),
              top:   80 + 55 * math.cos(t * 0.4),
              child: _orb(220, AppTheme.accentBlue.withOpacity(0.18)),
            ),
            Positioned(
              right: -50 + 35 * math.cos(t * 0.5),
              top:   -30 + 45 * math.sin(t * 0.35),
              child:
                  _orb(190, AppTheme.accentViolet.withOpacity(0.14)),
            ),
            Positioned(
              left:   sz.width * 0.30 + 22 * math.sin(t * 0.7),
              bottom: 20 + 38 * math.cos(t * 0.5),
              child: _orb(170, AppTheme.accentTeal.withOpacity(0.12)),
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

// ═════════════════════════════════════════════════════════════════
//  Shared sub-widgets (used by both screens via export)
// ═════════════════════════════════════════════════════════════════

/// Small glass icon-button (back arrow, etc.)
class _GlassIconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassIconBtn({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic text field — floating label + animated focus glow
/// Made public so ChangePasswordScreen can reuse it.
class FpGlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final bool enabled;
  final String? exampleHint; // subtle italic hint below field

  const FpGlassField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.exampleHint,
  });

  @override
  State<FpGlassField> createState() => _FpGlassFieldState();
}

class _FpGlassFieldState extends State<FpGlassField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusAnim;
  late Animation<double> _border;
  final FocusNode _focus = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _border = CurvedAnimation(
        parent: _focusAnim, curve: Curves.easeOut);
    _focus.addListener(() =>
        _focus.hasFocus ? _focusAnim.forward() : _focusAnim.reverse());
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _border,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                      widget.enabled
                          ? (0.07 + 0.05 * _border.value)
                          : 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Color.lerp(
                      Colors.white.withOpacity(0.14),
                      AppTheme.accentBlue.withOpacity(0.65),
                      _border.value,
                    )!,
                    width: 1.2 + 0.4 * _border.value,
                  ),
                  boxShadow: _border.value > 0.1
                      ? [
                          BoxShadow(
                              color: AppTheme.accentBlue.withOpacity(
                                  0.10 * _border.value),
                              blurRadius: 16),
                        ]
                      : null,
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  obscureText: widget.isPassword ? _obscure : false,
                  style: AppTheme.dmSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: widget.enabled
                          ? AppTheme.textPrimary
                          : AppTheme.textMuted),
                  cursorColor: AppTheme.accentBlue,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: widget.hint,
                    hintStyle: AppTheme.dmSans(
                        fontSize: 13,
                        color: AppTheme.textMuted.withOpacity(0.50),
                        fontStyle: FontStyle.italic),
                    labelStyle: AppTheme.dmSans(
                        fontSize: 14,
                        color: AppTheme.textSecondary.withOpacity(0.55)),
                    floatingLabelStyle: AppTheme.dmSans(
                        fontSize: 12,
                        color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w600),
                    prefixIcon: Icon(widget.icon,
                        color: Color.lerp(AppTheme.textMuted,
                            AppTheme.accentBlue, _border.value),
                        size: 19),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppTheme.textMuted,
                              size: 19,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.exampleHint != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              widget.exampleHint!,
              style: AppTheme.dmSans(
                  fontSize: 11,
                  color: AppTheme.textMuted.withOpacity(0.50),
                  fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }
}

/// Gradient action button with spinner loading state.
/// Made public so ChangePasswordScreen can reuse it.
class FpActionButton extends StatelessWidget {
  final String label;
  final bool loading;
  final Color accent;
  final VoidCallback onTap;
  final IconData? trailingIcon;

  const FpActionButton({
    super.key,
    required this.label,
    required this.loading,
    required this.accent,
    required this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accent,
              Color.lerp(accent, Colors.black, 0.22)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(loading ? 0.12 : 0.38),
                blurRadius: 22,
                offset: const Offset(0, 8)),
            BoxShadow(
                color: Colors.white.withOpacity(0.07),
                blurRadius: 1,
                offset: const Offset(0, -1)),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.85),
                      strokeWidth: 2.5))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: AppTheme.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1.2)),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon,
                        color: Colors.white, size: 17),
                  ],
                ]),
        ),
      ),
    );
  }
}