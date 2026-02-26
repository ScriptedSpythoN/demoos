import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class StudentMedicalHistoryScreen extends StatefulWidget {
  const StudentMedicalHistoryScreen({super.key, required this.studentRollNo});
  final String studentRollNo;

  @override
  State<StudentMedicalHistoryScreen> createState() =>
      _StudentMedicalHistoryScreenState();
}

class _StudentMedicalHistoryScreenState
    extends State<StudentMedicalHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<MedicalEntry> submissions = [];
  bool isLoading = true;
  String _selectedFilter = 'All';
  late AnimationController _animController;

  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadHistory();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() => isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final allDeptIds = ['CSE'];
      List<MedicalEntry> allRequests = [];
      for (var dept in allDeptIds) {
        final reqs = await ApiService.fetchPendingMedical(dept);
        allRequests
            .addAll(reqs.where((r) => r.studentRollNo == widget.studentRollNo));
      }
      if (!mounted) return;
      setState(() {
        submissions = allRequests;
        isLoading = false;
      });
      _animController.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Error fetching history: $e',
                style: AppTheme.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          backgroundColor: AppTheme.accentPink.withOpacity(0.95),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<MedicalEntry> get _filteredSubmissions {
    if (_selectedFilter == 'All') return submissions;
    return submissions
        .where((s) => s.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  int _countByStatus(String status) {
    if (status == 'All') return submissions.length;
    return submissions
        .where((s) => s.status.toLowerCase() == status.toLowerCase())
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Medical History', style: AppTheme.sora(fontSize: 18)),
            Text(
              widget.studentRollNo,
              style: AppTheme.mono(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary, size: 20),
              onPressed: _loadHistory,
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100), // Safely clears the transparent AppBar
            if (!isLoading && submissions.isNotEmpty) _buildSummaryCards(),
            if (!isLoading && submissions.isNotEmpty) _buildFilterChips(),
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : _filteredSubmissions.isEmpty
                      ? _buildEmptyState()
                      : _buildHistoryList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatPill('Total', _countByStatus('All'), AppTheme.accentBlue),
            const SizedBox(width: 8),
            _buildStatPill('Approved', _countByStatus('Approved'), AppTheme.statusAccepted),
            const SizedBox(width: 8),
            _buildStatPill('Pending', _countByStatus('Pending'), AppTheme.statusPending),
            const SizedBox(width: 8),
            _buildStatPill('Rejected', _countByStatus('Rejected'), AppTheme.statusRejected),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2), width: 1.2),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: AppTheme.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withOpacity(0.8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          final color = _chipColor(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 12, bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : Colors.white.withOpacity(0.8),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]
                      : [],
                ),
                child: Text(
                  filter,
                  style: AppTheme.dmSans(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _chipColor(String filter) {
    switch (filter) {
      case 'Approved':
        return AppTheme.statusAccepted;
      case 'Pending':
        return AppTheme.statusPending;
      case 'Rejected':
        return AppTheme.statusRejected;
      default:
        return AppTheme.accentBlue;
    }
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredSubmissions.length,
      itemBuilder: (context, index) {
        final entry = _filteredSubmissions[index];
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = (index * 0.1).clamp(0.0, 0.8);
            final slideAnim = Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animController,
              curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic),
            ));
            final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _animController,
                curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0)),
              ),
            );
            return FadeTransition(
              opacity: fadeAnim,
              child: SlideTransition(position: slideAnim, child: child),
            );
          },
          child: _buildEntryCard(entry, index),
        );
      },
    );
  }

  Widget _buildEntryCard(MedicalEntry entry, int index) {
    final statusColor = AppTheme.statusColor(entry.status);
    final statusIcon = _statusIcon(entry.status);
    final dayCount = entry.toDate.difference(entry.fromDate).inDays + 1;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero, // We handle padding inside
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Top status bar
              Container(
                height: 4,
                color: statusColor,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(statusIcon, color: statusColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request #${index + 1}',
                                style: AppTheme.sora(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                entry.reason,
                                style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(entry.status), // Dynamically uses your AppTheme badge
                      ],
                    ),

                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.5), thickness: 1, height: 1),
                    const SizedBox(height: 16),

                    // Date Range Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: 'From',
                            value: _fmt(entry.fromDate),
                            color: AppTheme.accentBlue,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.arrow_forward_rounded,
                              size: 16, color: AppTheme.textMuted),
                        ),
                        Expanded(
                          child: _buildInfoChip(
                            icon: Icons.event_rounded,
                            label: 'To',
                            value: _fmt(entry.toDate),
                            color: AppTheme.accentViolet,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$dayCount',
                                style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                dayCount == 1 ? 'day' : 'days',
                                style: AppTheme.dmSans(fontSize: 10, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // HOD Remark
                    if (entry.hodRemark != null && entry.hodRemark!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withOpacity(0.15)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.format_quote_rounded, color: statusColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HOD Remark',
                                    style: AppTheme.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    entry.hodRemark!,
                                    style: AppTheme.dmSans(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: color.withOpacity(0.8)),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTheme.dmSans(
                  fontSize: 10,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTheme.mono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check_circle_rounded;
      case 'REJECTED':
        return Icons.cancel_rounded;
      case 'PENDING':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ShimmerBox(width: 120, height: 16, borderRadius: 6),
              const SizedBox(height: 12),
              const ShimmerBox(width: 200, height: 12, borderRadius: 4),
              const SizedBox(height: 24),
              Row(
                children: const [
                  ShimmerBox(width: 100, height: 40, borderRadius: 10),
                  SizedBox(width: 12),
                  ShimmerBox(width: 100, height: 40, borderRadius: 10),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.1), blurRadius: 20)],
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                size: 56,
                color: AppTheme.accentBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _selectedFilter == 'All'
                  ? 'No Medical Requests'
                  : 'No $_selectedFilter Requests',
              style: AppTheme.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'All'
                  ? 'Your medical leave submissions\nwill appear here'
                  : 'No requests with "$_selectedFilter" status found',
              textAlign: TextAlign.center,
              style: AppTheme.dmSans(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}