// lib/screens/hod_dashboard_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'medical_detail_screen.dart';
import 'login_screen.dart';

class HoDDashboardScreen extends StatefulWidget {
  const HoDDashboardScreen({super.key, required this.departmentId});
  final String departmentId;

  @override
  State<HoDDashboardScreen> createState() => _HoDDashboardScreenState();
}

class _HoDDashboardScreenState extends State<HoDDashboardScreen>
    with SingleTickerProviderStateMixin {
  List<MedicalEntry> pendingRequests = [];
  bool isLoading = true;
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadPendingRequests();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final requests = await ApiService.fetchPendingMedical(widget.departmentId);
      if (!mounted) return;
      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
      _staggerCtrl.reset();
      _staggerCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      messenger.showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text('Error: $e',
                style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: AppTheme.accentPink.withOpacity(0.90),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
    }
  }

  Future<void> _logout() async {
    final nav = Navigator.of(context);
    await ApiService.logout();
    if (!mounted) return;
    nav.pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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
                _buildStatsRow(),
                _buildSectionHeader(),
                Expanded(
                  child: isLoading
                      ? _buildLoadingState()
                      : pendingRequests.isEmpty
                          ? _buildEmptyState()
                          : _buildRequestList(),
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
            Color(0xFF0B0A14),
            Color(0xFF0D0B1A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // HOD avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentViolet,
                  AppTheme.accentViolet.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withOpacity(0.40),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOD Dashboard',
                  style: TextStyle(
                    color: AppTheme.accentViolet.withOpacity(0.80),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.departmentId,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          _buildIconAction(Icons.refresh_rounded, _loadPendingRequests),
          const SizedBox(width: 8),
          _buildIconAction(Icons.logout_rounded, _logout),
        ],
      ),
    );
  }

  Widget _buildIconAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFFFFF).withOpacity(0.10)),
            ),
            child: Icon(icon,
                color: AppTheme.textPrimary.withOpacity(0.70), size: 18),
          ),
        ),
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final flagged = pendingRequests
        .where((r) => r.ocrStatus == 'MISMATCH')
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildStatCard(
            value: isLoading ? '—' : '${pendingRequests.length}',
            label: 'Awaiting',
            icon: Icons.pending_actions_rounded,
            color: AppTheme.accentAmber,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            value: isLoading ? '—' : '$flagged',
            label: 'AI Flagged',
            icon: Icons.smart_toy_rounded,
            color: AppTheme.accentPink,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            value: '0',
            label: 'Reviewed',
            icon: Icons.check_circle_outline_rounded,
            color: AppTheme.accentTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPrimary.withOpacity(0.45),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────
  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: Row(
        children: [
          Icon(Icons.inbox_rounded,
              color: AppTheme.textPrimary.withOpacity(0.45), size: 16),
          const SizedBox(width: 8),
          Text(
            'Pending Approvals',
            style: TextStyle(
              color: AppTheme.textPrimary.withOpacity(0.70),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (!isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: pendingRequests.isEmpty
                    ? AppTheme.accentTeal.withOpacity(0.12)
                    : AppTheme.accentAmber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: pendingRequests.isEmpty
                      ? AppTheme.accentTeal.withOpacity(0.25)
                      : AppTheme.accentAmber.withOpacity(0.25),
                ),
              ),
              child: Text(
                '${pendingRequests.length} request${pendingRequests.length == 1 ? '' : 's'}',
                style: TextStyle(
                  color: pendingRequests.isEmpty
                      ? AppTheme.accentTeal
                      : AppTheme.accentAmber,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Request list ──────────────────────────────────────────────
  Widget _buildRequestList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: pendingRequests.length,
      itemBuilder: (context, index) {
        final req = pendingRequests[index];
        return AnimatedBuilder(
          animation: _staggerCtrl,
          builder: (context, child) {
            final s = (index * 0.09).clamp(0.0, 0.75);
            final e = (s + 0.35).clamp(0.0, 1.0);
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: _staggerCtrl,
                  curve: Interval(s, e, curve: Curves.easeOut)),
            );
            final slide = Tween<Offset>(
                    begin: const Offset(0, 0.05), end: Offset.zero)
                .animate(CurvedAnimation(
                    parent: _staggerCtrl,
                    curve: Interval(s, e, curve: Curves.easeOutCubic)));
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: _buildRequestCard(req),
        );
      },
    );
  }

  Widget _buildRequestCard(MedicalEntry req) {
    final hasMismatch = req.ocrStatus == 'MISMATCH';
    final dayCount = req.toDate.difference(req.fromDate).inDays + 1;
    final initials = req.studentRollNo.length >= 2
        ? req.studentRollNo.substring(req.studentRollNo.length - 2)
        : req.studentRollNo;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MedicalDetailScreen(entry: req),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(1, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 350),
          ),
        );
        if (result == true) _loadPendingRequests();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: hasMismatch
                    ? AppTheme.accentPink.withOpacity(0.07)
                    : const Color(0xFFFFFFFF).withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: hasMismatch
                      ? AppTheme.accentPink.withOpacity(0.25)
                      : const Color(0xFFFFFFFF).withOpacity(0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: hasMismatch
                        ? AppTheme.accentPink.withOpacity(0.12)
                        : Colors.black.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // AI flag banner
                  if (hasMismatch)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withOpacity(0.12),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded,
                              size: 13, color: AppTheme.accentPink),
                          const SizedBox(width: 6),
                          Text(
                            'AI flagged: Date mismatch detected in document',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentPink.withOpacity(0.90),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentViolet,
                                AppTheme.accentViolet.withOpacity(0.60),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentViolet.withOpacity(0.30),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.studentRollNo,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                req.reason,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textPrimary.withOpacity(0.45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 11,
                                      color: AppTheme.accentViolet.withOpacity(0.80)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_fmt(req.fromDate)} → ${_fmt(req.toDate)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.accentViolet.withOpacity(0.90),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFFFFF).withOpacity(0.06),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$dayCount d',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary.withOpacity(0.50),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Status + chevron
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: AppTheme.statusBadgeDecor('PENDING'),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  color: AppTheme.statusPending,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(Icons.chevron_right_rounded,
                                color: AppTheme.textPrimary.withOpacity(0.30),
                                size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Loading state ─────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(4, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: _ShimmerCard(),
            ),
          ),
        )),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentTeal.withOpacity(0.20),
                    AppTheme.accentTeal.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withOpacity(0.25),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: const Icon(Icons.done_all_rounded,
                  size: 52, color: AppTheme.accentTeal),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Caught Up!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pending medical requests\nfor ${widget.departmentId} department',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textPrimary.withOpacity(0.40),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _loadPendingRequests,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: AppTheme.accentViolet.withOpacity(0.30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentViolet.withOpacity(0.20),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: AppTheme.accentViolet, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Check Again',
                      style: TextStyle(
                        color: AppTheme.accentViolet,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
}

// ── Shimmer card ──────────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.03, end: 0.09)
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
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(_anim.value * 2),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 12, width: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_anim.value * 2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10, width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_anim.value),
                      borderRadius: BorderRadius.circular(5),
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
}