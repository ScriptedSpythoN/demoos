// lib/screens/hod_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_top_bar.dart';
import 'medical_detail_screen.dart';
import 'reviewed_medical_screen.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────────────────────
//  HoDDashboardScreen — Shell with Bottom Navigation
// ─────────────────────────────────────────────────────────────────
class HoDDashboardScreen extends StatefulWidget {
  const HoDDashboardScreen({super.key, required this.departmentId});
  final String departmentId;

  @override
  State<HoDDashboardScreen> createState() => _HoDDashboardScreenState();
}

class _HoDDashboardScreenState extends State<HoDDashboardScreen> {
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

  void _logout() async {
    final nav = Navigator.of(context);
    await ApiService.logout();
    if (!mounted) return;
    nav.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'HOD';
    final userId = ApiService.currentUserId ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      // ── Drawer ───────────────────────────────────────────────
      drawer: AppDrawer(
        userName: name,
        userId: userId,
        role: 'HOD',
        accentColor: AppTheme.accentViolet,
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
                  _HoDHomeTab(departmentId: widget.departmentId),
                  _HoDClassroomTab(departmentId: widget.departmentId),
                  _HoDAnnouncementsTab(
                      departmentId: widget.departmentId),
                  _HoDProfileTab(
                      departmentId: widget.departmentId,
                      onLogout: _logout),
                ],
              ),
              // ── New three-point top bar ─────────────────────
              DashboardTopBar(
                accentColor: AppTheme.accentViolet,
                notificationCount: 5,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentTab,
        items: _navItems,
        accentColor: AppTheme.accentViolet,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 0 — Home
// ─────────────────────────────────────────────────────────────────
class _HoDHomeTab extends StatefulWidget {
  final String departmentId;
  const _HoDHomeTab({required this.departmentId});

  @override
  State<_HoDHomeTab> createState() => _HoDHomeTabState();
}

class _HoDHomeTabState extends State<_HoDHomeTab>
    with SingleTickerProviderStateMixin {
  List<MedicalEntry> pendingRequests = [];
  bool isLoading = true;
  int reviewedCount = 0;
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800))
      ..forward();
    _loadData();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final requests = await ApiService.fetchPendingMedical(widget.departmentId);
      final reviewedData = await ApiService.fetchReviewedMedical(widget.departmentId); // Fetch the reviewed list
      
      if (!mounted) return;
      setState(() {
        pendingRequests = requests;
        reviewedCount = reviewedData.length; // Set the dynamic count
        isLoading = false;
      });
      _staggerCtrl.reset();
      _staggerCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: AppTheme.accentPink.withOpacity(0.90),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accentViolet,
      backgroundColor: Colors.white,
      onRefresh: _loadData,
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
                child: _buildStatsRow()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl,
                index: 1,
                child: _buildScheduleCard()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl,
                index: 2,
                child: _buildAttendanceOverview()),
            const SizedBox(height: 12),
            StaggerEntry(
                parent: _staggerCtrl,
                index: 3,
                child: _buildMedicalSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final flagged =
        pendingRequests.where((r) => r.ocrStatus == 'MISMATCH').length;
    return Row(
      children: [
        _statCard(
            '${isLoading ? '—' : pendingRequests.length}',
            'Awaiting',
            Icons.pending_actions_rounded,
            AppTheme.accentAmber),
        const SizedBox(width: 10),
        _statCard('${isLoading ? '—' : flagged}', 'AI Flagged',
            Icons.smart_toy_rounded, AppTheme.accentPink),
        const SizedBox(width: 10),
        _statCard(
          '${isLoading ? '—' : reviewedCount}', // Now dynamic!
          'Reviewed',
          Icons.check_circle_outline_rounded, 
          AppTheme.accentTeal,
          onTap: () {
            // Smoothly slide to the new reviewed leaves screen
            Navigator.push(
              context,
              AppTheme.slideRoute(ReviewedMedicalScreen(departmentId: widget.departmentId)),
            );
          },
        ),
      ],
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          borderColor: color.withOpacity(0.20),
          color: const Color(0xFFFFFFFF).withOpacity(0.65),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value,
                style: AppTheme.mono(
                    fontSize: 22, color: color, fontWeight: FontWeight.w800)),
            Text(label,
                style: AppTheme.dmSans(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    final classes = [
      {
        'subject': 'Data Structures',
        'code': 'DS',
        'time': '10:00',
        'section': 'CS-A'
      },
      {
        'subject': 'Theory of Computation',
        'code': 'TOC',
        'time': '12:00',
        'section': 'CS-B'
      },
      {
        'subject': 'Software Engineering',
        'code': 'SE',
        'time': '15:00',
        'section': 'CS-A'
      },
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.calendar_today_rounded, "Department Schedule",
            AppTheme.accentViolet),
        const SizedBox(height: 12),
        ...classes.map((c) => _scheduleRow(c)).toList(),
      ]),
    );
  }

  Widget _scheduleRow(Map<String, dynamic> c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppTheme.accentViolet.withOpacity(0.12)),
            ),
            child: Row(children: [
              Text(c['time'],
                  style: AppTheme.mono(
                      fontSize: 12,
                      color: AppTheme.accentViolet,
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(c['subject'],
                      style: AppTheme.dmSans(
                          fontSize: 13, fontWeight: FontWeight.w600))),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.accentViolet.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(c['section'],
                    style: AppTheme.dmSans(
                        fontSize: 10,
                        color: AppTheme.accentViolet,
                        fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceOverview() {
    final sections = [
      {'section': 'CS-A', 'avg': 82.5, 'students': 60},
      {'section': 'CS-B', 'avg': 75.0, 'students': 58},
      {'section': 'CS-C', 'avg': 68.0, 'students': 55},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHeader(Icons.bar_chart_rounded, 'Attendance Overview',
            AppTheme.accentBlue),
        const SizedBox(height: 14),
        ...sections.map((s) {
          final pct = s['avg'] as double;
          final color = pct >= 75
              ? AppTheme.accentTeal
              : pct >= 60
                  ? AppTheme.accentAmber
                  : AppTheme.accentPink;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(s['section'] as String,
                        style: AppTheme.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${pct.toStringAsFixed(1)}%',
                        style: AppTheme.mono(
                            fontSize: 13,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      backgroundColor: color.withOpacity(0.10),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('${s['students']} students',
                      style: AppTheme.dmSans(
                          fontSize: 10, color: AppTheme.textMuted)),
                ]),
          );
        }).toList(),
      ]),
    );
  }

  Widget _buildMedicalSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        _sectionHeader(Icons.medical_services_rounded, 'Pending Approvals',
            AppTheme.accentPink),
        const Spacer(),
        if (!isLoading)
          GlassCard(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: (pendingRequests.isEmpty
                    ? AppTheme.accentTeal
                    : AppTheme.accentAmber)
                .withOpacity(0.10),
            borderColor: (pendingRequests.isEmpty
                    ? AppTheme.accentTeal
                    : AppTheme.accentAmber)
                .withOpacity(0.20),
            child: Text(
                '${pendingRequests.length} request${pendingRequests.length == 1 ? '' : 's'}',
                style: AppTheme.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: pendingRequests.isEmpty
                        ? AppTheme.accentTeal
                        : AppTheme.accentAmber)),
          ),
      ]),
      const SizedBox(height: 12),
      isLoading
          ? _buildLoadingState()
          : pendingRequests.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: pendingRequests.asMap().entries.map((e) {
                    final idx = e.key;
                    final req = e.value;
                    return AnimatedBuilder(
                      animation: _staggerCtrl,
                      builder: (_, child) {
                        final s = (idx * 0.09).clamp(0.0, 0.75);
                        final end = (s + 0.35).clamp(0.0, 1.0);
                        final fade = Tween<double>(
                                begin: 0.0, end: 1.0)
                            .animate(CurvedAnimation(
                                parent: _staggerCtrl,
                                curve: Interval(s, end,
                                    curve: Curves.easeOut)));
                        return FadeTransition(
                            opacity: fade, child: child);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRequestCard(req),
                      ),
                    );
                  }).toList()),
    ]);
  }

  Widget _buildRequestCard(MedicalEntry req) {
    final hasMismatch = req.ocrStatus == 'MISMATCH';
    final dayCount =
        req.toDate.difference(req.fromDate).inDays + 1;
    final initials = req.studentRollNo.length >= 2
        ? req.studentRollNo
            .substring(req.studentRollNo.length - 2)
        : req.studentRollNo;

    return GlassCard(
      borderColor: hasMismatch
          ? AppTheme.accentPink.withOpacity(0.25)
          : null,
      color: hasMismatch
          ? AppTheme.accentPink.withOpacity(0.05)
          : Colors.white.withOpacity(0.55),
      onTap: () async {
        final result = await Navigator.push(context,
            AppTheme.slideRoute(MedicalDetailScreen(entry: req)));
        if (result == true) _loadData();
      },
      child: Column(children: [
        if (hasMismatch)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withOpacity(0.10),
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20)),
            ),
            child: Row(children: [
              const Icon(Icons.smart_toy_rounded,
                  size: 13, color: AppTheme.accentPink),
              const SizedBox(width: 6),
              Text('AI flagged: Date mismatch detected',
                  style: AppTheme.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentPink)),
            ]),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.accentViolet,
                  AppTheme.accentViolet.withOpacity(0.60),
                ]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.accentViolet.withOpacity(0.25),
                      blurRadius: 10)
                ],
              ),
              child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14))),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(req.studentRollNo,
                      style: AppTheme.sora(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(req.reason,
                      style: AppTheme.dmSans(
                          fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 11,
                        color: AppTheme.accentViolet.withOpacity(0.80)),
                    const SizedBox(width: 4),
                    Text(
                        '${_fmt(req.fromDate)} → ${_fmt(req.toDate)}',
                        style: AppTheme.dmSans(
                            fontSize: 11,
                            color: AppTheme.accentViolet,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppTheme.accentViolet.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text('$dayCount d',
                          style: AppTheme.dmSans(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const StatusBadge('PENDING'),
              const SizedBox(height: 8),
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 20),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
          3,
          (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Container(
                      height: 90,
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        ShimmerBox(width: 46, height: 46, borderRadius: 14),
                        const SizedBox(width: 14),
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ShimmerBox(width: 140, height: 12),
                              const SizedBox(height: 8),
                              ShimmerBox(width: 100, height: 10),
                            ]),
                      ])),
                ),
              )),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(40),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppTheme.accentTeal.withOpacity(0.15),
                  AppTheme.accentTeal.withOpacity(0.05),
                ]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.done_all_rounded,
                  size: 48, color: AppTheme.accentTeal),
            ),
            const SizedBox(height: 20),
            Text('All Caught Up!',
                style: AppTheme.sora(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('No pending medical requests',
                textAlign: TextAlign.center,
                style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textMuted)),
            const SizedBox(height: 20),
            GlowButton(
                label: 'Refresh',
                accent: AppTheme.accentViolet,
                onPressed: _loadData,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 16),
                height: 44),
          ]),
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
          style:
              AppTheme.sora(fontSize: 14, fontWeight: FontWeight.w700)),
    ]);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

// ─────────────────────────────────────────────────────────────────
//  TAB 1 — Classroom  (unchanged)
// ─────────────────────────────────────────────────────────────────
class _HoDClassroomTab extends StatelessWidget {
  final String departmentId;
  const _HoDClassroomTab({required this.departmentId});

  @override
  Widget build(BuildContext context) {
    final sections = [
      {
        'section': 'CS-A',
        'students': 60,
        'faculty': 'Dr. Sharma',
        'subjects': 6
      },
      {
        'section': 'CS-B',
        'students': 58,
        'faculty': 'Prof. Gupta',
        'subjects': 6
      },
      {
        'section': 'CS-C',
        'students': 55,
        'faculty': 'Dr. Patel',
        'subjects': 6
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Classroom Monitor',
            style:
                AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Department: $departmentId',
            style: AppTheme.dmSans(
                fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        ...sections
            .map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppTheme.accentViolet.withOpacity(0.15),
                    child: Row(children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppTheme.accentViolet,
                            AppTheme.accentViolet.withOpacity(0.6),
                          ]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.accentViolet
                                    .withOpacity(0.25),
                                blurRadius: 10)
                          ],
                        ),
                        child: Center(
                            child: Text(s['section'] as String,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11))),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                            Text('Section ${s['section']}',
                                style: AppTheme.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(children: [
                              _chip('${s['students']} Students',
                                  AppTheme.accentBlue),
                              const SizedBox(width: 6),
                              _chip('${s['subjects']} Subjects',
                                  AppTheme.accentTeal),
                            ]),
                            const SizedBox(height: 4),
                            Text(s['faculty'] as String,
                                style: AppTheme.dmSans(
                                    fontSize: 11,
                                    color: AppTheme.textMuted)),
                          ])),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textMuted),
                    ]),
                  ),
                ))
            .toList(),
      ]),
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.20))),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 2 — Announcements  (unchanged)
// ─────────────────────────────────────────────────────────────────
class _HoDAnnouncementsTab extends StatefulWidget {
  final String departmentId;
  const _HoDAnnouncementsTab({required this.departmentId});

  @override
  State<_HoDAnnouncementsTab> createState() =>
      _HoDAnnouncementsTabState();
}

class _HoDAnnouncementsTabState extends State<_HoDAnnouncementsTab> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
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
                style: AppTheme.sora(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Broadcast to ${widget.departmentId}',
                style: AppTheme.dmSans(
                    fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(16),
              borderColor: AppTheme.accentViolet.withOpacity(0.20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Department Notice',
                        style: AppTheme.sora(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ctrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText:
                              'Write department announcement...'),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                        width: double.infinity,
                        child: GlowButton(
                            label: 'Broadcast',
                            accent: AppTheme.accentViolet,
                            onPressed: () {
                              _ctrl.clear();
                            },
                            icon: const Icon(Icons.send_rounded,
                                color: Colors.white, size: 16))),
                  ]),
            ),
            const SizedBox(height: 16),
            Text('Previous Notices',
                style: AppTheme.sora(
                    fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Exam timetable for end-semester released.',
                          style: AppTheme.dmSans(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text('3 days ago',
                          style: AppTheme.dmSans(
                              fontSize: 11,
                              color: AppTheme.textMuted)),
                    ])),
          ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 3 — Profile  (unchanged)
// ─────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────
//  TAB 3 — Profile  (DYNAMICALLY WIRED)
// ─────────────────────────────────────────────────────────────────
class _HoDProfileTab extends StatefulWidget {
  final String departmentId;
  final VoidCallback onLogout;
  const _HoDProfileTab({required this.departmentId, required this.onLogout});

  @override
  State<_HoDProfileTab> createState() => _HoDProfileTabState();
}

class _HoDProfileTabState extends State<_HoDProfileTab> {
  int _studentCount = 0;
  int _facultyCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await ApiService.fetchDepartmentStats();
    if (mounted) {
      setState(() {
        _studentCount = stats['students'] ?? 0;
        _facultyCount = stats['faculty'] ?? 0;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        GlassCard(
          padding: const EdgeInsets.all(24),
          glowColor: AppTheme.accentViolet,
          child: Column(children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [
                      AppTheme.accentViolet,
                      AppTheme.accentBlue
                    ]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.accentViolet.withOpacity(0.30),
                      blurRadius: 20)
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Center(
                  child: Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 36)),
            ),
            const SizedBox(height: 14),
            Text('Head of Department',
                style: AppTheme.sora(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.departmentId,
                style: AppTheme.dmSans(
                    fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            const RoleBadge('HOD'),
          ]),
        ),
        const SizedBox(height: 12),
        GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _row(Icons.school_rounded, 'Department', widget.departmentId,
                  AppTheme.accentViolet),
              
              // Animated transition between loading and showing data
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading 
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(color: AppTheme.accentViolet),
                    )
                  : Column(
                      key: const ValueKey('stats'),
                      children: [
                        _row(Icons.people_rounded, 'Total Students',
                            '$_studentCount Students', AppTheme.accentViolet),
                        _row(Icons.person_rounded, 'Faculty Members',
                            '$_facultyCount Faculty', AppTheme.accentViolet),
                      ],
                    ),
              )
            ])),
        const SizedBox(height: 12),
        GlowButton(
            label: 'Sign Out',
            accent: AppTheme.accentPink,
            onPressed: widget.onLogout,
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