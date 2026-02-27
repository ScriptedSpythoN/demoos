// lib/screens/hod_student_directory_screen.dart

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
enum _FilterMode { all, defaulters, safe }
enum _SortMode   { nameAsc, attendDesc, attendAsc }

class HodStudentDirectoryScreen extends StatefulWidget {
  final String departmentId;
  const HodStudentDirectoryScreen({
    super.key,
    required this.departmentId,
  });

  @override
  State<HodStudentDirectoryScreen> createState() =>
      _HodStudentDirectoryScreenState();
}

class _HodStudentDirectoryScreenState
    extends State<HodStudentDirectoryScreen>
    with SingleTickerProviderStateMixin {

  List<dynamic> _all      = [];
  List<dynamic> _filtered = [];
  bool   _loading  = true;
  bool   _hasError = false;
  String _errMsg   = '';

  final _searchCtrl = TextEditingController();
  _FilterMode _filter = _FilterMode.all;
  _SortMode   _sort   = _SortMode.nameAsc;
  int?        _expandedIdx;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  // ── Stats ──────────────────────────────────────────────────────
  int    get _total      => _all.length;
  int    get _defCount   =>
      _all.where((s) => (s['overall_attendance'] as double) < 75.0).length;
  double get _avgAttend  {
    if (_all.isEmpty) return 0;
    return _all.fold<double>(
            0, (p, s) => p + (s['overall_attendance'] as double)) /
        _all.length;
  }

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _searchCtrl.addListener(_apply);
    _fetch();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────
  Future<void> _fetch({bool silent = false}) async {
    if (!silent) setState(() { _loading = true; _hasError = false; });
    try {
      final data =
          await ApiService.fetchDepartmentAnalytics(widget.departmentId);
      if (!mounted) return;
      setState(() { _all = data; _loading = false; });
      _apply();
      _fadeCtrl.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _hasError = true; _errMsg = e.toString(); });
    }
  }

  void _apply() {
    final q = _searchCtrl.text.trim().toLowerCase();
    List<dynamic> list = List.from(_all);

    switch (_filter) {
      case _FilterMode.defaulters:
        list = list.where((s) =>
            (s['overall_attendance'] as double) < 75).toList();
        break;
      case _FilterMode.safe:
        list = list.where((s) =>
            (s['overall_attendance'] as double) >= 75).toList();
        break;
      default: break;
    }

    if (q.isNotEmpty) {
      list = list.where((s) =>
          (s['name'] ?? '').toLowerCase().contains(q) ||
          (s['roll_no'] ?? '').toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) {
      switch (_sort) {
        case _SortMode.nameAsc:
          return (a['name'] ?? '').compareTo(b['name'] ?? '');
        case _SortMode.attendDesc:
          return (b['overall_attendance'] as double)
              .compareTo(a['overall_attendance'] as double);
        case _SortMode.attendAsc:
          return (a['overall_attendance'] as double)
              .compareTo(b['overall_attendance'] as double);
      }
    });

    setState(() { _filtered = list; _expandedIdx = null; });
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _topBar(),
            Expanded(child: _buildBody()),
          ]),
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(children: [
        _iconBtn(Icons.arrow_back_ios_new_rounded,
            () => Navigator.pop(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text('Student Directory',
                style: AppTheme.sora(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            Text(widget.departmentId,
                style: AppTheme.dmSans(
                    fontSize: 12,
                    color: AppTheme.accentViolet,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
        _iconBtn(Icons.refresh_rounded, () => _fetch()),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GlassCard(
      radius: 14,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        width: 40, height: 40,
        child: Icon(icon, size: 18,
            color: AppTheme.textPrimary.withOpacity(0.6)),
      ),
    );
  }

  // ── Body router ────────────────────────────────────────────────
  Widget _buildBody() {
    if (_loading) return _shimmer();
    if (_hasError) return _errorState();

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(children: [
        _statsBanner(),
        _searchBar(),
        _filterRow(),
        Expanded(
          child: _filtered.isEmpty ? _emptyState() : _list(),
        ),
      ]),
    );
  }

  // ── Stats banner ───────────────────────────────────────────────
  Widget _statsBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        glowColor: AppTheme.accentBlue,
        child: Row(children: [
          _statCell('Total Students', '$_total',
              Icons.groups_rounded, AppTheme.accentBlue),
          _vLine(),
          _statCell('Defaulters', '$_defCount',
              Icons.warning_amber_rounded, AppTheme.accentPink),
          _vLine(),
          _statCell('Avg Attend.',
              '${_avgAttend.toStringAsFixed(1)}%',
              Icons.insert_chart_outlined_rounded,
              _avgAttend >= 75 ? AppTheme.accentTeal : AppTheme.accentAmber),
        ]),
      ),
    );
  }

  Widget _statCell(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 5),
        Text(value,
            style: AppTheme.sora(
                fontSize: 17, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 1),
        Text(label,
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 9,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2)),
      ]),
    );
  }

  Widget _vLine() => Container(
      width: 1, height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppTheme.glassBorder);

  // ── Search ─────────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        child: Row(children: [
          Icon(Icons.search_rounded,
              color: AppTheme.textMuted, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              style: AppTheme.dmSans(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search name or roll number…',
                hintStyle: AppTheme.dmSans(
                    fontSize: 14, color: AppTheme.textMuted),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                isDense: true,
              ),
            ),
          ),
          if (_searchCtrl.text.isNotEmpty)
            GestureDetector(
              onTap: () { _searchCtrl.clear(); },
              child: Icon(Icons.close_rounded,
                  color: AppTheme.textMuted, size: 17),
            ),
        ]),
      ),
    );
  }

  // ── Filter + sort ──────────────────────────────────────────────
  Widget _filterRow() {
    const sortLabels = ['Name A→Z', 'Attend ↓', 'Attend ↑'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      physics: const BouncingScrollPhysics(),
      child: Row(children: [
        _chip(_FilterMode.all, 'All',
            Icons.groups_outlined, AppTheme.accentBlue),
        const SizedBox(width: 8),
        _chip(_FilterMode.defaulters, 'Defaulters',
            Icons.warning_amber_rounded, AppTheme.accentPink),
        const SizedBox(width: 8),
        _chip(_FilterMode.safe, 'Safe ✓',
            Icons.check_circle_outline_rounded, AppTheme.accentTeal),
        const SizedBox(width: 8),
        // Sort pill
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() =>
                _sort = _SortMode.values[
                    (_sort.index + 1) % _SortMode.values.length]);
            _apply();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.22)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.sort_rounded,
                  size: 13, color: AppTheme.accentBlue),
              const SizedBox(width: 5),
              Text(sortLabels[_sort.index],
                  style: AppTheme.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentBlue)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _chip(_FilterMode mode, String label, IconData icon, Color color) {
    final active = _filter == mode;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _filter = mode);
        _apply();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? color.withOpacity(0.10)
              : const Color(0xFFFFFFFF).withOpacity(0.55),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: active
                ? color.withOpacity(0.40)
                : const Color(0xFFFFFFFF).withOpacity(0.70),
            width: active ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
                color: active
                    ? color.withOpacity(0.12)
                    : const Color(0xFF2B7DE9).withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13,
              color: active ? color : AppTheme.textMuted),
          const SizedBox(width: 5),
          Text(label,
              style: AppTheme.dmSans(
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? color : AppTheme.textSecondary)),
        ]),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────
  Widget _list() {
    return RefreshIndicator(
      color: AppTheme.accentViolet,
      backgroundColor: AppTheme.glassFillHi,
      onRefresh: () => _fetch(silent: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        itemCount: _filtered.length,
        itemBuilder: (_, i) {
          final s        = _filtered[i];
          final attend   = (s['overall_attendance'] as double);
          final isDefaul = attend < 75.0;
          final isExpand = _expandedIdx == i;
          return _StudentCard(
            key: ValueKey('${s['roll_no']}_$i'),
            student: s,
            attendance: attend,
            isDefaulter: isDefaul,
            isExpanded: isExpand,
            onToggle: () {
              HapticFeedback.selectionClick();
              setState(() => _expandedIdx = isExpand ? null : i);
            },
          );
        },
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _shimmer() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 70, 16, 40),
      itemCount: 6,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const ShimmerBox(width: 52, height: 52, borderRadius: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const ShimmerBox(
                    width: double.infinity, height: 14, borderRadius: 7),
                const SizedBox(height: 8),
                const ShimmerBox(width: 120, height: 10, borderRadius: 5),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────
  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentPink.withOpacity(0.08),
                border: Border.all(
                    color: AppTheme.accentPink.withOpacity(0.25)),
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppTheme.accentPink, size: 26),
            ),
            const SizedBox(height: 16),
            Text('Could not load data',
                style: AppTheme.sora(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_errMsg,
                textAlign: TextAlign.center,
                style: AppTheme.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 20),
            GlowButton(
                label: 'Retry',
                accent: AppTheme.accentBlue,
                onPressed: _fetch,
                height: 44),
          ]),
        ),
      ),
    );
  }

  // ── Empty ──────────────────────────────────────────────────────
  Widget _emptyState() {
    final isDefMode = _filter == _FilterMode.defaulters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isDefMode
                ? Icons.celebration_rounded
                : Icons.search_off_rounded,
            size: 52,
            color: isDefMode ? AppTheme.accentTeal : AppTheme.textMuted,
          ),
          const SizedBox(height: 14),
          Text(
            isDefMode
                ? 'No defaulters — great attendance! 🎉'
                : 'No students match your search.',
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5),
          ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  Student Card
// ══════════════════════════════════════════════════════════════════
class _StudentCard extends StatefulWidget {
  final Map<String, dynamic> student;
  final double       attendance;
  final bool         isDefaulter;
  final bool         isExpanded;
  final VoidCallback onToggle;

  const _StudentCard({
    super.key,
    required this.student,
    required this.attendance,
    required this.isDefaulter,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_StudentCard> createState() => _StudentCardState();
}

class _StudentCardState extends State<_StudentCard>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  Color get _accent =>
      widget.isDefaulter ? AppTheme.accentPink : AppTheme.accentViolet;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _anim = CurvedAnimation(
        parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.isExpanded) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(_StudentCard old) {
    super.didUpdateWidget(old);
    if (widget.isExpanded != old.isExpanded) {
      widget.isExpanded ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderColor: widget.isDefaulter
            ? AppTheme.accentPink.withOpacity(0.35)
            : null,
        glowColor: widget.isDefaulter ? AppTheme.accentPink : null,
        onTap: widget.onToggle,
        child: Column(children: [
          _header(),
          SizeTransition(
            sizeFactor: _anim,
            child: _detail(),
          ),
        ]),
      ),
    );
  }

  // ── Header row ─────────────────────────────────────────────────
  Widget _header() {
    final name = widget.student['name'] ?? 'Unknown';
    final roll = widget.student['roll_no'] ?? '—';
    final sem  = widget.student['semester']?.toString() ?? '?';

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        // Arc ring
        _ArcRing(pct: widget.attendance, color: _accent),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            Text(name,
                style: AppTheme.sora(
                    fontSize: 15, fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Wrap(spacing: 6, runSpacing: 4, children: [
              _tag(roll, AppTheme.accentBlue),
              _tag('Sem $sem', AppTheme.accentViolet),
              if (widget.isDefaulter)
                _tag('⚠ Defaulter', AppTheme.accentPink),
            ]),
          ]),
        ),
        AnimatedRotation(
          turns: widget.isExpanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMuted, size: 20),
        ),
      ]),
    );
  }

  // ── Detail panel ───────────────────────────────────────────────
  Widget _detail() {
    final s = widget.student;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassFill,
        border: Border(
            top: BorderSide(color: _accent.withOpacity(0.12))),
        borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [

        // Contact
        _secLabel('Contact', Icons.contact_mail_outlined,
            AppTheme.accentBlue),
        const SizedBox(height: 8),
        _row(Icons.email_outlined,
            s['email'] ?? 'Not provided', AppTheme.accentBlue),
        const SizedBox(height: 6),
        _row(Icons.phone_outlined,
            s['contact_no'] != null
                ? '+91 ${s['contact_no']}'
                : 'Not provided',
            AppTheme.accentTeal),
        const SizedBox(height: 14),

        // Guardian
        _secLabel('Guardian', Icons.family_restroom_rounded,
            AppTheme.accentViolet),
        const SizedBox(height: 8),
        _row(Icons.person_outline_rounded,
            s['guardian_name'] ?? 'Not provided',
            AppTheme.accentViolet),
        const SizedBox(height: 6),
        _row(Icons.phone_outlined,
            s['guardian_contact_no'] != null
                ? '+91 ${s['guardian_contact_no']}'
                : 'Not provided',
            AppTheme.accentAmber),
        const SizedBox(height: 14),

        Divider(color: AppTheme.accentBlue.withOpacity(0.10)),
        const SizedBox(height: 12),

        // Subjects
        _secLabel('Subject-wise Attendance',
            Icons.bar_chart_rounded, AppTheme.accentTeal),
        const SizedBox(height: 10),
        ...(s['subject_breakdown'] as List? ?? []).map((sub) {
          final pct   = (sub['percentage'] as num).toDouble();
          final color = pct >= 75 ? AppTheme.accentTeal : AppTheme.accentPink;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubjectBar(
              name: sub['subject_name'] ?? '',
              code: sub['subject_code'] ?? '',
              pct: pct,
              color: color,
            ),
          );
        }),
      ]),
    );
  }

  Widget _secLabel(String label, IconData icon, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Icon(icon, size: 12, color: color),
      ),
      const SizedBox(width: 8),
      Text(label,
          style: AppTheme.sora(
              fontSize: 12, fontWeight: FontWeight.w700)),
    ]);
  }

  Widget _row(IconData icon, String text, Color color) {
    return Row(children: [
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text,
            style: AppTheme.dmSans(fontSize: 13),
            overflow: TextOverflow.ellipsis),
      ),
    ]);
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color.withOpacity(0.22)),
        ),
        child: Text(label,
            style: AppTheme.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color)),
      );
}

// ══════════════════════════════════════════════════════════════════
//  Arc Ring (static — no animation controller needed in list)
// ══════════════════════════════════════════════════════════════════
class _ArcRing extends StatelessWidget {
  final double pct;
  final Color  color;
  const _ArcRing({required this.pct, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52, height: 52,
      child: CustomPaint(
        painter: _RingPainter(
          progress: (pct / 100).clamp(0.0, 1.0),
          color: color,
          trackColor: color.withOpacity(0.10),
        ),
        child: Center(
          child: Text(
            '${pct.toInt()}%',
            style: AppTheme.mono(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: color),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color  color;
  final Color  trackColor;
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c    = Offset(size.width / 2, size.height / 2);
    final r    = (size.shortestSide - 5) / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final p    = Paint()
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..strokeWidth = 4.5;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi, false,
        p..color = trackColor);
    if (progress > 0) {
      canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false,
          p..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ══════════════════════════════════════════════════════════════════
//  Subject Bar
// ══════════════════════════════════════════════════════════════════
class _SubjectBar extends StatefulWidget {
  final String name;
  final String code;
  final double pct;
  final Color  color;
  const _SubjectBar({
    required this.name,
    required this.code,
    required this.pct,
    required this.color,
  });

  @override
  State<_SubjectBar> createState() => _SubjectBarState();
}

class _SubjectBarState extends State<_SubjectBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(widget.name,
              style: AppTheme.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: AppTheme.textMuted.withOpacity(0.07),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(widget.code,
              style: AppTheme.mono(
                  fontSize: 9,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        Text('${widget.pct.toStringAsFixed(1)}%',
            style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: widget.color)),
      ]),
      const SizedBox(height: 5),
      AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => LayoutBuilder(
          builder: (_, constraints) {
            final total = constraints.maxWidth;
            final fill  =
                (widget.pct / 100 * _anim.value * total).clamp(0.0, total);
            return SizedBox(
              height: 6,
              child: Stack(children: [
                // Track
                Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(3),
                    )),
                // Fill
                Container(
                  height: 6,
                  width: fill,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // 75% line
                Positioned(
                  left: total * 0.75 - 0.75,
                  top: 0,
                  child: Container(
                      width: 1.5, height: 6,
                      color: AppTheme.accentAmber.withOpacity(0.50)),
                ),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}