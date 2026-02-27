// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../config/app_config.dart';
// import '../../services/api_service.dart';
// import '../../theme/app_theme.dart';

// class AnalyticsScreen extends StatefulWidget {
//   final int contentId;
//   final String title;
//   final String type;

//   const AnalyticsScreen({Key? key, required this.contentId, required this.title, required this.type}) : super(key: key);

//   @override
//   State<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }

// class _AnalyticsScreenState extends State<AnalyticsScreen> {
//   List<dynamic> submissions = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   Future<void> fetchData() async {
//     try {
//       final token = await ApiService.getToken();
//       final endpoint = widget.type == 'assignments' 
//           ? 'assignments/${widget.contentId}/submissions' 
//           : 'tests/${widget.contentId}/results';

//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/$endpoint'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           submissions = jsonDecode(response.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(title: Text("${widget.title} Analytics")),
//         body: isLoading 
//             ? const Center(child: CircularProgressIndicator())
//             : submissions.isEmpty
//                 ? Center(child: Text("No submissions yet.", style: AppTheme.dmSans(color: AppTheme.textMuted)))
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: submissions.length,
//                     itemBuilder: (ctx, i) {
//                       final sub = submissions[i];
//                       final date = DateTime.parse(sub['submitted_at']);
                      
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: GlassCard(
//                           padding: const EdgeInsets.all(16),
//                           child: Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: AppTheme.accentBlue.withOpacity(0.15),
//                                 radius: 24,
//                                 child: Text(sub['student_name'][0], style: AppTheme.sora(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(sub['student_name'], style: AppTheme.sora(fontSize: 16)),
//                                     const SizedBox(height: 4),
//                                     Text("Submitted: ${DateFormat('MMM dd, HH:mm').format(date.toLocal())}", 
//                                       style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
//                                   ],
//                                 ),
//                               ),
//                               widget.type == 'tests'
//                                   ? Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                       decoration: AppTheme.statusBadgeDecor('ACCEPTED'),
//                                       child: Text(
//                                         "${sub['score']} / ${sub['total']}",
//                                         style: AppTheme.dmSans(fontWeight: FontWeight.bold, color: AppTheme.statusAccepted),
//                                       ),
//                                     )
//                                   : IconButton(
//                                       icon: const Icon(Icons.download, color: AppTheme.accentBlue),
//                                       onPressed: () => launchUrl(Uri.parse('${AppConfig.baseUrl}${sub['file_url']}')),
//                                     ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  final int contentId;
  final String title;
  final String type;

  const AnalyticsScreen({
    Key? key,
    required this.contentId,
    required this.title,
    required this.type,
  }) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> submissions = [];
  bool isLoading = true;
  late AnimationController _animCtrl;

  bool get isTest => widget.type == 'tests';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fetchData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final token = await ApiService.getToken();
      final endpoint = isTest
          ? 'tests/${widget.contentId}/results'
          : 'assignments/${widget.contentId}/submissions';

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/classroom/$endpoint'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          submissions = jsonDecode(response.body);
          isLoading = false;
        });
        _animCtrl.forward();
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  double get _avgScore {
    if (submissions.isEmpty) return 0;
    final total = submissions.fold<double>(
        0, (sum, s) => sum + (s['score'] as num).toDouble());
    return total / submissions.length;
  }

  int? get _maxTotal {
    if (submissions.isEmpty) return null;
    return (submissions.first['total'] as num?)?.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            isTest ? 'Test Results' : 'Submissions',
            style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isLoading
            ? _buildShimmer()
            : submissions.isEmpty
                ? _buildEmpty()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: AppTheme.sora(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${submissions.length} ${isTest ? 'result${submissions.length != 1 ? 's' : ''}' : 'submission${submissions.length != 1 ? 's' : ''}'}',
                                style: AppTheme.dmSans(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary),
                              ),
                              if (isTest && submissions.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Submissions',
                                        value: '${submissions.length}',
                                        icon: Icons.people_alt_rounded,
                                        color: AppTheme.accentBlue,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        label: 'Avg Score',
                                        value:
                                            '${_avgScore.toStringAsFixed(1)} / ${_maxTotal ?? '—'}',
                                        icon: Icons.insights_rounded,
                                        color: AppTheme.accentTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final sub = submissions[i];
                              final date =
                                  DateTime.parse(sub['submitted_at']);
                              return StaggerEntry(
                                index: i,
                                parent: _animCtrl,
                                interval: 0.07,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: _SubmissionCard(
                                    submission: sub,
                                    date: date,
                                    isTest: isTest,
                                  ),
                                ),
                              );
                            },
                            childCount: submissions.length,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ShimmerCard(),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.accentBlue.withOpacity(0.25),
                      width: 1.5),
                ),
                child: Icon(
                  isTest ? Icons.quiz_outlined : Icons.inbox_outlined,
                  size: 48,
                  color: AppTheme.accentBlue,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No submissions yet',
                style: AppTheme.sora(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                isTest
                    ? 'Student results will appear here once they complete the test.'
                    : 'Student file submissions will appear here.',
                textAlign: TextAlign.center,
                style: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5),
              ),
            ],
          ),
        ),
      );
}

// ─── Animated shimmer card ────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.30, end: 0.60)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: Colors.white.withOpacity(0.80), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: AppTheme.accentBlue.withOpacity(0.06),
                blurRadius: 20)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(_a.value * 0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 12,
                    width: 130,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(_a.value * 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 85,
                    decoration: BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(_a.value * 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 58,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(_a.value * 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Submission card ─────────────────────────────────────────────
class _SubmissionCard extends StatelessWidget {
  final dynamic submission;
  final DateTime date;
  final bool isTest;

  const _SubmissionCard({
    required this.submission,
    required this.date,
    required this.isTest,
  });

  @override
  Widget build(BuildContext context) {
    final name = (submission['student_name'] as String?) ?? 'Unknown';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    Color scoreColor = AppTheme.statusAccepted;
    if (isTest) {
      final score = (submission['score'] as num).toDouble();
      final total = (submission['total'] as num).toDouble();
      final pct = total > 0 ? score / total : 0.0;
      if (pct < 0.4) {
        scoreColor = AppTheme.statusRejected;
      } else if (pct < 0.7) {
        scoreColor = AppTheme.statusPending;
      }
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.accentBlue.withOpacity(0.30), width: 1.5),
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTheme.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: AppTheme.sora(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.schedule_rounded,
                      size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, HH:mm').format(date.toLocal()),
                    style: AppTheme.dmSans(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ]),
              ],
            ),
          ),
          if (isTest)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withOpacity(0.35)),
              ),
              child: Text(
                '${submission['score']} / ${submission['total']}',
                style: AppTheme.mono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scoreColor),
              ),
            )
          else
            GestureDetector(
              onTap: () => launchUrl(
                  Uri.parse(
                      '${AppConfig.baseUrl}${submission['file_url']}')),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppTheme.accentBlue.withOpacity(0.30)),
                ),
                child: const Icon(Icons.download_rounded,
                    color: AppTheme.accentBlue, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: color,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.dmSans(
                        fontSize: 11, color: AppTheme.textSecondary)),
                const SizedBox(height: 3),
                Text(value,
                    style: AppTheme.sora(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}