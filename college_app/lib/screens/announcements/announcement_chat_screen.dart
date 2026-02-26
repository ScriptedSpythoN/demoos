import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../config/app_config.dart';

const _kEmojis = ['👍', '❤️', '😮', '😂', '🔥', '👏'];

class AnnouncementChatScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final bool isAdmin;

  const AnnouncementChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.isAdmin,
  });

  @override
  State<AnnouncementChatScreen> createState() => _AnnouncementChatScreenState();
}

class _AnnouncementChatScreenState extends State<AnnouncementChatScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _msgs = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String? _filterTag;
  final TextEditingController _ctrl = TextEditingController();
  late AnimationController _animController;

  static const _defaultTags = [
    'Urgent', 'Notice', 'Exam', 'Placement', 'Event', 'Holiday'
  ];

  /// Builds filter tag list: default presets + any custom tags found in loaded messages.
  List<String> get _allTags {
    final customTags = <String>{};
    for (final m in _msgs) {
      for (final t in (m['tags'] as List)) {
        final tag = t.toString();
        if (!_defaultTags.contains(tag)) customTags.add(tag);
      }
    }
    return ['All', ..._defaultTags, ...customTags.toList()..sort()];
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fetch();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final data = await ApiService.fetchAnnouncements(widget.groupId);
      if (mounted) {
        setState(() {
          _msgs = data;
          _apply();
          _loading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _apply() {
    _filtered = _filterTag == null
        ? List.from(_msgs)
        : _msgs.where((m) => (m['tags'] as List).contains(_filterTag)).toList();
  }

  // ── POST ───────────────────────────────────────────────────────

  void _postFlow(String type,
      {String? content, File? file, List<String>? pollOptions}) {
    List<String> selected = [];
    const defaultTags = ['Urgent', 'Notice', 'Exam', 'Placement', 'Event', 'Holiday'];
    final customTagCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 0, 16, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            radius: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Tag this notice',
                    style: AppTheme.sora(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Select presets or add custom tags',
                    style:
                        AppTheme.dmSans(fontSize: 13, color: AppTheme.textMuted)),
                const SizedBox(height: 16),
                // ── Preset tags ──────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...defaultTags.map((t) {
                      final sel = selected.contains(t);
                      final color = _tagColor(t);
                      return GestureDetector(
                        onTap: () => setS(() =>
                            sel ? selected.remove(t) : selected.add(t)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? color.withOpacity(0.15)
                                : AppTheme.textPrimary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(
                              color: sel
                                  ? color.withOpacity(0.50)
                                  : AppTheme.textPrimary.withOpacity(0.10),
                              width: sel ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (sel) ...[
                                Icon(Icons.check_rounded, size: 14, color: color),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                '#$t',
                                style: AppTheme.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: sel ? color : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    // ── Custom tags already added ────────────────
                    ...selected
                        .where((t) => !defaultTags.contains(t))
                        .map((t) => GestureDetector(
                              onTap: () => setS(() => selected.remove(t)),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: AppTheme.accentAmber.withOpacity(0.50),
                                      width: 1.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.close_rounded,
                                        size: 13, color: AppTheme.accentAmber),
                                    const SizedBox(width: 4),
                                    Text(
                                      '#$t',
                                      style: AppTheme.dmSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentAmber,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                  ],
                ),
                const SizedBox(height: 14),
                // ── Custom tag input row ─────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: customTagCtrl,
                        style: AppTheme.dmSans(fontSize: 14),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText: 'Add custom tag...',
                          prefixIcon: const Icon(Icons.label_outline_rounded,
                              color: AppTheme.accentAmber, size: 18),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          filled: true,
                          fillColor: AppTheme.accentAmber.withOpacity(0.06),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: AppTheme.accentAmber.withOpacity(0.25)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppTheme.accentAmber, width: 1.5),
                          ),
                        ),
                        onSubmitted: (val) {
                          final trimmed = val.trim();
                          if (trimmed.isNotEmpty && !selected.contains(trimmed)) {
                            setS(() {
                              selected.add(trimmed);
                              customTagCtrl.clear();
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final trimmed = customTagCtrl.text.trim();
                        if (trimmed.isNotEmpty && !selected.contains(trimmed)) {
                          setS(() {
                            selected.add(trimmed);
                            customTagCtrl.clear();
                          });
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentAmber.withOpacity(0.30),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                GlowButton(
                  label: 'Post Notice',
                  accent: AppTheme.accentTeal,
                  height: 50,
                  onPressed: selected.isEmpty
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          try {
                            await ApiService.postAnnouncement(
                              groupId: widget.groupId,
                              type: type,
                              content: content,
                              tags: selected,
                              file: file,
                              pollOptions: pollOptions,
                            );
                            _ctrl.clear();
                            _fetch();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())));
                            }
                          }
                        },
                  icon: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPollCreator() {
    final List<TextEditingController> optCtrls = [
      TextEditingController(),
      TextEditingController(),
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            radius: 24,
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
                          colors: [AppTheme.accentViolet, AppTheme.accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.poll_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Create Poll',
                        style: AppTheme.sora(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 20),
                ...optCtrls.asMap().entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: e.value,
                        style: AppTheme.dmSans(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Option ${e.key + 1}',
                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppTheme.accentViolet.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: AppTheme.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accentViolet,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )),
                if (optCtrls.length < 6)
                  GestureDetector(
                    onTap: () =>
                        setS(() => optCtrls.add(TextEditingController())),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentViolet.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentViolet.withOpacity(0.20),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline_rounded,
                              color: AppTheme.accentViolet, size: 18),
                          const SizedBox(width: 8),
                          Text('Add option',
                              style: AppTheme.dmSans(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentViolet,
                                fontSize: 14,
                              )),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
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
                        label: 'Next',
                        accent: AppTheme.accentViolet,
                        height: 48,
                        onPressed: () {
                          final opts = optCtrls
                              .map((c) => c.text.trim())
                              .where((t) => t.isNotEmpty)
                              .toList();
                          if (opts.length < 2) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Enter at least 2 options')),
                            );
                            return;
                          }
                          Navigator.pop(ctx);
                          _postFlow('POLL',
                              content: 'Poll', pollOptions: opts);
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

  Future<void> _deleteAnnouncement(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accentPink.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: AppTheme.accentPink, size: 26),
              ),
              const SizedBox(height: 14),
              Text('Delete Notice',
                  style: AppTheme.sora(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('This notice will be permanently removed.',
                  textAlign: TextAlign.center,
                  style: AppTheme.dmSans(
                      color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx, false),
                      child: Container(
                        height: 46,
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
                      label: 'Delete',
                      accent: AppTheme.accentPink,
                      height: 46,
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
      await ApiService.deleteAnnouncement(widget.groupId, id);
      _fetch();
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.groupName,
                style: AppTheme.sora(
                    fontSize: 17, fontWeight: FontWeight.w700)),
            Text(
              widget.isAdmin ? 'Admin view' : 'Member view',
              style: AppTheme.dmSans(
                  fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          if (widget.isAdmin)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentTeal.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.accentTeal.withOpacity(0.30)),
              ),
              child: Text('Admin',
                  style: AppTheme.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentTeal)),
            ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildFilters(),
              Expanded(child: _buildList()),
              if (widget.isAdmin) _buildInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _allTags.map((t) {
          final isAll = t == 'All';
          final selected = isAll ? _filterTag == null : _filterTag == t;
          final color = isAll ? AppTheme.accentBlue : _tagColor(t);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() {
                _filterTag = isAll ? null : t;
                _apply();
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? color.withOpacity(0.15)
                      : Colors.white.withOpacity(0.50),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: selected
                        ? color.withOpacity(0.45)
                        : Colors.white.withOpacity(0.70),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.15),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
                child: Text(
                  isAll ? 'All' : '#$t',
                  style: AppTheme.dmSans(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? color : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _shimmerMsg(),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 56,
                color: AppTheme.textMuted.withOpacity(0.40)),
            const SizedBox(height: 12),
            Text(
              _filterTag == null
                  ? 'No notices yet'
                  : 'No #$_filterTag notices',
              style: AppTheme.dmSans(color: AppTheme.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetch,
      color: AppTheme.accentBlue,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _filtered.length,
        itemBuilder: (ctx, i) => StaggerEntry(
          parent: _animController,
          index: i,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMsg(_filtered[i]),
          ),
        ),
      ),
    );
  }

  Widget _buildMsg(Map m) {
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: (m['tags'] as List)
                      .map((t) => _tagChip(t.toString()))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMM, HH:mm')
                    .format(DateTime.parse(m['created_at'])),
                style: AppTheme.dmSans(
                    fontSize: 11, color: AppTheme.textMuted),
              ),
              if (widget.isAdmin) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _deleteAnnouncement(m['id'] as int),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.accentPink, size: 15),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          // Content
          _buildContent(m),
          const SizedBox(height: 14),
          // Divider
          Container(
            height: 1,
            color: AppTheme.accentBlue.withOpacity(0.08),
          ),
          const SizedBox(height: 12),
          // Reactions
          _buildReactions(m),
        ],
      ),
    );
  }

  Widget _buildContent(Map m) {
    switch (m['type'] as String) {
      case 'TEXT':
        return Text(
          m['content'] ?? '',
          style: AppTheme.dmSans(fontSize: 15, height: 1.55),
        );

      case 'IMAGE':
        if (m['file_url'] == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () =>
              launchUrl(Uri.parse('${AppConfig.baseUrl}${m['file_url']}')),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              '${AppConfig.baseUrl}${m['file_url']}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppTheme.bgSoftBlue,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                          child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, __, ___) => Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.bgSoftBlue,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        color: AppTheme.accentBlue)),
              ),
            ),
          ),
        );

      case 'PDF':
        return _fileButton(
          icon: Icons.picture_as_pdf_rounded,
          label: 'View PDF',
          color: AppTheme.accentPink,
          url: '${AppConfig.baseUrl}${m['file_url']}',
        );

      case 'AUDIO':
        return _fileButton(
          icon: Icons.headphones_rounded,
          label: 'Play Audio',
          color: AppTheme.accentViolet,
          url: '${AppConfig.baseUrl}${m['file_url']}',
        );

      case 'POLL':
        return _buildPoll(m);

      default:
        return Text(m['content'] ?? '',
            style: AppTheme.dmSans(fontSize: 15));
    }
  }

  Widget _fileButton({
    required IconData icon,
    required String label,
    required Color color,
    required String url,
  }) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url)),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTheme.dmSans(
                      fontWeight: FontWeight.w600, color: color)),
            ),
            Icon(Icons.open_in_new_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPoll(Map m) {
    final opts = (m['poll_options'] as List?) ?? [];
    final total = (m['poll_total_votes'] as int?) ?? 0;
    final myVote = m['my_vote_option_id'] as int?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (m['content'] != null &&
            (m['content'] as String).isNotEmpty &&
            m['content'] != 'Poll')
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(m['content'],
                style: AppTheme.sora(
                    fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ...opts.map((opt) {
          final votes = (opt['votes'] as int?) ?? 0;
          final pct = total > 0 ? votes / total : 0.0;
          final isSelected = myVote == opt['id'];
          const color = AppTheme.accentViolet;

          return GestureDetector(
            onTap: () async {
              await ApiService.votePoll(m['id'] as int, opt['id'] as int);
              _fetch();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.08)
                    : Colors.white.withOpacity(0.50),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: isSelected
                      ? color.withOpacity(0.45)
                      : AppTheme.textPrimary.withOpacity(0.08),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    // Progress bar fill
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      widthFactor: pct,
                      child: Container(
                        color: color.withOpacity(0.12),
                      ),
                    ),
                    // Content row
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : AppTheme.textMuted,
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    size: 12,
                                    color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(opt['text'] ?? '',
                                style: AppTheme.dmSans(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? color
                                        : AppTheme.textPrimary)),
                          ),
                          Text(
                            total > 0
                                ? '${(pct * 100).round()}%'
                                : '$votes',
                            style: AppTheme.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? color
                                    : AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        Text(
          '$total vote${total != 1 ? 's' : ''}',
          style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildReactions(Map m) {
    final reactions = (m['reactions'] as Map?) ?? {};
    final myReaction = m['my_reaction'] as String?;
    final id = m['id'] as int;

    return Row(
      children: [
        // Emoji picker trigger
        GestureDetector(
          onTap: () => _showReactionPicker(id, myReaction),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: myReaction != null
                  ? AppTheme.accentBlue.withOpacity(0.10)
                  : Colors.white.withOpacity(0.50),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: myReaction != null
                    ? AppTheme.accentBlue.withOpacity(0.30)
                    : AppTheme.textPrimary.withOpacity(0.08),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(myReaction ?? '🙂',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                Icon(
                  myReaction != null
                      ? Icons.expand_more_rounded
                      : Icons.add_rounded,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Existing reactions
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: reactions.entries
                  .where((e) => (e.value as int) > 0)
                  .map((e) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: AppTheme.textPrimary.withOpacity(0.08)),
                        ),
                        child: Text(
                          '${e.key} ${e.value}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  void _showReactionPicker(int announcementId, String? current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          radius: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('React',
                  style: AppTheme.sora(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _kEmojis
                    .map((e) => GestureDetector(
                          onTap: () async {
                            Navigator.pop(ctx);
                            await ApiService.reactToAnnouncement(
                                announcementId, e);
                            _fetch();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: current == e
                                  ? AppTheme.accentBlue.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.60),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: current == e
                                    ? AppTheme.accentBlue.withOpacity(0.40)
                                    : AppTheme.textPrimary.withOpacity(0.08),
                                width: current == e ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(e,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── INPUT BAR ─────────────────────────────────────────────────

  Widget _buildInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        border: Border(
            top: BorderSide(color: AppTheme.accentBlue.withOpacity(0.10))),
      ),
      child: Row(
        children: [
          // Media button
          GestureDetector(
            onTap: _showMedia,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentBlue, AppTheme.accentViolet],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentBlue.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: GlassCard(
              radius: 22,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: TextField(
                controller: _ctrl,
                style: AppTheme.dmSans(fontSize: 14),
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Write a notice...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintStyle: AppTheme.dmSans(
                      fontSize: 14, color: AppTheme.textMuted),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: () {
              final text = _ctrl.text.trim();
              if (text.isEmpty) return;
              _postFlow('TEXT', content: text);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.accentTeal,
                borderRadius: BorderRadius.circular(13),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentTeal.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _showMedia() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(ctx).padding.bottom + 20),
        child: GlassCard(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          radius: 28,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Attach Content',
                  style: AppTheme.sora(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _mediaOption(
                    icon: Icons.image_rounded,
                    label: 'Photo',
                    color: AppTheme.accentBlue,
                    onTap: () async {
                      final img = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      if (img != null && mounted) {
                        Navigator.pop(ctx);
                        _postFlow('IMAGE', file: File(img.path));
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _mediaOption(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF',
                    color: AppTheme.accentPink,
                    onTap: () async {
                      final res = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf'],
                      );
                      if (res != null && mounted) {
                        Navigator.pop(ctx);
                        _postFlow('PDF',
                            file: File(res.files.single.path!));
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _mediaOption(
                    icon: Icons.headphones_rounded,
                    label: 'Audio',
                    color: AppTheme.accentViolet,
                    onTap: () async {
                      final res = await FilePicker.platform
                          .pickFiles(type: FileType.audio);
                      if (res != null && mounted) {
                        Navigator.pop(ctx);
                        _postFlow('AUDIO',
                            file: File(res.files.single.path!));
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _mediaOption(
                    icon: Icons.poll_rounded,
                    label: 'Poll',
                    color: AppTheme.accentAmber,
                    onTap: () {
                      Navigator.pop(ctx);
                      _showPollCreator();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mediaOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(label,
                  style: AppTheme.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────

  /// Returns a deterministic accent color for a tag.
  /// Known preset tags get fixed colors; custom tags get a color derived from their hash.
  Color _tagColor(String tag) {
    switch (tag) {
      case 'Urgent':    return AppTheme.accentPink;
      case 'Exam':      return AppTheme.accentViolet;
      case 'Placement': return AppTheme.accentTeal;
      case 'Event':     return AppTheme.accentAmber;
      case 'Holiday':   return const Color(0xFF0EB8A8);
      case 'Notice':    return AppTheme.accentBlue;
      default:
        // Custom tag — deterministic color from tag name hash
        final colors = [
          AppTheme.accentBlue,
          AppTheme.accentViolet,
          AppTheme.accentTeal,
          AppTheme.accentAmber,
          AppTheme.accentPink,
        ];
        return colors[tag.hashCode.abs() % colors.length];
    }
  }

  Widget _tagChip(String tag) {
    final color = _tagColor(tag);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        '#$tag',
        style: AppTheme.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.2),
      ),
    );
  }

  Widget _shimmerMsg() {
    return GlassCard(
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ShimmerBox(width: 60, height: 22, borderRadius: 50),
              const SizedBox(width: 8),
              ShimmerBox(width: 50, height: 22, borderRadius: 50),
            ]),
            const SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            ShimmerBox(width: 200, height: 14),
          ],
        ),
      ),
    );
  }
}