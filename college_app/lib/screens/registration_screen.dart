// lib/screens/registration_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  final String role; // 'Student', 'Faculty', 'HOD'
  const RegistrationScreen({super.key, required this.role});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  // Phase: 0 = Profile Details, 1 = Password Setup — UNCHANGED
  int _phase = 0;
  bool _isLoading = false;

  // ── Student controllers — UNCHANGED ──
  final _stuFullNameCtrl    = TextEditingController();
  final _stuRegdNoCtrl      = TextEditingController();
  final _stuRollNoCtrl      = TextEditingController();
  final _stuContactCtrl     = TextEditingController();
  final _stuEmailCtrl       = TextEditingController();
  final _stuGuardianNameCtrl    = TextEditingController();
  final _stuGuardianContactCtrl = TextEditingController();
  String _stuSemester = '1st';

  // ── Faculty / HOD controllers — UNCHANGED ──
  final _facNameCtrl      = TextEditingController();
  final _facIdCtrl        = TextEditingController();
  final _facContactCtrl   = TextEditingController();
  final _facEmailCtrl     = TextEditingController();
  final _facEducationCtrl = TextEditingController();
  final _facExpertiseCtrl = TextEditingController();
  String _facDesignation  = 'Asst. Prof.';

  // ── Password controllers — UNCHANGED ──
  final _passCtrl        = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _passVisible        = false;
  bool _confirmPassVisible = false;

  // Animation controllers — UNCHANGED
  late AnimationController _orbController;
  late AnimationController _cardEntryController;
  late AnimationController _glowPulseController;
  late AnimationController _phaseTransitionController;

  late Animation<double> _cardFadeAnim;
  late Animation<Offset> _cardSlideAnim;
  late Animation<double> _glowAnim;
  late Animation<double> _phaseFadeAnim;

  final List<String> _semesters = [
    '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th'
  ];
  final List<String> _facDesignations = ['Prof.', 'Asst. Prof.', 'Guest Faculty'];

  Color get _roleAccent {
    switch (widget.role) {
      case 'Faculty': return AppTheme.accentTeal;
      case 'HOD':     return AppTheme.accentViolet;
      default:        return AppTheme.accentBlue;
    }
  }

  bool get _isStudent => widget.role == 'Student';

  String get _backendRole {
    switch (widget.role) {
      case 'HOD':     return 'HOD';
      case 'Faculty': return 'TEACHER';
      default:        return 'STUDENT';
    }
  }

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
        vsync: this, duration: const Duration(seconds: 14))..repeat();

    _cardEntryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _glowPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);

    _phaseTransitionController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _cardFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardEntryController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    _cardSlideAnim = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _cardEntryController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));

    _glowAnim = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _glowPulseController, curve: Curves.easeInOut));

    _phaseFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _phaseTransitionController, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _cardEntryController.forward();
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _cardEntryController.dispose();
    _glowPulseController.dispose();
    _phaseTransitionController.dispose();
    _stuFullNameCtrl.dispose(); _stuRegdNoCtrl.dispose();
    _stuRollNoCtrl.dispose(); _stuContactCtrl.dispose();
    _stuEmailCtrl.dispose(); _stuGuardianNameCtrl.dispose();
    _stuGuardianContactCtrl.dispose();
    _facNameCtrl.dispose(); _facIdCtrl.dispose();
    _facContactCtrl.dispose(); _facEmailCtrl.dispose();
    _facEducationCtrl.dispose(); _facExpertiseCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Logic — UNCHANGED ─────────────────────────────────────────
  void _handleSave() {
    if (_isStudent) {
      if (_stuFullNameCtrl.text.isEmpty || _stuRegdNoCtrl.text.isEmpty ||
          _stuRollNoCtrl.text.isEmpty || _stuContactCtrl.text.isEmpty ||
          _stuEmailCtrl.text.isEmpty || _stuGuardianNameCtrl.text.isEmpty ||
          _stuGuardianContactCtrl.text.isEmpty) {
        _showError('Please fill in all required fields'); return;
      }
      if (_stuContactCtrl.text.length != 10) {
        _showError('Contact number must be 10 digits'); return;
      }
      if (_stuGuardianContactCtrl.text.length != 10) {
        _showError("Guardian's contact number must be 10 digits"); return;
      }
    } else {
      if (_facNameCtrl.text.isEmpty || _facIdCtrl.text.isEmpty ||
          _facContactCtrl.text.isEmpty || _facEmailCtrl.text.isEmpty ||
          _facEducationCtrl.text.isEmpty || _facExpertiseCtrl.text.isEmpty) {
        _showError('Please fill in all required fields'); return;
      }
      if (_facContactCtrl.text.length != 10) {
        _showError('Contact number must be 10 digits'); return;
      }
    }
    _phaseTransitionController.reset();
    setState(() => _phase = 1);
    _phaseTransitionController.forward();
  }

  Future<void> _handleSignUp() async {
    if (_passCtrl.text.isEmpty || _confirmPassCtrl.text.isEmpty) {
      _showError('Please fill in all password fields'); return;
    }
    if (_passCtrl.text.length < 6) {
      _showError('Password must be at least 6 characters'); return;
    }
    if (_passCtrl.text != _confirmPassCtrl.text) {
      _showError('Passwords do not match'); return;
    }
    setState(() => _isLoading = true);

    final RegistrationResult result;
    if (_isStudent) {
      result = await ApiService.registerStudent(
        fullName: _stuFullNameCtrl.text.trim(),
        regdNo: _stuRegdNoCtrl.text.trim(),
        rollNo: _stuRollNoCtrl.text.trim(),
        semester: _stuSemester,
        contactNo: _stuContactCtrl.text.trim(),
        email: _stuEmailCtrl.text.trim(),
        guardianName: _stuGuardianNameCtrl.text.trim(),
        guardianContactNo: _stuGuardianContactCtrl.text.trim(),
        password: _passCtrl.text,
      );
    } else {
      result = await ApiService.registerFaculty(
        fullName: _facNameCtrl.text.trim(),
        facultyId: _facIdCtrl.text.trim(),
        role: _facDesignation,
        contactNo: _facContactCtrl.text.trim(),
        email: _facEmailCtrl.text.trim(),
        education: _facEducationCtrl.text.trim(),
        fieldsOfExpertise: _facExpertiseCtrl.text.trim(),
        password: _passCtrl.text,
        accountRole: _backendRole,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (result.success) _showSuccessDialog();
    else _showError(result.message);
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              decoration: BoxDecoration(
                // White-glass dialog on the light background
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _roleAccent.withOpacity(0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(color: _roleAccent.withOpacity(0.18), blurRadius: 40),
                  BoxShadow(color: Colors.white.withOpacity(0.80), blurRadius: 1,
                      offset: const Offset(0, -1)),
                ],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      _roleAccent.withOpacity(0.20), _roleAccent.withOpacity(0.05),
                    ]),
                    border: Border.all(color: _roleAccent.withOpacity(0.40), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: _roleAccent.withOpacity(0.25), blurRadius: 24),
                    ],
                  ),
                  child: Icon(Icons.check_circle_rounded, color: _roleAccent, size: 38),
                ),
                const SizedBox(height: 20),
                Text('Registration Successful!', textAlign: TextAlign.center,
                    style: AppTheme.sora(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text('Your account has been created.\nYou can now log in.',
                    textAlign: TextAlign.center,
                    style: AppTheme.dmSans(fontSize: 14, color: AppTheme.textSecondary,
                        height: 1.5)),
                const SizedBox(height: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const LoginScreen(),
                        transitionsBuilder: (_, anim, __, child) => SlideTransition(
                          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                      (route) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity, height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_roleAccent, Color.lerp(_roleAccent, const Color(0xFF0A4FBF), 0.3)!],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(color: _roleAccent.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 6)),
                        BoxShadow(color: Colors.white.withOpacity(0.50), blurRadius: 1, offset: const Offset(0, -1)),
                      ],
                    ),
                    child: Center(child: Text('OK', style: AppTheme.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w800,
                        color: Colors.white, letterSpacing: 2.0))),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Build — STRUCTURE UNCHANGED ───────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        showOrb: false,
        child: Stack(
          children: [
            _buildOrbBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: FadeTransition(
                        opacity: _cardFadeAnim,
                        child: SlideTransition(
                          position: _cardSlideAnim,
                          child: _phase == 0
                              ? _buildProfileCard()
                              : FadeTransition(
                                  opacity: _phaseFadeAnim,
                                  child: _buildPasswordCard(),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Top bar — structure preserved, colours updated ─────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_phase == 1) setState(() => _phase = 0);
              else Navigator.pop(context);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.60),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.80)),
                    boxShadow: [BoxShadow(
                        color: const Color(0xFF2B7DE9).withOpacity(0.08), blurRadius: 12)],
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${widget.role} Registration',
                  style: AppTheme.sora(fontSize: 17, fontWeight: FontWeight.w700)),
              Text(
                _phase == 0 ? 'Step 1 of 2 — Profile Details' : 'Step 2 of 2 — Credentials',
                style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textMuted),
              ),
            ]),
          ),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(2, (i) {
        final active = i == _phase;
        final done = i < _phase;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(left: 5),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: (done || active)
                ? LinearGradient(colors: [_roleAccent, _roleAccent.withOpacity(0.7)])
                : null,
            color: (done || active) ? null : _roleAccent.withOpacity(0.20),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ── Orb background — light version ────────────────────────────
  Widget _buildOrbBackground() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _orbController,
        builder: (context, _) {
          final t = _orbController.value * 2 * math.pi;
          final size = MediaQuery.of(context).size;
          return Stack(
            children: [
              Positioned(
                left: -60 + 40 * math.sin(t * 0.6),
                top: 40 + 60 * math.cos(t * 0.4),
                child: _glowOrb(260, _roleAccent.withOpacity(0.16)),
              ),
              Positioned(
                right: -40 + 30 * math.cos(t * 0.5),
                top: -20 + 30 * math.sin(t * 0.35),
                child: _glowOrb(200, Colors.white.withOpacity(0.55)),
              ),
              Positioned(
                left: size.width * 0.25 + 25 * math.sin(t * 0.7),
                bottom: 30 + 40 * math.cos(t * 0.5),
                child: _glowOrb(180, AppTheme.accentBlue.withOpacity(0.20)),
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

  // ── Glass card container — white frosted ──────────────────────
  Widget _glassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.68),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.5),
            boxShadow: [
              BoxShadow(color: const Color(0xFF2B7DE9).withOpacity(0.10),
                  blurRadius: 40, offset: const Offset(0, 16)),
              BoxShadow(color: Colors.white.withOpacity(0.80),
                  blurRadius: 1, offset: const Offset(0, -1)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: child,
        ),
      ),
    );
  }

  // ── Section title chip — updated colours ──────────────────────
  Widget _sectionTitle(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _roleAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _roleAccent.withOpacity(0.20)),
      ),
      child: Row(children: [
        Icon(icon, color: _roleAccent, size: 18),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.dmSans(
            fontSize: 13, color: _roleAccent, fontWeight: FontWeight.w700,
            letterSpacing: 0.5)),
      ]),
    );
  }

  // ── PROFILE CARD — structure UNCHANGED ────────────────────────
  Widget _buildProfileCard() {
    return _glassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildCardHeader(),
        const SizedBox(height: 24),
        if (_isStudent) ..._buildStudentFields()
        else ..._buildFacultyFields(),
        const SizedBox(height: 28),
        _buildSaveButton(),
      ]),
    );
  }

  Widget _buildCardHeader() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) => Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              _roleAccent.withOpacity(0.20), _roleAccent.withOpacity(0.05),
            ]),
            border: Border.all(color: _roleAccent.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(color: _roleAccent.withOpacity(_glowAnim.value * 0.40), blurRadius: 22),
            ],
          ),
          child: Icon(Icons.person_add_rounded, color: _roleAccent, size: 26),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Create Account', style: AppTheme.sora(
              fontSize: 20, fontWeight: FontWeight.w700)),
          Text('Fill in your profile details', style: AppTheme.dmSans(
              fontSize: 12, color: AppTheme.textMuted)),
        ]),
      ]),
    );
  }

  List<Widget> _buildStudentFields() {
    return [
      _sectionTitle('Academic Details', Icons.school_outlined),
      const SizedBox(height: 16),
      _RegGlassTextField(controller: _stuFullNameCtrl, label: 'Full Name',
          icon: Icons.badge_outlined, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _stuRegdNoCtrl, label: 'Regd. No.',
          icon: Icons.numbers_rounded, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _stuRollNoCtrl, label: 'Roll No.',
          icon: Icons.format_list_numbered_rounded, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _buildSemesterDropdown(),
      const SizedBox(height: 24),
      _sectionTitle('Contact Details', Icons.contact_phone_outlined),
      const SizedBox(height: 16),
      _PhoneGlassTextField(controller: _stuContactCtrl,
          label: 'Contact No.', accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _stuEmailCtrl, label: 'Email Address',
          icon: Icons.email_outlined, accentColor: _roleAccent,
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 24),
      _sectionTitle("Guardian's Details", Icons.family_restroom_rounded),
      const SizedBox(height: 16),
      _RegGlassTextField(controller: _stuGuardianNameCtrl, label: "Guardian's Name",
          icon: Icons.person_outline_rounded, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _PhoneGlassTextField(controller: _stuGuardianContactCtrl,
          label: "Guardian's Contact No.", accentColor: _roleAccent),
    ];
  }

  Widget _buildSemesterDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.80)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _stuSemester,
              dropdownColor: Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _roleAccent, size: 22),
              style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              items: _semesters.map((s) => DropdownMenuItem(
                value: s,
                child: Row(children: [
                  Icon(Icons.layers_outlined, color: _roleAccent.withOpacity(0.7), size: 18),
                  const SizedBox(width: 10),
                  Text('$s Semester'),
                ]),
              )).toList(),
              onChanged: (val) { if (val != null) setState(() => _stuSemester = val); },
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFacultyFields() {
    return [
      _sectionTitle('Professional Details', Icons.work_outline_rounded),
      const SizedBox(height: 16),
      _RegGlassTextField(controller: _facNameCtrl, label: 'Full Name',
          icon: Icons.badge_outlined, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _facIdCtrl, label: 'Faculty ID',
          icon: Icons.numbers_rounded, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _buildDesignationDropdown(),
      const SizedBox(height: 12),
      _PhoneGlassTextField(controller: _facContactCtrl,
          label: 'Contact Number', accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _facEmailCtrl, label: 'Email Address',
          icon: Icons.email_outlined, accentColor: _roleAccent,
          keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _facEducationCtrl,
          label: 'Education (e.g. Ph.D, M.Tech)',
          icon: Icons.school_outlined, accentColor: _roleAccent),
      const SizedBox(height: 12),
      _RegGlassTextField(controller: _facExpertiseCtrl,
          label: 'Fields of Expertise',
          icon: Icons.lightbulb_outline_rounded, accentColor: _roleAccent, maxLines: 2),
    ];
  }

  Widget _buildDesignationDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.60),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.80)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _facDesignation,
              dropdownColor: Colors.white,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: _roleAccent, size: 22),
              style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              items: _facDesignations.map((r) => DropdownMenuItem(
                value: r,
                child: Row(children: [
                  Icon(Icons.work_outline_rounded, color: _roleAccent.withOpacity(0.7), size: 18),
                  const SizedBox(width: 10),
                  Text(r),
                ]),
              )).toList(),
              onChanged: (val) { if (val != null) setState(() => _facDesignation = val); },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _handleSave,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_roleAccent, Color.lerp(_roleAccent, const Color(0xFF0A4FBF), 0.3)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: _roleAccent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.50), blurRadius: 1, offset: const Offset(0, -1)),
          ],
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text('SAVE & CONTINUE', style: AppTheme.dmSans(
                fontSize: 15, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 1.5)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
          ]),
        ),
      ),
    );
  }

  // ── PASSWORD CARD — structure UNCHANGED ───────────────────────
  Widget _buildPasswordCard() {
    return _glassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildPasswordHeader(),
        const SizedBox(height: 28),
        _sectionTitle('Set Credentials', Icons.lock_outline_rounded),
        const SizedBox(height: 20),
        _RegPasswordField(
          controller: _passCtrl,
          label: 'Password',
          placeholder: 'e.g. John@2018',
          isVisible: _passVisible,
          accentColor: _roleAccent,
          onToggle: () => setState(() => _passVisible = !_passVisible),
        ),
        const SizedBox(height: 14),
        _RegPasswordField(
          controller: _confirmPassCtrl,
          label: 'Confirm Password',
          placeholder: 'e.g. John@2018',
          isVisible: _confirmPassVisible,
          accentColor: _roleAccent,
          onToggle: () => setState(() => _confirmPassVisible = !_confirmPassVisible),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Use a mix of letters, numbers & symbols for a strong password.',
            style: AppTheme.dmSans(fontSize: 11.5, color: AppTheme.textMuted, height: 1.5),
          ),
        ),
        const SizedBox(height: 28),
        _buildSignUpButton(),
      ]),
    );
  }

  Widget _buildPasswordHeader() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) => Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [
              _roleAccent.withOpacity(0.20), _roleAccent.withOpacity(0.05),
            ]),
            border: Border.all(color: _roleAccent.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(color: _roleAccent.withOpacity(_glowAnim.value * 0.40), blurRadius: 22),
            ],
          ),
          child: Icon(Icons.lock_person_rounded, color: _roleAccent, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Almost Done!', style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
          Text('Set a secure password for your account',
              style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textMuted)),
        ])),
      ]),
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignUp,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_roleAccent, Color.lerp(_roleAccent, const Color(0xFF0A4FBF), 0.3)!],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(color: _roleAccent.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.white.withOpacity(0.50), blurRadius: 1, offset: const Offset(0, -1)),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text('SIGN UP', style: AppTheme.dmSans(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 2.0)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  _RegGlassTextField — White-glass, light theme
// ─────────────────────────────────────────────────────────────────
class _RegGlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color accentColor;
  final TextInputType keyboardType;
  final int maxLines;

  const _RegGlassTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  State<_RegGlassTextField> createState() => _RegGlassTextFieldState();
}

class _RegGlassTextFieldState extends State<_RegGlassTextField>
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
              color: Colors.white.withOpacity(0.60 + 0.10 * _borderGlow.value),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withOpacity(0.75),
                  widget.accentColor.withOpacity(0.65),
                  _borderGlow.value,
                )!,
                width: 1.2 + _borderGlow.value * 0.5,
              ),
              boxShadow: [
                if (_borderGlow.value > 0.1)
                  BoxShadow(color: widget.accentColor.withOpacity(0.10 * _borderGlow.value),
                      blurRadius: 14),
                BoxShadow(color: Colors.white.withOpacity(0.70), blurRadius: 1,
                    offset: const Offset(0, -1)),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              maxLines: widget.maxLines,
              style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: widget.label,
                labelStyle: AppTheme.dmSans(fontSize: 14,
                    color: AppTheme.textPrimary.withOpacity(
                        _borderGlow.value > 0.5 ? 0.80 : 0.45)),
                floatingLabelStyle: AppTheme.dmSans(fontSize: 12,
                    color: widget.accentColor, fontWeight: FontWeight.w600),
                prefixIcon: Icon(widget.icon,
                  color: Color.lerp(AppTheme.textMuted, widget.accentColor, _borderGlow.value),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              cursorColor: widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  _PhoneGlassTextField — +91 prefix, light theme
// ─────────────────────────────────────────────────────────────────
class _PhoneGlassTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Color accentColor;

  const _PhoneGlassTextField({
    required this.controller,
    required this.label,
    required this.accentColor,
  });

  @override
  State<_PhoneGlassTextField> createState() => _PhoneGlassTextFieldState();
}

class _PhoneGlassTextFieldState extends State<_PhoneGlassTextField>
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
              color: Colors.white.withOpacity(0.60 + 0.10 * _borderGlow.value),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withOpacity(0.75),
                  widget.accentColor.withOpacity(0.65),
                  _borderGlow.value,
                )!,
                width: 1.2 + _borderGlow.value * 0.5,
              ),
              boxShadow: [
                if (_borderGlow.value > 0.1)
                  BoxShadow(color: widget.accentColor.withOpacity(0.10 * _borderGlow.value),
                      blurRadius: 14),
                BoxShadow(color: Colors.white.withOpacity(0.70), blurRadius: 1,
                    offset: const Offset(0, -1)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Color.lerp(
                          const Color(0xFF1A6FE8).withOpacity(0.12),
                          widget.accentColor.withOpacity(0.35),
                          _borderGlow.value,
                        )!,
                      ),
                    ),
                  ),
                  child: Text('+91',
                    style: AppTheme.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Color.lerp(AppTheme.textSecondary, widget.accentColor, _borderGlow.value)!,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      labelText: widget.label,
                      counterText: '',
                      labelStyle: AppTheme.dmSans(fontSize: 14,
                          color: AppTheme.textPrimary.withOpacity(
                              _borderGlow.value > 0.5 ? 0.80 : 0.45)),
                      floatingLabelStyle: AppTheme.dmSans(fontSize: 12,
                          color: widget.accentColor, fontWeight: FontWeight.w600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    ),
                    cursorColor: widget.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  _RegPasswordField — Password + visibility toggle, light theme
// ─────────────────────────────────────────────────────────────────
class _RegPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final bool isVisible;
  final Color accentColor;
  final VoidCallback onToggle;

  const _RegPasswordField({
    required this.controller,
    required this.label,
    required this.placeholder,
    required this.isVisible,
    required this.accentColor,
    required this.onToggle,
  });

  @override
  State<_RegPasswordField> createState() => _RegPasswordFieldState();
}

class _RegPasswordFieldState extends State<_RegPasswordField>
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
              color: Colors.white.withOpacity(0.60 + 0.10 * _borderGlow.value),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withOpacity(0.75),
                  widget.accentColor.withOpacity(0.65),
                  _borderGlow.value,
                )!,
                width: 1.2 + _borderGlow.value * 0.5,
              ),
              boxShadow: [
                if (_borderGlow.value > 0.1)
                  BoxShadow(color: widget.accentColor.withOpacity(0.10 * _borderGlow.value),
                      blurRadius: 14),
                BoxShadow(color: Colors.white.withOpacity(0.70), blurRadius: 1,
                    offset: const Offset(0, -1)),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: !widget.isVisible,
              style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.placeholder,
                hintStyle: AppTheme.dmSans(fontSize: 14, color: AppTheme.textMuted,
                    fontStyle: FontStyle.italic),
                labelStyle: AppTheme.dmSans(fontSize: 14,
                    color: AppTheme.textPrimary.withOpacity(
                        _borderGlow.value > 0.5 ? 0.80 : 0.45)),
                floatingLabelStyle: AppTheme.dmSans(fontSize: 12,
                    color: widget.accentColor, fontWeight: FontWeight.w600),
                prefixIcon: Icon(Icons.lock_outline_rounded,
                  color: Color.lerp(AppTheme.textMuted, widget.accentColor, _borderGlow.value),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: AppTheme.textMuted, size: 20,
                  ),
                  onPressed: widget.onToggle,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              cursorColor: widget.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}