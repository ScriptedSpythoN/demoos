import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class MedicalDetailScreen extends StatefulWidget {
  final MedicalEntry entry;
  const MedicalDetailScreen({super.key, required this.entry});

  @override
  State<MedicalDetailScreen> createState() => _MedicalDetailScreenState();
}

class _MedicalDetailScreenState extends State<MedicalDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _remarkController = TextEditingController();
  bool _isProcessing = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitDecision(String action) async {
    if (action == 'REJECTED' && _remarkController.text.trim().isEmpty) {
      _showSnackBar(
        'A remark is required when rejecting a request.',
        AppTheme.accentAmber,
        Icons.info_outline_rounded,
      );
      return;
    }

    final confirmed = await _showConfirmDialog(action);
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      await ApiService.reviewMedical(
        widget.entry.requestId,
        action,
        _remarkController.text.trim(),
      );
      if (mounted) {
        _showSnackBar(
          action == 'APPROVED'
              ? 'Request approved successfully'
              : 'Request rejected',
          action == 'APPROVED' ? AppTheme.accentTeal : AppTheme.accentPink,
          action == 'APPROVED'
              ? Icons.check_circle_rounded
              : Icons.cancel_rounded,
        );
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Error: $e',
          AppTheme.accentPink,
          Icons.error_outline_rounded,
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool> _showConfirmDialog(String action) async {
    final isApprove = action == 'APPROVED';
    final accentColor = isApprove ? AppTheme.accentTeal : AppTheme.accentPink;

    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            // Picks up dialogTheme from AppTheme.lightTheme automatically
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Accent icon circle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: accentColor.withOpacity(0.25)),
                  ),
                  child: Icon(
                    isApprove
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: accentColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isApprove ? 'Approve Request?' : 'Reject Request?',
                  // Uses dialogTheme.titleTextStyle (Sora bold)
                ),
                const SizedBox(height: 8),
                Text(
                  isApprove
                      ? 'This will approve the medical leave for ${widget.entry.studentRollNo}.'
                      : 'This will reject the medical leave request. The student will be notified.',
                  textAlign: TextAlign.center,
                  // Uses dialogTheme.contentTextStyle (DM Sans)
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  'Cancel',
                  style: AppTheme.dmSans(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Themed filled button
              GestureDetector(
                onTap: () => Navigator.pop(ctx, true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isApprove ? 'Approve' : 'Reject',
                    style: AppTheme.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Uses snackBarTheme from AppTheme.lightTheme (floating, glass-white)
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTheme.dmSans(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMismatch = widget.entry.ocrStatus == 'MISMATCH';
    final dayCount =
        widget.entry.toDate.difference(widget.entry.fromDate).inDays + 1;

    return Scaffold(
      backgroundColor: Colors.transparent, // AppBackground provides the gradient
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Transparent AppBar — inherits AppTheme.lightTheme appBarTheme
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medical Review', style: AppTheme.sora(fontSize: 18)),
            Text(
              widget.entry.studentRollNo,
              style: AppTheme.dmSans(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Themed PENDING badge using StatusBadge widget
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge('PENDING')),
          ),
        ],
      ),
      body: AppBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── AI Mismatch Warning ──────────────────────────
                  if (hasMismatch) ...[
                    _buildAiWarningBanner(),
                    const SizedBox(height: 16),
                  ],

                  // ── Student Info Card ────────────────────────────
                  _buildStudentInfoCard(dayCount),
                  const SizedBox(height: 16),

                  // ── Date Range Card ──────────────────────────────
                  _buildDateRangeCard(),
                  const SizedBox(height: 16),

                  // ── Reason Card ──────────────────────────────────
                  _buildReasonCard(),
                  const SizedBox(height: 16),

                  // ── Document Card ────────────────────────────────
                  _buildDocumentCard(),
                  const SizedBox(height: 16),

                  // ── OCR Section ──────────────────────────────────
                  if (widget.entry.ocrText != null &&
                      widget.entry.ocrText!.isNotEmpty) ...[
                    _buildOcrCard(hasMismatch),
                    const SizedBox(height: 16),
                  ],

                  // ── HOD Remark ───────────────────────────────────
                  _buildRemarkSection(),
                  const SizedBox(height: 28),

                  // ── Action Buttons ───────────────────────────────
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── AI Warning Banner ──────────────────────────────────────────────
  Widget _buildAiWarningBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.accentPink.withOpacity(0.40),
      glowColor: AppTheme.accentPink,
      color: AppTheme.accentPink.withOpacity(0.06),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentPink.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.smart_toy_rounded,
                color: AppTheme.accentPink, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Verification Warning',
                  style: AppTheme.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentPink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The document dates don\'t match the claimed leave period. Please verify carefully before approving.',
                  style: AppTheme.dmSans(
                    fontSize: 12,
                    color: AppTheme.accentPink,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Student Info Card ──────────────────────────────────────────────
  Widget _buildStudentInfoCard(int dayCount) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: AppTheme.accentViolet,
      child: Row(
        children: [
          // Avatar showing last 2 chars of roll number
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.accentViolet, AppTheme.accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentViolet.withOpacity(0.30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.entry.studentRollNo.length >= 2
                    ? widget.entry.studentRollNo.substring(
                        widget.entry.studentRollNo.length - 2)
                    : widget.entry.studentRollNo,
                style: AppTheme.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.entry.studentRollNo,
                  style: AppTheme.sora(fontSize: 15, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Computer Science Department',
                  style: AppTheme.dmSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Day count pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accentViolet.withOpacity(0.20)),
            ),
            child: Column(
              children: [
                Text(
                  '$dayCount',
                  style: AppTheme.sora(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentViolet,
                  ),
                ),
                Text(
                  dayCount == 1 ? 'day' : 'days',
                  style: AppTheme.dmSans(
                    fontSize: 11,
                    color: AppTheme.accentViolet,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Range Card ────────────────────────────────────────────────
  Widget _buildDateRangeCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Leave Period', Icons.date_range_rounded),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateBlock(
                  'From',
                  widget.entry.fromDate,
                  AppTheme.accentBlue,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ),
              Expanded(
                child: _buildDateBlock(
                  'To',
                  widget.entry.toDate,
                  AppTheme.accentViolet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateBlock(String label, DateTime date, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTheme.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color.withOpacity(0.75),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _fmt(date),
            style: AppTheme.sora(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Reason Card ────────────────────────────────────────────────────
  Widget _buildReasonCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Reason for Leave', Icons.description_rounded),
          const SizedBox(height: 12),
          Text(
            widget.entry.reason,
            style: AppTheme.dmSans(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Document Card ──────────────────────────────────────────────────
  Widget _buildDocumentCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Attached Certificate', Icons.attach_file_rounded),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening PDF Viewer...')),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppTheme.accentPink.withOpacity(0.18),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppTheme.accentPink,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medical Certificate.pdf',
                          style: AppTheme.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tap to view document',
                          style: AppTheme.dmSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppTheme.accentPink.withOpacity(0.60),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── OCR Card ───────────────────────────────────────────────────────
  Widget _buildOcrCard(bool hasMismatch) {
    final statusColor =
        hasMismatch ? AppTheme.accentPink : AppTheme.accentTeal;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderColor: statusColor.withOpacity(0.35),
      glowColor: statusColor,
      color: statusColor.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, size: 16, color: statusColor),
              const SizedBox(width: 8),
              Text(
                'AI OCR Extraction',
                style: AppTheme.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              // Re-use StatusBadge logic via a manual themed pill here
              // since OCR status is custom (MISMATCH/VERIFIED, not leave status)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: statusColor.withOpacity(0.35)),
                ),
                child: Text(
                  hasMismatch ? 'MISMATCH' : 'VERIFIED',
                  style: AppTheme.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.glassFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Text(
              widget.entry.ocrText ?? '',
              style: AppTheme.mono(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HOD Remark TextField ───────────────────────────────────────────
  Widget _buildRemarkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('HOD Remarks', Icons.rate_review_rounded),
        const SizedBox(height: 12),
        // GlassCard wraps the TextField to keep the frosted look consistent
        GlassCard(
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _remarkController,
            maxLines: 4,
            // inputDecorationTheme from AppTheme.lightTheme styles this
            decoration: const InputDecoration(
              hintText: 'Add notes (required for rejection)...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.all(16),
            ),
            style: AppTheme.dmSans(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────
  Widget _buildActionButtons() {
    if (_isProcessing) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppTheme.accentViolet,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        // ── Reject — outlined ghost button ──────────────────────
        Expanded(
          child: GestureDetector(
            onTap: () => _submitDecision('REJECTED'),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withOpacity(0.07),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppTheme.accentPink.withOpacity(0.55),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close_rounded,
                      color: AppTheme.accentPink, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reject',
                    style: AppTheme.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentPink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        // ── Approve — GlowButton (AppTheme CTA component) ───────
        Expanded(
          flex: 2,
          child: GlowButton(
            label: 'Approve',
            accent: AppTheme.accentTeal,
            onPressed: () => _submitDecision('APPROVED'),
            height: 56,
            icon: const Icon(Icons.check_rounded,
                color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // ── Shared section label ───────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentViolet),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTheme.sora(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}