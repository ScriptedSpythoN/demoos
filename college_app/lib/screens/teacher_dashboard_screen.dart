// lib/screens/teacher_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import 'ai_evaluation_screen.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late Future<List<Map<String, dynamic>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loadSchedule();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = ApiService.fetchTeacherSchedule();
    });
  }

  void _logout() {
    ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.accentTeal,
                    backgroundColor: AppTheme.bgSecondary,
                    onRefresh: () async {
                      _staggerCtrl.reset();
                      _loadSchedule();
                      await Future.delayed(const Duration(milliseconds: 100));
                      _staggerCtrl.forward();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildWelcomeCard(),
                          const SizedBox(height: 12),
                          _buildAiCard(),
                          const SizedBox(height: 12),
                          _buildScheduleSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ────────────────────────────────────────────────
  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0A0A0F),
            Color(0xFF080F12),
            Color(0xFF091212),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    final name = ApiService.currentUserName ?? 'Faculty';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EduFlow',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Faculty Portal',
                  style: TextStyle(
                    color: AppTheme.accentTeal.withOpacity(0.80),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh_rounded,
                color: AppTheme.textPrimary.withOpacity(0.50), size: 20),
            onPressed: () {
              _staggerCtrl.reset();
              _loadSchedule();
              _staggerCtrl.forward();
            },
          ),
          GestureDetector(
            onTap: _logout,
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.accentTeal, AppTheme.accentTeal.withOpacity(0.6)],
                ),
                boxShadow: [
                  BoxShadow(color: AppTheme.accentTeal.withOpacity(0.40), blurRadius: 12),
                ],
              ),
              child: Center(
                child: Text(initials,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Welcome card ──────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return _StaggerEntry(
      parent: _staggerCtrl,
      index: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentTeal.withOpacity(0.20)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentTeal.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentTeal.withOpacity(0.30)),
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: AppTheme.accentTeal, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          color: AppTheme.textPrimary.withOpacity(0.50),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ApiService.currentUserName ?? 'Professor',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.accentTeal.withOpacity(0.25)),
                  ),
                  child: const Text(
                    'FACULTY',
                    style: TextStyle(
                      color: AppTheme.accentTeal,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── AI Evaluation card ────────────────────────────────────────
  Widget _buildAiCard() {
    return _StaggerEntry(
      parent: _staggerCtrl,
      index: 1,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          _slideRoute(const AiEvaluationScreen()),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentViolet.withOpacity(0.15),
                    AppTheme.accentBlue.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentViolet.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentViolet.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentViolet.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: AppTheme.accentViolet, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'AI Answer Checker',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accentViolet.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.accentViolet.withOpacity(0.30)),
                              ),
                              child: const Text(
                                'BETA',
                                style: TextStyle(
                                  color: AppTheme.accentViolet,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Auto-grade scanned answer sheets with AI',
                          style: TextStyle(
                            color: AppTheme.textPrimary.withOpacity(0.50),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        color: AppTheme.accentViolet, size: 18),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Schedule section ──────────────────────────────────────────
  Widget _buildScheduleSection() {
    return _StaggerEntry(
      parent: _staggerCtrl,
      index: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: AppTheme.textPrimary.withOpacity(0.50), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Assigned Classes',
                  style: TextStyle(
                    color: AppTheme.textPrimary.withOpacity(0.80),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _scheduleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoadingCards();
              }
              if (snapshot.hasError) {
                return _buildErrorCard('${snapshot.error}');
              }
              final classes = snapshot.data ?? [];
              if (classes.isEmpty) {
                return _buildEmptySchedule();
              }
              return Column(
                children: classes.asMap().entries.map((e) {
                  return _StaggerEntry(
                    parent: _staggerCtrl,
                    index: 3 + e.key,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildClassCard(e.value),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        _slideRoute(AttendanceScreen(
          classId: cls['class_identifier'] ?? '',
          subjectId: cls['subject_code'] ?? '',
        )),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.30),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Time block
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentTeal.withOpacity(0.20)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        (cls['time_slot'] as String? ?? '09:00').split(' ').first,
                        style: const TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        cls['room'] ?? 'LH',
                        style: TextStyle(
                          color: AppTheme.textPrimary.withOpacity(0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Subject info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls['subject_name'] ?? 'Subject',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentTeal.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              cls['subject_code'] ?? '---',
                              style: const TextStyle(
                                color: AppTheme.accentTeal,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cls['class_identifier'] ?? '',
                            style: TextStyle(
                              color: AppTheme.textPrimary.withOpacity(0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Take attendance CTA
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.accentTeal.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.how_to_reg_rounded,
                          color: AppTheme.accentTeal, size: 15),
                      const SizedBox(width: 4),
                      const Text(
                        'Attend',
                        style: TextStyle(
                          color: AppTheme.accentTeal,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Column(
      children: List.generate(3, (i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.07)),
        ),
        child: Center(
          child: _ShimmerBox(width: 200, height: 16),
        ),
      )),
    );
  }

  Widget _buildEmptySchedule() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded,
              size: 48, color: AppTheme.textPrimary.withOpacity(0.20)),
          const SizedBox(height: 16),
          Text(
            'No classes scheduled',
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.45),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your assigned classes will appear here',
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.25),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentPink.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppTheme.accentPink, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load schedule: $error',
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.70),
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: _loadSchedule,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: AppTheme.accentPink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _slideRoute(Widget screen) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

// ── Stagger entry helper ──────────────────────────────────────────
class _StaggerEntry extends StatelessWidget {
  final Widget child;
  final Animation<double> parent;
  final int index;

  const _StaggerEntry({required this.child, required this.parent, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = (index * 0.09).clamp(0.0, 0.75);
    final e = (s + 0.35).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: parent, curve: Interval(s, e, curve: Curves.easeOut)));
    final slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: parent, curve: Interval(s, e, curve: Curves.easeOutCubic)));
    return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
  }
}

// ── Shimmer loading box ───────────────────────────────────────────
class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.03, end: 0.10)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}