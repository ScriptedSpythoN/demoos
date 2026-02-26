import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class HodStudentDirectoryScreen extends StatefulWidget {
  final String departmentId;
  const HodStudentDirectoryScreen({super.key, required this.departmentId});

  @override
  State<HodStudentDirectoryScreen> createState() => _HodStudentDirectoryScreenState();
}

class _HodStudentDirectoryScreenState extends State<HodStudentDirectoryScreen> {
  List<dynamic> _allStudents = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchCtrl.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final data = await ApiService.fetchDepartmentAnalytics(widget.departmentId);
    if (!mounted) return;
    setState(() {
      _allStudents = data;
      _filteredStudents = data;
      _isLoading = false;
    });
  }

  void _filterStudents() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredStudents = _allStudents.where((s) {
        final name = (s['name'] ?? '').toLowerCase();
        final roll = (s['roll_no'] ?? '').toLowerCase();
        return name.contains(query) || roll.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.accentViolet))
                    : _buildStudentList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Student Directory', style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(widget.departmentId, style: AppTheme.dmSans(fontSize: 13, color: AppTheme.accentViolet)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: _searchCtrl,
          style: AppTheme.dmSans(fontSize: 14),
          decoration: InputDecoration(
            // Removed const here because textMuted is a getter
            icon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
            hintText: 'Search by name or roll number...',
            hintStyle: AppTheme.dmSans(color: AppTheme.textMuted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            fillColor: Colors.transparent, // Override theme default for this specific text field
          ),
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_filteredStudents.isEmpty) {
      return Center(
        // Removed const here because textMuted is a getter
        child: Text('No students found.', style: AppTheme.dmSans(color: AppTheme.textMuted)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        final attendance = student['overall_attendance'] as double;
        final isDefaulter = attendance < 75.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            borderColor: isDefaulter ? AppTheme.accentPink.withOpacity(0.3) : null,
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: const Border(), // Removes the default borders when expanded
              leading: Container(
                width: 45, height: 45,
                decoration: BoxDecoration(
                  color: isDefaulter ? AppTheme.accentPink.withOpacity(0.1) : AppTheme.accentViolet.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${attendance.toInt()}%',
                    style: AppTheme.mono(
                      fontSize: 13, 
                      fontWeight: FontWeight.w800, 
                      color: isDefaulter ? AppTheme.accentPink : AppTheme.accentViolet
                    ),
                  ),
                ),
              ),
              title: Text(student['name'] ?? 'Unknown', style: AppTheme.sora(fontSize: 15, fontWeight: FontWeight.w700)),
              subtitle: Text('${student['roll_no']} • Sem ${student['semester']}', 
                  // Removed const here because textSecondary is a getter
                  style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
              children: [
                _buildExpandedDetails(student),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedDetails(Map<String, dynamic> student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.glassFill, // Using the theme's glass surface color
        border: Border(top: BorderSide(color: AppTheme.glassBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Contact Info
          Text('Contact Information', style: AppTheme.sora(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _infoRow(Icons.email_outlined, student['email'] ?? 'N/A'),
          _infoRow(Icons.phone_outlined, student['contact_no'] ?? 'N/A'),
          const SizedBox(height: 12),
          Text('Guardian Details', style: AppTheme.sora(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          _infoRow(Icons.person_outline, student['guardian_name'] ?? 'N/A'),
          _infoRow(Icons.phone_outlined, student['guardian_contact_no'] ?? 'N/A'),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white30),
          ),

          // Subject Breakdown
          Text('Subject-wise Attendance', style: AppTheme.sora(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...(student['subject_breakdown'] as List).map((sub) {
            final pct = sub['percentage'] as double;
            final color = pct >= 75 ? AppTheme.accentTeal : AppTheme.accentPink;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${sub['subject_name']} (${sub['subject_code']})', 
                        style: AppTheme.dmSans(fontSize: 12)),
                  ),
                  Text('${pct.toStringAsFixed(1)}%', 
                      style: AppTheme.mono(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Removed const because textSecondary is a getter
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(text, style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}