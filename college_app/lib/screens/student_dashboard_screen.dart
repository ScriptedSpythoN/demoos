// lib/screens/student_dashboard_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'medical_screen.dart';
import 'student_medical_history_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen>
    with TickerProviderStateMixin {
  // ── Stagger controller ────────────────────────────────────────
  late AnimationController _staggerCtrl;
  late AnimationController _numberRollCtrl;

  // ── Subject data ──────────────────────────────────────────────
  final List<Map<String, dynamic>> _subjects = [
    {'code': 'CN',   'name': 'Computer Networks',                    'percentage': 82.5, 'color': AppTheme.accentBlue},
    {'code': 'CD',   'name': 'Compiler Design',                      'percentage': 78.0, 'color': AppTheme.accentViolet},
    {'code': 'OS',   'name': 'Operating System',                     'percentage': 85.5, 'color': Color(0xFF3B82F6)},
    {'code': 'ESSP', 'name': 'Enhancing Soft Skills & Personality',  'percentage': 91.0, 'color': AppTheme.accentTeal},
    {'code': 'ML',   'name': 'Machine Learning',                     'percentage': 68.5, 'color': AppTheme.accentPink},
    {'code': 'DLD',  'name': 'Digital Logic Design',                 'percentage': 72.0, 'color': AppTheme.accentAmber},
  ];

  // ── Announcements data ────────────────────────────────────────
  final List<Map<String, dynamic>> _announcements = [
    {'title': 'Mid-Semester Exams', 'time': '2 hrs ago',     'priority': 'high',   'text': 'Mid-sem schedule released for all departments'},
    {'title': 'Lab Session Update', 'time': 'Yesterday',     'priority': 'medium', 'text': 'CN Lab shifted to LH-3 from Monday onwards'},
    {'title': 'Holiday Notice',     'time': '3 days ago',    'priority': 'low',    'text': 'College closed on 26th for national holiday'},
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _numberRollCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _numberRollCtrl.dispose();
    super.dispose();
  }

  double get _overallPercentage {
    if (_subjects.isEmpty) return 0.0;
    return _subjects.fold<double>(0, (s, e) => s + (e['percentage'] as double)) / _subjects.length;
  }

  Color _colorForPct(double pct) {
    if (pct >= 75) return AppTheme.accentTeal;
    if (pct >= 60) return AppTheme.accentAmber;
    return AppTheme.accentPink;
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
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.bgPrimary, Color(0xFF0B0B18), AppTheme.bgSecondary],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.accentBlue,
                    backgroundColor: AppTheme.bgSecondary,
                    onRefresh: () async {
                      _staggerCtrl.reset();
                      _numberRollCtrl.reset();
                      await Future.delayed(const Duration(milliseconds: 100));
                      _staggerCtrl.forward();
                      _numberRollCtrl.forward();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Row 1: Welcome hero + Quick stats
                          _buildWelcomeHero(),
                          const SizedBox(height: 12),
                          // Row 2: Attendance (full width)
                          _buildAttendanceBento(),
                          const SizedBox(height: 12),
                          // Row 3: Medical + Announcements
                          _buildBottomRow(),
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

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Left: App title
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
                  'Student Portal',
                  style: TextStyle(
                    color: AppTheme.accentBlue.withOpacity(0.80),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Right: Actions + Avatar
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppTheme.textPrimary.withOpacity(0.60), size: 20),
            onPressed: () {
              _staggerCtrl.reset();
              _numberRollCtrl.reset();
              _staggerCtrl.forward();
              _numberRollCtrl.forward();
            },
          ),
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final name = ApiService.currentUserName ?? 'S';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.6)],
          ),
          boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.40), blurRadius: 12)],
        ),
        child: Center(
          child: Text(initials,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }

  // ── Welcome hero card ─────────────────────────────────────────
  Widget _buildWelcomeHero() {
    return StaggerEntry(
      parent: _staggerCtrl,
      index: 0,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        glowColor: AppTheme.accentBlue.withOpacity(0.12),
        borderColor: AppTheme.accentBlue.withOpacity(0.20),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
                  Text(
                    ApiService.currentUserName ?? 'Student',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.accentBlue.withOpacity(0.25)),
                    ),
                    child: const Text(
                      'Dept. of Computer Science',
                      style: TextStyle(
                        color: AppTheme.accentBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Overall % ring
            AnimatedBuilder(
              animation: _numberRollCtrl,
              builder: (context, _) {
                final pct = _overallPercentage * _numberRollCtrl.value;
                return _buildMiniRing(pct, 56);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Attendance bento ──────────────────────────────────────────
  Widget _buildAttendanceBento() {
    return StaggerEntry(
      parent: _staggerCtrl,
      index: 1,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Attendance',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _colorForPct(_overallPercentage).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedBuilder(
                    animation: _numberRollCtrl,
                    builder: (context, _) {
                      final val = _overallPercentage * _numberRollCtrl.value;
                      return Text(
                        'Overall ${val.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _colorForPct(_overallPercentage),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.95,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _subjects.length,
              itemBuilder: (context, i) => _buildSubjectRingCard(_subjects[i], i),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectRingCard(Map<String, dynamic> subject, int index) {
    final pct = subject['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = subject['color'] as Color;

    return GestureDetector(
      onTap: () => _showSubjectSheet(subject),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: accent.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _numberRollCtrl,
                  builder: (context, _) {
                    final animPct = pct * _numberRollCtrl.value;
                    return _buildSubjectRing(animPct, color, subject['code'] as String, accent);
                  },
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    subject['code'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withOpacity(0.70),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

  Widget _buildSubjectRing(double pct, Color color, String code, Color accent) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _RingPainter(
              percentage: pct / 100,
              color: color,
              trackColor: color.withOpacity(0.12),
              strokeWidth: 4.5,
            ),
          ),
          Text(
            '${pct.toInt()}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniRing(double pct, double size) {
    final color = _colorForPct(pct);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              percentage: pct / 100,
              color: color,
              trackColor: color.withOpacity(0.12),
              strokeWidth: 5,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${pct.toInt()}%',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom row: Medical + Announcements ───────────────────────
  Widget _buildBottomRow() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Medical Card
          Expanded(
            child: StaggerEntry(
              parent: _staggerCtrl,
              index: 2,
              child: _buildMedicalCard(),
            ),
          ),
          const SizedBox(width: 12),
          // Announcements Card
          Expanded(
            child: StaggerEntry(
              parent: _staggerCtrl,
              index: 3,
              child: _buildAnnouncementsCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: AppTheme.accentPink.withOpacity(0.08),
      borderColor: AppTheme.accentPink.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medical_services_rounded,
                    color: AppTheme.accentPink, size: 18),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Medical',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildMedicalButton(
            label: 'Apply Leave',
            icon: Icons.add_circle_outline_rounded,
            color: AppTheme.accentPink,
            onTap: () => Navigator.push(
              context,
              _slideRoute(const MedicalScreen()),
            ),
          ),
          const SizedBox(height: 8),
          _buildMedicalButton(
            label: 'View History',
            icon: Icons.history_rounded,
            color: AppTheme.accentAmber,
            onTap: () => Navigator.push(
              context,
              _slideRoute(StudentMedicalHistoryScreen(
                studentRollNo: ApiService.currentUserId ?? '2301105277',
              )),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.60), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded,
                    color: AppTheme.accentAmber, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                'Notices',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._announcements.take(3).map((a) => _buildAnnouncementItem(a)).toList(),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Map<String, dynamic> a) {
    final priorityColor = a['priority'] == 'high'
        ? AppTheme.accentPink
        : a['priority'] == 'medium'
            ? AppTheme.accentAmber
            : AppTheme.accentBlue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priorityColor,
              boxShadow: [BoxShadow(color: priorityColor.withOpacity(0.5), blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a['title'] as String,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  a['time'] as String,
                  style: TextStyle(
                    color: AppTheme.textPrimary.withOpacity(0.35),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Subject detail bottom sheet ───────────────────────────────
  void _showSubjectSheet(Map<String, dynamic> subject) {
    final pct = subject['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = subject['color'] as Color;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary.withOpacity(0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.20), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 100, height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(100, 100),
                        painter: _RingPainter(
                          percentage: pct / 100,
                          color: color,
                          trackColor: color.withOpacity(0.12),
                          strokeWidth: 8,
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subject['name'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: AppTheme.statusBadgeDecor(pct >= 75 ? 'ACCEPTED' : pct >= 60 ? 'PENDING' : 'REJECTED'),
                  child: Text(
                    pct >= 75 ? 'Safe' : pct >= 60 ? 'Warning' : 'Critical',
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildSheetStat('Classes\nAttended', '33', accent),
                    _buildSheetStat('Total\nClasses', '40', accent),
                    _buildSheetStat('Target\nMinimum', '75%', accent),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetStat(String label, String value, Color accent) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.45),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  PageRoute _slideRoute(Widget screen) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );
}

// ── Circular ring painter ─────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.percentage,
    required this.color,
    required this.trackColor,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    canvas.drawCircle(
      center, radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    final sweepAngle = 2 * math.pi * percentage.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percentage != percentage || old.color != color;
}

// ── Stagger entry reuse ───────────────────────────────────────────
class StaggerEntry extends StatelessWidget {
  final Widget child;
  final Animation<double> parent;
  final int index;

  const StaggerEntry({super.key, required this.child, required this.parent, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = (index * 0.09).clamp(0.0, 0.75);
    final e = (s + 0.35).clamp(0.0, 1.0);
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: parent, curve: Interval(s, e, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: parent, curve: Interval(s, e, curve: Curves.easeOutCubic)),
    );
    return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
  }
}