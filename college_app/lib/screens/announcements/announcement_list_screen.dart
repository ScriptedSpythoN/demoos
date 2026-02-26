import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'announcement_chat_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _groups = [];
  bool _isLoading = true;
  late AnimationController _animController;

  bool get _isStaff =>
      ApiService.userRole == 'TEACHER' || ApiService.userRole == 'HOD';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _load();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.fetchMyAnnouncementGroups();
      if (mounted) {
        setState(() {
          _groups = data;
          _isLoading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── DIALOGS ──────────────────────────────────────────────────

  void _showActionDialog() {
    final ctrl = TextEditingController();
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            padding: const EdgeInsets.all(28),
            radius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (_isStaff ? AppTheme.accentTeal : AppTheme.accentBlue),
                            (_isStaff ? AppTheme.accentTeal : AppTheme.accentBlue)
                                .withOpacity(0.5),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _isStaff ? Icons.add_rounded : Icons.login_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _isStaff ? 'New Board' : 'Join Board',
                      style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: AppTheme.dmSans(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: _isStaff
                        ? 'Board name...'
                        : 'Invite code (std@AbCdEf...)',
                    prefixIcon: Icon(
                      _isStaff ? Icons.campaign_rounded : Icons.vpn_key_rounded,
                      color: _isStaff ? AppTheme.accentTeal : AppTheme.accentBlue,
                      size: 20,
                    ),
                  ),
                ),
                if (!_isStaff) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.accentBlue.withOpacity(0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppTheme.accentBlue, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use std@... for student access, ad@... for admin (creator only)',
                            style: AppTheme.dmSans(
                                fontSize: 11, color: AppTheme.accentBlue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: AppTheme.textPrimary.withOpacity(0.08),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: AppTheme.dmSans(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlowButton(
                        label: 'Confirm',
                        accent: _isStaff ? AppTheme.accentTeal : AppTheme.accentBlue,
                        height: 48,
                        isLoading: isProcessing,
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final input = ctrl.text.trim();
                                if (input.isEmpty) return;
                                setS(() => isProcessing = true);
                                try {
                                  if (_isStaff) {
                                    await ApiService.createAnnouncementGroup(input);
                                  } else {
                                    await ApiService.joinAnnouncementGroup(input);
                                  }
                                  if (mounted) Navigator.pop(ctx);
                                  _load();
                                } catch (e) {
                                  setS(() => isProcessing = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            e.toString().replaceAll('Exception: ', '')),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave(Map group) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassCard(
          padding: const EdgeInsets.all(28),
          radius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    color: AppTheme.accentPink, size: 28),
              ),
              const SizedBox(height: 16),
              Text('Leave Board',
                  style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'You\'ll need a new invite code to rejoin "${group['name']}".',
                textAlign: TextAlign.center,
                style: AppTheme.dmSans(color: AppTheme.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.textPrimary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text('Cancel',
                              style: AppTheme.dmSans(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlowButton(
                      label: 'Leave',
                      accent: AppTheme.accentPink,
                      height: 48,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      await ApiService.leaveGroup(group['id'] as int);
      _load();
    }
  }

  void _showCodes(Map group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(ctx).padding.bottom + 20),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          radius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accentBlue, AppTheme.accentViolet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.share_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invite Codes',
                          style: AppTheme.sora(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(group['name'],
                          style: AppTheme.dmSans(
                              fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentAmber.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentAmber.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded,
                        color: AppTheme.accentAmber, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Only the board creator can use the Admin code.',
                        style:
                            AppTheme.dmSans(fontSize: 12, color: AppTheme.accentAmber),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _codeTile(
                icon: Icons.people_alt_rounded,
                label: 'Student Code',
                code: 'std@${group['invite_link']}',
                color: AppTheme.accentBlue,
              ),
              const SizedBox(height: 10),
              _codeTile(
                icon: Icons.admin_panel_settings_rounded,
                label: 'Admin Code',
                code: 'ad@${group['invite_link']}',
                color: AppTheme.accentViolet,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _codeTile({
    required IconData icon,
    required String label,
    required String code,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.dmSans(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(code,
                    style: AppTheme.mono(
                        fontSize: 13, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$label copied')));
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.copy_rounded, color: color, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── MAIN BUILD ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 20, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notices',
                  style:
                      AppTheme.sora(fontSize: 26, fontWeight: FontWeight.w800)),
              Text(
                _isStaff ? 'Manage your boards' : 'Stay up to date',
                style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textMuted),
              ),
            ],
          ),
          const Spacer(),
          GlowButton(
            label: _isStaff ? '+ Create' : '+ Join',
            accent: _isStaff ? AppTheme.accentTeal : AppTheme.accentBlue,
            height: 42,
            onPressed: _showActionDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: 4,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _shimmerCard(),
        ),
      );
    }

    if (_groups.isEmpty) return _emptyState();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accentBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        itemCount: _groups.length,
        itemBuilder: (ctx, i) => StaggerEntry(
          parent: _animController,
          index: i,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _groupCard(_groups[i]),
          ),
        ),
      ),
    );
  }

  Widget _groupCard(Map g) {
    final isAdmin = g['role'] == 'ADMIN';
    final accent = isAdmin ? AppTheme.accentTeal : AppTheme.accentBlue;

    return GlassCard(
      radius: 22,
      glowColor: accent,
      onTap: () async {
        await Navigator.push(
          context,
          AppTheme.slideRoute(AnnouncementChatScreen(
            groupId: g['id'],
            groupName: g['name'],
            isAdmin: isAdmin,
          )),
        );
        _load();
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Gradient icon box
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent,
                    Color.lerp(accent, const Color(0xFF1A50A0), 0.35)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.campaign_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g['name'],
                    style: AppTheme.sora(fontSize: 15, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withOpacity(0.22)),
                    ),
                    child: Text(
                      isAdmin ? '⚡ Admin' : '👤 Member',
                      style: AppTheme.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              GestureDetector(
                onTap: () => _showCodes(g),
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentBlue.withOpacity(0.15)),
                  ),
                  child: const Icon(Icons.share_rounded,
                      color: AppTheme.accentBlue, size: 17),
                ),
              ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'leave') _confirmLeave(g);
              },
              color: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.more_vert_rounded,
                    color: AppTheme.textMuted, size: 18),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded,
                          color: AppTheme.accentPink, size: 18),
                      const SizedBox(width: 10),
                      Text('Leave Board',
                          style: AppTheme.dmSans(color: AppTheme.accentPink)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentBlue.withOpacity(0.12),
                    AppTheme.accentBlue.withOpacity(0.0),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.campaign_outlined,
                size: 50,
                color: AppTheme.accentBlue.withOpacity(0.35),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              _isStaff ? 'No boards yet' : 'Not in any board',
              style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Text(
              _isStaff
                  ? 'Create a board to start broadcasting notices to your students.'
                  : 'Use an invite code from your teacher to join a board.',
              textAlign: TextAlign.center,
              style: AppTheme.dmSans(
                  fontSize: 14, color: AppTheme.textMuted, height: 1.6),
            ),
            const SizedBox(height: 30),
            GlowButton(
              label: _isStaff ? 'Create Board' : 'Join Board',
              accent: _isStaff ? AppTheme.accentTeal : AppTheme.accentBlue,
              height: 52,
              onPressed: _showActionDialog,
              icon: Icon(
                _isStaff
                    ? Icons.add_circle_outline_rounded
                    : Icons.login_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard() {
    return GlassCard(
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            ShimmerBox(width: 52, height: 52, borderRadius: 16),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 160, height: 14),
                const SizedBox(height: 8),
                ShimmerBox(width: 80, height: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}