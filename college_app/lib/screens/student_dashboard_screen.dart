// lib/screens/student_dashboard_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'medical_screen.dart';
import 'student_medical_history_screen.dart';

// ─────────────────────────────────────────────────────────────────
//  StudentDashboardScreen — Shell with Bottom Navigation
// ─────────────────────────────────────────────────────────────────
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentTab = 0;

  static const _navItems = [
    GlassNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Classroom'),
    GlassNavItem(icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'Notices'),
    GlassNavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  void _logout() {
    ApiService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              IndexedStack(
                index: _currentTab,
                children: const [
                  _StudentHomeTab(),
                  _StudentClassroomTab(),
                  _StudentAnnouncementsTab(),
                  _StudentProfileTab(),
                ],
              ),
              // Top bar overlaid
              _StudentTopBar(onLogout: _logout),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentTab,
        items: _navItems,
        accentColor: AppTheme.accentBlue,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────
class _StudentTopBar extends StatelessWidget {
  final VoidCallback onLogout;
  const _StudentTopBar({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Student';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();

    return Positioned(
      top: 0, left: 0, right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EduFlow',
                    style: AppTheme.sora(fontSize: 22, fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary)),
                Text('Student Portal',
                    style: AppTheme.dmSans(fontSize: 12, color: AppTheme.accentBlue,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: onLogout,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppTheme.accentBlue, AppTheme.accentBlue.withOpacity(0.7),
                      ]),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.30), blurRadius: 12)],
                      border: Border.all(color: Colors.white.withOpacity(0.60), width: 1.5),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
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
}

// ─────────────────────────────────────────────────────────────────
//  TAB 0 — Home
// ─────────────────────────────────────────────────────────────────
class _StudentHomeTab extends StatefulWidget {
  const _StudentHomeTab();

  @override
  State<_StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<_StudentHomeTab>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late AnimationController _numberCtrl;

  final List<Map<String, dynamic>> _subjects = [
    {'code': 'CN',   'name': 'Computer Networks',                   'percentage': 82.5, 'color': AppTheme.accentBlue},
    {'code': 'CD',   'name': 'Compiler Design',                     'percentage': 78.0, 'color': AppTheme.accentViolet},
    {'code': 'OS',   'name': 'Operating System',                    'percentage': 85.5, 'color': const Color(0xFF3B82F6)},
    {'code': 'ESSP', 'name': 'Enhancing Soft Skills & Personality', 'percentage': 91.0, 'color': AppTheme.accentTeal},
    {'code': 'ML',   'name': 'Machine Learning',                    'percentage': 68.5, 'color': AppTheme.accentPink},
    {'code': 'DLD',  'name': 'Digital Logic Design',                'percentage': 72.0, 'color': AppTheme.accentAmber},
  ];

  final List<Map<String, dynamic>> _schedule = [
    {'subject': 'Computer Networks', 'code': 'CN', 'time': '09:00', 'room': 'LH-2', 'faculty': 'Dr. Sharma'},
    {'subject': 'Machine Learning',  'code': 'ML', 'time': '11:00', 'room': 'LH-4', 'faculty': 'Prof. Gupta'},
    {'subject': 'Operating System',  'code': 'OS', 'time': '14:00', 'room': 'LH-1', 'faculty': 'Dr. Patel'},
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _numberCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  double get _overallPct => _subjects.isEmpty ? 0 :
      _subjects.fold<double>(0, (s, e) => s + (e['percentage'] as double)) / _subjects.length;

  Color _colorForPct(double p) {
    if (p >= 75) return AppTheme.accentTeal;
    if (p >= 60) return AppTheme.accentAmber;
    return AppTheme.accentPink;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: Colors.white,
      onRefresh: () async {
        _staggerCtrl.reset(); _numberCtrl.reset();
        await Future.delayed(const Duration(milliseconds: 80));
        _staggerCtrl.forward(); _numberCtrl.forward();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerEntry(parent: _staggerCtrl, index: 0, child: _buildWelcomeCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 1, child: _buildScheduleCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 2, child: _buildAttendanceCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 3, child: _buildMedicalCard()),
          ],
        ),
      ),
    );
  }

  // ── Welcome card ──────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: AppTheme.accentBlue,
      borderColor: AppTheme.accentBlue.withOpacity(0.25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(ApiService.currentUserName ?? 'Student', style: AppTheme.sora(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: AppTheme.accentBlue.withOpacity(0.10),
                  borderColor: AppTheme.accentBlue.withOpacity(0.20),
                  child: Text('Dept. of Computer Science',
                      style: AppTheme.dmSans(fontSize: 11, color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          // Overall ring
          AnimatedBuilder(
            animation: _numberCtrl,
            builder: (_, __) => _buildRing(_overallPct * _numberCtrl.value, 60),
          ),
        ],
      ),
    );
  }

  // ── Schedule card ─────────────────────────────────────────────
  Widget _buildScheduleCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.calendar_today_rounded, "Today's Schedule", AppTheme.accentBlue),
          const SizedBox(height: 12),
          ..._schedule.map((cls) => _buildScheduleItem(cls)).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> cls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(cls['time'], style: AppTheme.mono(
                      fontSize: 12, color: AppTheme.accentBlue, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls['subject'], style: AppTheme.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${cls['room']} • ${cls['faculty']}',
                          style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(cls['code'], style: AppTheme.dmSans(
                      fontSize: 10, color: AppTheme.accentTeal, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Attendance card ───────────────────────────────────────────
  Widget _buildAttendanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionHeader(Icons.bar_chart_rounded, 'Attendance', AppTheme.accentViolet),
              const Spacer(),
              AnimatedBuilder(
                animation: _numberCtrl,
                builder: (_, __) {
                  final val = _overallPct * _numberCtrl.value;
                  return GlassCard(
                    radius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: _colorForPct(_overallPct).withOpacity(0.10),
                    borderColor: _colorForPct(_overallPct).withOpacity(0.20),
                    child: Text('${val.toStringAsFixed(1)}%',
                        style: AppTheme.mono(fontSize: 12, color: _colorForPct(_overallPct),
                            fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.92,
              crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: _subjects.length,
            itemBuilder: (_, i) => _buildSubjectCell(_subjects[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCell(Map<String, dynamic> sub) {
    final pct = sub['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = sub['color'] as Color;

    return GestureDetector(
      onTap: () => _showSubjectSheet(sub),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.20)),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _numberCtrl,
                  builder: (_, __) => SizedBox(
                    width: 50, height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(size: const Size(50, 50),
                            painter: _RingPainter(percentage: (pct * _numberCtrl.value) / 100,
                                color: color, trackColor: color.withOpacity(0.12), strokeWidth: 4.5)),
                        Text('${(pct * _numberCtrl.value).toInt()}',
                            style: AppTheme.mono(fontSize: 11, color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(sub['code'], style: AppTheme.dmSans(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Medical card ──────────────────────────────────────────────
  Widget _buildMedicalCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: AppTheme.accentPink,
      borderColor: AppTheme.accentPink.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.medical_services_rounded, 'Medical', AppTheme.accentPink),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMedBtn('Apply Leave', Icons.add_circle_outline_rounded,
                  AppTheme.accentPink, () => Navigator.push(context,
                      AppTheme.slideRoute(const MedicalScreen())))),
              const SizedBox(width: 10),
              Expanded(child: _buildMedBtn('View History', Icons.history_rounded,
                  AppTheme.accentAmber, () => Navigator.push(context,
                      AppTheme.slideRoute(StudentMedicalHistoryScreen(
                          studentRollNo: ApiService.currentUserId ?? '2301105277'))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(label, style: AppTheme.dmSans(
                    fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section header helper ─────────────────────────────────────
  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.sora(fontSize: 14, fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary)),
      ],
    );
  }

  // ── Ring widget ───────────────────────────────────────────────
  Widget _buildRing(double pct, double size) {
    final color = _colorForPct(pct);
    return SizedBox(
      width: size, height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size),
              painter: _RingPainter(percentage: pct / 100, color: color,
                  trackColor: color.withOpacity(0.12), strokeWidth: 5)),
          Text('${pct.toInt()}%', style: AppTheme.mono(
              fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  // ── Subject detail sheet ──────────────────────────────────────
  void _showSubjectSheet(Map<String, dynamic> sub) {
    final pct = sub['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = sub['color'] as Color;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4,
                  decoration: BoxDecoration(color: AppTheme.textMuted,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              SizedBox(width: 100, height: 100, child: Stack(alignment: Alignment.center, children: [
                CustomPaint(size: const Size(100, 100),
                    painter: _RingPainter(percentage: pct / 100, color: color,
                        trackColor: color.withOpacity(0.12), strokeWidth: 8)),
                Text('${pct.toStringAsFixed(1)}%', style: AppTheme.mono(
                    fontSize: 20, color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
              ])),
              const SizedBox(height: 16),
              Text(sub['name'], textAlign: TextAlign.center,
                  style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              StatusBadge(pct >= 75 ? 'ACCEPTED' : pct >= 60 ? 'PENDING' : 'REJECTED'),
              const SizedBox(height: 24),
              Row(children: [
                _sheetStat('Attended', '33', accent),
                _sheetStat('Total', '40', accent),
                _sheetStat('Minimum', '75%', accent),
              ]),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sheetStat(String label, String val, Color accent) {
    return Expanded(child: Column(children: [
      Text(val, style: AppTheme.mono(fontSize: 22, color: accent, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center,
          style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
    ]));
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 1 — Classroom
// ─────────────────────────────────────────────────────────────────
class _StudentClassroomTab extends StatelessWidget {
  const _StudentClassroomTab();

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {'code': 'CN', 'name': 'Computer Networks', 'color': AppTheme.accentBlue, 'materials': 12, 'assignments': 2},
      {'code': 'CD', 'name': 'Compiler Design', 'color': AppTheme.accentViolet, 'materials': 8, 'assignments': 1},
      {'code': 'OS', 'name': 'Operating System', 'color': const Color(0xFF3B82F6), 'materials': 15, 'assignments': 3},
      {'code': 'ML', 'name': 'Machine Learning', 'color': AppTheme.accentPink, 'materials': 10, 'assignments': 1},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classroom', style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Access your course materials', style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ...subjects.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSubjectCard(s),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> s) {
    final color = s['color'] as Color;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.20),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)],
            ),
            child: Center(child: Text(s['code'],
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['name'], style: AppTheme.dmSans(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Row(children: [
                _chip('${s['materials']} Materials', color),
                const SizedBox(width: 6),
                _chip('${s['assignments']} Tasks', AppTheme.accentAmber),
              ]),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.20))),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 2 — Announcements
// ─────────────────────────────────────────────────────────────────
class _StudentAnnouncementsTab extends StatelessWidget {
  const _StudentAnnouncementsTab();

  static const _announcements = [
    {'title': 'Mid-Semester Exams', 'time': '2 hrs ago', 'priority': 'high',
     'text': 'Mid-sem schedule released. Exams begin 15th March across all departments.', 'dept': 'Admin'},
    {'title': 'CN Lab Shift', 'time': 'Yesterday', 'priority': 'medium',
     'text': 'Computer Networks lab has been shifted to LH-3 from Monday onwards.', 'dept': 'CS'},
    {'title': 'Holiday Notice', 'time': '3 days ago', 'priority': 'low',
     'text': 'College will remain closed on 26th January for Republic Day.', 'dept': 'Admin'},
    {'title': 'Hackathon Registration', 'time': '4 days ago', 'priority': 'medium',
     'text': 'Annual HackFest registrations open until end of month. Register now.', 'dept': 'CS'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notices', style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Department & college announcements',
              style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ..._announcements.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildCard(a),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> a) {
    final color = a['priority'] == 'high' ? AppTheme.accentPink
        : a['priority'] == 'medium' ? AppTheme.accentAmber : AppTheme.accentBlue;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: color.withOpacity(0.20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 8, height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)])),
          const SizedBox(width: 10),
          Expanded(child: Text(a['title'], style: AppTheme.sora(
              fontSize: 14, fontWeight: FontWeight.w700))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(a['dept'], style: AppTheme.dmSans(
                  fontSize: 10, color: AppTheme.accentBlue, fontWeight: FontWeight.w600))),
        ]),
        const SizedBox(height: 8),
        Text(a['text'], style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        const SizedBox(height: 8),
        Text(a['time'], style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 3 — Profile
// ─────────────────────────────────────────────────────────────────
class _StudentProfileTab extends StatelessWidget {
  const _StudentProfileTab();

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Student';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.accentBlue, AppTheme.accentViolet]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.30), blurRadius: 20)],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(child: Text(initials,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 14),
              Text(name, style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Roll: ${ApiService.currentUserId ?? '---'}',
                  style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              const RoleBadge('STUDENT'),
            ]),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _profileRow(Icons.school_rounded, 'Department', 'Computer Science'),
              _profileRow(Icons.calendar_month_rounded, 'Semester', '5th Semester'),
              _profileRow(Icons.email_rounded, 'Email', '${ApiService.currentUserId ?? 'student'}@college.edu'),
              _profileRow(Icons.badge_rounded, 'Student ID', ApiService.currentUserId ?? '---'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.accentBlue, size: 16)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: AppTheme.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.percentage, required this.color,
    required this.trackColor, this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint..color = trackColor);
    if (percentage > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          -math.pi / 2, 2 * math.pi * percentage.clamp(0, 1), false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percentage != percentage || old.color != color;
}