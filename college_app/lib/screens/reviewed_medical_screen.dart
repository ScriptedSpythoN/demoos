import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ReviewedMedicalScreen extends StatefulWidget {
  final String departmentId;
  const ReviewedMedicalScreen({Key? key, required this.departmentId}) : super(key: key);

  @override
  State<ReviewedMedicalScreen> createState() => _ReviewedMedicalScreenState();
}

class _ReviewedMedicalScreenState extends State<ReviewedMedicalScreen> {
  List<MedicalEntry> _allReviewed = [];
  List<MedicalEntry> _filteredReviewed = [];
  bool _isLoading = true;
  String _filterStatus = 'ALL'; // 'ALL', 'APPROVED', 'REJECTED'

  @override
  void initState() {
    super.initState();
    _loadReviewedData();
  }

  Future<void> _loadReviewedData() async {
    try {
      final data = await ApiService.fetchReviewedMedical(widget.departmentId);
      setState(() {
        _allReviewed = data;
        _filteredReviewed = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load data'),
            backgroundColor: AppTheme.accentPink.withOpacity(0.90),
          ),
        );
      }
    }
  }

  void _applyFilter(String status) {
    setState(() {
      _filterStatus = status;
      if (status == 'ALL') {
        _filteredReviewed = _allReviewed;
      } else {
        _filteredReviewed = _allReviewed.where((entry) => entry.status == status).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Essential for AppBackground to show through
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Reviewed Leaves', style: AppTheme.sora(fontSize: 18)),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: AppTheme.textPrimary),
            onSelected: _applyFilter,
            color: Colors.white.withOpacity(0.9),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'ALL', 
                child: Text('Show All', style: AppTheme.dmSans(fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: 'APPROVED', 
                child: Text('Approved Only', style: AppTheme.dmSans(color: AppTheme.accentTeal, fontWeight: FontWeight.w600)),
              ),
              PopupMenuItem(
                value: 'REJECTED', 
                child: Text('Rejected Only', style: AppTheme.dmSans(color: AppTheme.accentPink, fontWeight: FontWeight.w600)),
              ),
            ],
          )
        ],
      ),
      // AppBackground applies the beautiful white-to-blue gradient and orbs
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentViolet),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredReviewed.length,
                  itemBuilder: (context, index) {
                    final entry = _filteredReviewed[index];
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      // GlassCard gives it the frosted border and subtle shadow
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Roll: ${entry.studentRollNo}',
                                  style: AppTheme.sora(fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                // Automatically pulls your theme's green/red based on status
                                StatusBadge(entry.status), 
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Reason: ${entry.reason}', 
                              style: AppTheme.dmSans(color: AppTheme.textSecondary),
                            ),
                            if (entry.hodRemark != null && entry.hodRemark!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentViolet.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.accentViolet.withOpacity(0.1)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.format_quote_rounded, size: 14, color: AppTheme.accentViolet.withOpacity(0.7)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'HOD Remark: ${entry.hodRemark}', 
                                        style: AppTheme.dmSans(
                                          color: AppTheme.textPrimary.withOpacity(0.8), 
                                          fontStyle: FontStyle.italic,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}