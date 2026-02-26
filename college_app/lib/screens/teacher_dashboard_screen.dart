// lib/screens/teacher_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_top_bar.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import 'ai_evaluation_screen.dart';

// ─────────────────────────────────────────────────────────────────
//  TeacherDashboardScreen — Shell with Bottom Navigation
// ─────────────────────────────────────────────────────────────────
class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() =>
      _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  int _currentTab = 0;

  static const _navItems = [
    GlassNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home'),
    GlassNavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book_rounded,
        label: 'Classroom'),
    GlassNavItem(
        icon: Icons.campaign_outlined,
        activeIcon: Icons.campaign_rounded,
        label: 'Notices'),
    GlassNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile'),
  ];

  void _logout() {
    ApiService.logout();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Faculty';
    final userId = ApiService.currentUserId ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // ── Drawer ───────────────────────────────────────────────
      drawer: AppDrawer(
        userName: name,
        userId: userId,
        role: 'TEACHER',
        accentColor: AppTheme.accentTeal,
        onLogout: _logout,
      ),
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              IndexedStack(
                index: _currentTab,
                children: [
                  _TeacherHomeTab(onLogout: _logout),
                  const _TeacherClassroomTab(),
                  const _TeacherAnnouncementsTab(),
                  _TeacherProfileTab(onLogout: _logout),
                ],
              ),
              // ── New three-point top bar ─────────────────────
              DashboardTopBar(
                accentColor: AppTheme.accentTeal,
                notificationCount: 2,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentTab,
        items: _navItems,
        accentColor: AppTheme.accentTeal,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 0 — Home
// ─────────────────────────────────────────────────────────────────
class _TeacherHomeTab extends StatefulWidget {
  final VoidCallback onLogout;
  const _TeacherHomeTab({required this.onLogout});

  @override
  State<_TeacherHomeTab> createState() => _TeacherHomeTabState();
}

class _TeacherHomeTabState extends State<_TeacherHomeTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late Future<List<Map<String, dynamic>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
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

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accentTeal,
      backgroundColor: Colors.white,
      onRefresh: () async {
        _staggerCtrl.reset();
        _loadSchedule();
        await Future.delayed(const Duration(milliseconds: 80));
        _staggerCtrl.forward();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerEntry(
                parent: _staggerCtrl,
                index: 0,
                child: _buildWelcomeCard()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl, index: 1, child: _buildAiCard()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl,
                index: 2,
                child: _buildScheduleSection()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl,
                index: 3,
                child: _buildAttendanceReviewCard()),
          ],
        ),
      ),
    );
  }

  // ── Welcome card ──────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: AppTheme.accentTeal,
      borderColor: AppTheme.accentTeal.withOpacity(0.25),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.accentTeal.withOpacity(0.20),
                AppTheme.accentTeal.withOpacity(0.05),
              ]),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppTheme.accentTeal.withOpacity(0.30)),
            ),
            child: const Icon(Icons.person_rounded,
                color: AppTheme.accentTeal, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,',
                      style: AppTheme.dmSans(
                          fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 3),
                  Text(ApiService.currentUserName ?? 'Professor',
                      style: AppTheme.sora(
                          fontSize: 19, fontWeight: FontWeight.w800)),
                ]),
          ),
          const RoleBadge('TEACHER'),
        ],
      ),
    );
  }

  // ── AI card ───────────────────────────────────────────────────
  Widget _buildAiCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      glowColor: AppTheme.accentViolet,
      borderColor: AppTheme.accentViolet.withOpacity(0.25),
      onTap: () => Navigator.push(
          context, AppTheme.slideRoute(const AiEvaluationScreen())),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.accentViolet.withOpacity(0.18),
                AppTheme.accentBlue.withOpacity(0.08),
              ]),
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
                  Row(children: [
                    Text('AI Answer Checker',
                        style: AppTheme.sora(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.accentViolet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: AppTheme.accentViolet.withOpacity(0.25)),
                      ),
                      child: Text('BETA',
                          style: AppTheme.dmSans(
                              fontSize: 9,
                              color: AppTheme.accentViolet,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8)),
                    ),
                  ]),
                  const SizedBox(height: 3),
                  Text('Auto-grade scanned answer sheets',
                      style: AppTheme.dmSans(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ]),
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
    );
  }

  // ── Schedule section ──────────────────────────────────────────
  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.calendar_today_rounded, 'Assigned Classes',
            AppTheme.accentTeal),
        const SizedBox(height: 12),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _scheduleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                  children: List.generate(
                      3,
                      (_) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              child: Container(
                                  height: 80,
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                          color: AppTheme.accentTeal,
                                          strokeWidth: 2))),
                            ),
                          )));
            }
            if (snapshot.hasError)
              return _buildErrorCard('${snapshot.error}');
            final classes = snapshot.data ?? [];
            if (classes.isEmpty) return _buildEmptySchedule();
            return Column(
              children: classes
                  .map((cls) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildClassCard(cls),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.accentTeal.withOpacity(0.15),
      onTap: () => Navigator.push(
          context,
          AppTheme.slideRoute(AttendanceScreen(
            classId: cls['class_identifier'] ?? '',
            subjectId: cls['subject_code'] ?? '',
          ))),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accentTeal.withOpacity(0.20)),
            ),
            child: Column(children: [
              Text(
                  (cls['time_slot'] as String? ?? '09:00')
                      .split(' ')
                      .first,
                  style: AppTheme.mono(
                      fontSize: 13,
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w800)),
              Text(cls['room'] ?? 'LH',
                  style: AppTheme.dmSans(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls['subject_name'] ?? 'Subject',
                      style: AppTheme.sora(
                          fontSize: 14, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppTheme.accentTeal.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(cls['subject_code'] ?? '---',
                          style: AppTheme.dmSans(
                              fontSize: 10,
                              color: AppTheme.accentTeal,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Text(cls['class_identifier'] ?? '',
                        style: AppTheme.dmSans(
                            fontSize: 12, color: AppTheme.textMuted)),
                  ]),
                ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppTheme.accentTeal.withOpacity(0.25)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.how_to_reg_rounded,
                  color: AppTheme.accentTeal, size: 15),
              const SizedBox(width: 4),
              Text('Attend',
                  style: AppTheme.dmSans(
                      fontSize: 11,
                      color: AppTheme.accentTeal,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReviewCard() {
    final students = [
      {'name': 'Aryan Sharma', 'roll': '2301105201', 'pct': 88.0},
      {'name': 'Priya Gupta', 'roll': '2301105215', 'pct': 65.5},
      {'name': 'Rohit Verma', 'roll': '2301105229', 'pct': 72.0},
      {'name': 'Sneha Patel', 'roll': '2301105243', 'pct': 91.5},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.people_rounded, 'Student Attendance',
            AppTheme.accentBlue),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children:
                students.map((s) => _buildStudentRow(s)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> s) {
    final pct = s['pct'] as double;
    final color = pct >= 75
        ? AppTheme.accentTeal
        : pct >= 60
            ? AppTheme.accentAmber
            : AppTheme.accentPink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [color, color.withOpacity(0.6)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
                child: Text(
              (s['name'] as String).substring(0, 1),
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['name'],
                      style: AppTheme.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(s['roll'],
                      style: AppTheme.dmSans(
                          fontSize: 11, color: AppTheme.textMuted)),
                ]),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.20))),
            child: Text('${pct.toStringAsFixed(1)}%',
                style: AppTheme.mono(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16)),
      const SizedBox(width: 10),
      Text(title,
          style: AppTheme.sora(fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _buildEmptySchedule() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(children: [
        Icon(Icons.event_busy_rounded, size: 48, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text('No classes scheduled',
            style: AppTheme.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _buildErrorCard(String error) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppTheme.accentPink.withOpacity(0.20),
      child: Row(children: [
        const Icon(Icons.wifi_off_rounded,
            color: AppTheme.accentPink, size: 20),
        const SizedBox(width: 12),
        Expanded(
            child: Text('Could not load: $error',
                style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textSecondary))),
        GestureDetector(
          onTap: _loadSchedule,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
                color: AppTheme.accentPink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Text('Retry',
                style: AppTheme.dmSans(
                    fontSize: 12,
                    color: AppTheme.accentPink,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 1 — Classroom  (unchanged)
// ─────────────────────────────────────────────────────────────────
class _TeacherClassroomTab extends StatelessWidget {
  const _TeacherClassroomTab();

  @override
  Widget build(BuildContext context) {
    final classes = [
      {
        'subject': 'Computer Networks',
        'code': 'CN',
        'section': 'CS-A',
        'students': 58,
        'color': AppTheme.accentTeal
      },
      {
        'subject': 'Compiler Design',
        'code': 'CD',
        'section': 'CS-B',
        'students': 52,
        'color': AppTheme.accentBlue
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classroom',
              style:
                  AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Manage your classes',
              style: AppTheme.dmSans(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          ...classes
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GlassCard(
                      padding: const EdgeInsets.all(16),
                      borderColor:
                          (c['color'] as Color).withOpacity(0.20),
                      child: Row(children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              c['color'] as Color,
                              (c['color'] as Color).withOpacity(0.6),
                            ]),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: (c['color'] as Color)
                                      .withOpacity(0.25),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Center(
                              child: Text(c['code'] as String,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12))),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                              Text(c['subject'] as String,
                                  style: AppTheme.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Row(children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: (c['color'] as Color)
                                            .withOpacity(0.10),
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    child: Text(c['section'] as String,
                                        style: AppTheme.dmSans(
                                            fontSize: 10,
                                            color: c['color'] as Color,
                                            fontWeight:
                                                FontWeight.w600))),
                                const SizedBox(width: 8),
                                Text('${c['students']} Students',
                                    style: AppTheme.dmSans(
                                        fontSize: 11,
                                        color: AppTheme.textMuted)),
                              ]),
                            ])),
                        Icon(Icons.chevron_right_rounded,
                            color: AppTheme.textMuted),
                      ]),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 2 — Announcements  (unchanged)
// ─────────────────────────────────────────────────────────────────
class _TeacherAnnouncementsTab extends StatefulWidget {
  const _TeacherAnnouncementsTab();

  @override
  State<_TeacherAnnouncementsTab> createState() =>
      _TeacherAnnouncementsTabState();
}

class _TeacherAnnouncementsTabState
    extends State<_TeacherAnnouncementsTab> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Announcements',
              style:
                  AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Post updates for your students',
              style: AppTheme.dmSans(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderColor: AppTheme.accentTeal.withOpacity(0.20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Announcement',
                      style: AppTheme.sora(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write your announcement here...',
                      hintStyle:
                          TextStyle(color: Color(0x880D1B3E)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: GlowButton(
                        label: 'Post Announcement',
                        accent: AppTheme.accentTeal,
                        onPressed: () {
                          _controller.clear();
                        }),
                  ),
                ]),
          ),
          const SizedBox(height: 16),
          Text('Recent Posts',
              style: AppTheme.sora(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Text('CN Lab shifted to LH-3 from Monday.',
                style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 3 — Profile  (unchanged)
// ─────────────────────────────────────────────────────────────────
class _TeacherProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  const _TeacherProfileTab({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Faculty';
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          glowColor: AppTheme.accentTeal,
          child: Column(children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accentTeal, AppTheme.accentBlue]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.accentTeal.withOpacity(0.30),
                      blurRadius: 20)
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 14),
            Text(name,
                style: AppTheme.sora(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Faculty Member',
                style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            const RoleBadge('TEACHER'),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            _row(Icons.school_rounded, 'Department', 'Computer Science',
                AppTheme.accentTeal),
            _row(Icons.class_rounded, 'Subjects Assigned', '2 Subjects',
                AppTheme.accentTeal),
          ]),
        ),
        const SizedBox(height: 12),
        GlowButton(
            label: 'Sign Out',
            accent: AppTheme.accentPink,
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded,
                color: Colors.white, size: 18)),
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 16)),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(label,
                  style: AppTheme.dmSans(
                      fontSize: 11, color: AppTheme.textMuted)),
              Text(value,
                  style: AppTheme.dmSans(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ])),
      ]),
    );
  }
}