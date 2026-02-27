// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../config/app_config.dart';
// import '../../services/api_service.dart';
// import '../../theme/app_theme.dart';

// class TakeTestScreen extends StatefulWidget {
//   final int testId;
//   final String title;

//   const TakeTestScreen({Key? key, required this.testId, required this.title}) : super(key: key);

//   @override
//   State<TakeTestScreen> createState() => _TakeTestScreenState();
// }

// class _TakeTestScreenState extends State<TakeTestScreen> {
//   List<dynamic> questions = [];
//   Map<int, int> answers = {}; 
//   bool isLoading = true;
//   bool isSubmitting = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchQuestions();
//   }

//   Future<void> _fetchQuestions() async {
//     try {
//       final token = await ApiService.getToken();
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/tests/${widget.testId}/questions'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           questions = jsonDecode(response.body);
//           isLoading = false;
//         });
//       } else {
//         _showError("Could not load questions. Check if test has started.");
//       }
//     } catch (e) {
//       _showError("Error loading test: $e");
//     }
//   }

//   Future<void> _submitAnswers() async {
//     setState(() => isSubmitting = true);
//     List<int> answerList = [];
//     for (int i = 0; i < questions.length; i++) {
//       answerList.add(answers[i] ?? -1); 
//     }

//     try {
//       final token = await ApiService.getToken();
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/tests/submit'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
//         body: jsonEncode({"test_id": widget.testId, "answers": answerList}),
//       );

//       if (response.statusCode == 200) {
//         final result = jsonDecode(response.body);
//         _showResultDialog(result['score'], result['total']);
//       } else {
//         _showError("Submission failed: ${response.body}");
//         setState(() => isSubmitting = false);
//       }
//     } catch (e) {
//       _showError("Error submitting: $e");
//       setState(() => isSubmitting = false);
//     }
//   }

//   void _showResultDialog(int score, int total) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppTheme.glassFillHi,
//         title: Text("Test Submitted", style: AppTheme.sora(fontSize: 20)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.check_circle, color: AppTheme.statusAccepted, size: 60),
//             const SizedBox(height: 16),
//             Text("You scored", style: AppTheme.dmSans(fontSize: 16)),
//             Text("$score / $total", style: AppTheme.sora(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.accentBlue)),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.accentBlue,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             ),
//             onPressed: () {
//               Navigator.pop(ctx); 
//               Navigator.pop(context); 
//             },
//             child: Text("Close", style: AppTheme.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//     );
//   }

//   void _showError(String msg) {
//     setState(() => isLoading = false);
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(title: Text(widget.title)),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 children: [
//                   Expanded(
//                     child: ListView.builder(
//                       padding: const EdgeInsets.all(16),
//                       itemCount: questions.length,
//                       itemBuilder: (ctx, i) {
//                         final q = questions[i];
//                         final options = List<String>.from(q['options']);
//                         return Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: GlassCard(
//                             padding: const EdgeInsets.all(20),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text("Q${i + 1}. ${q['question_text']}", 
//                                     style: AppTheme.sora(fontWeight: FontWeight.w600, fontSize: 16, height: 1.4)),
//                                 const Padding(
//                                   padding: EdgeInsets.symmetric(vertical: 12),
//                                   child: Divider(),
//                                 ),
//                                 ...options.asMap().entries.map((entry) {
//                                   final isSelected = answers[i] == entry.key;
//                                   return GestureDetector(
//                                     onTap: () => setState(() => answers[i] = entry.key),
//                                     child: AnimatedContainer(
//                                       duration: const Duration(milliseconds: 200),
//                                       margin: const EdgeInsets.only(bottom: 8),
//                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                       decoration: BoxDecoration(
//                                         color: isSelected ? AppTheme.accentBlue.withOpacity(0.1) : Colors.transparent,
//                                         border: Border.all(
//                                           color: isSelected ? AppTheme.accentBlue : AppTheme.glassBorder,
//                                           width: isSelected ? 1.5 : 1
//                                         ),
//                                         borderRadius: BorderRadius.circular(12)
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Icon(
//                                             isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//                                             color: isSelected ? AppTheme.accentBlue : AppTheme.textMuted,
//                                             size: 20,
//                                           ),
//                                           const SizedBox(width: 12),
//                                           Expanded(child: Text(entry.value, style: AppTheme.dmSans(fontSize: 15, color: isSelected ? AppTheme.accentBlue : AppTheme.textPrimary))),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 }),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//                     decoration: BoxDecoration(
//                       color: AppTheme.glassFillHi,
//                       boxShadow: [
//                         BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
//                       ]
//                     ),
//                     child: GlowButton(
//                       isLoading: isSubmitting,
//                       onPressed: _submitAnswers,
//                       accent: AppTheme.accentBlue,
//                       label: "SUBMIT TEST",
//                     ),
//                   )
//                 ],
//               ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class TakeTestScreen extends StatefulWidget {
  final int testId;
  final String title;

  const TakeTestScreen(
      {Key? key, required this.testId, required this.title})
      : super(key: key);

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> questions = [];
  Map<int, int> answers = {};
  bool isLoading = true;
  bool isSubmitting = false;
  late AnimationController _animCtrl;
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fetchQuestions();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/classroom/tests/${widget.testId}/questions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          questions = jsonDecode(response.body);
          isLoading = false;
        });
        _animCtrl.forward();
      } else {
        _showError('Could not load questions. Check if test has started.');
      }
    } catch (e) {
      _showError('Connection error: $e');
    }
  }

  Future<void> _submitAnswers() async {
    final unanswered = List.generate(questions.length, (i) => i)
        .where((i) => !answers.containsKey(i))
        .length;

    if (unanswered > 0) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Text('Submit anyway?',
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          content: Text(
            '$unanswered question${unanswered > 1 ? 's are' : ' is'} unanswered. '
            'Unanswered questions will be marked incorrect.',
            style: AppTheme.dmSans(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Go back',
                  style: AppTheme.dmSans(
                      color: AppTheme.textPrimary.withOpacity(0.55))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 11),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Submit',
                  style: AppTheme.dmSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    setState(() => isSubmitting = true);

    final answerList =
        List.generate(questions.length, (i) => answers[i] ?? -1);

    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/classroom/tests/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'test_id': widget.testId,
          'answers': answerList,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultDialog(result['score'], result['total']);
      } else {
        _showError('Submission failed: ${response.body}');
        setState(() => isSubmitting = false);
      }
    } catch (e) {
      _showError('Error: $e');
      setState(() => isSubmitting = false);
    }
  }

  void _showResultDialog(int score, int total) {
    final pct = total > 0 ? score / total : 0.0;
    final Color color = pct >= 0.7
        ? AppTheme.statusAccepted
        : pct >= 0.4
            ? AppTheme.statusPending
            : AppTheme.statusRejected;

    final String grade = pct >= 0.9
        ? 'Excellent!'
        : pct >= 0.7
            ? 'Well done!'
            : pct >= 0.5
                ? 'Good effort!'
                : 'Keep practising!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        contentPadding:
            const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: color.withOpacity(0.35), width: 2),
              ),
              child: Center(
                child: Icon(
                  pct >= 0.7
                      ? Icons.emoji_events_rounded
                      : Icons.school_rounded,
                  color: color,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Test Submitted',
                style: AppTheme.sora(
                    fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(grade,
                style: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary.withOpacity(0.55))),
            const SizedBox(height: 20),
            // Score box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$score',
                        style: AppTheme.sora(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 10),
                        child: Text(
                          ' / $total',
                          style: AppTheme.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(color),
                      minHeight: 7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${(pct * 100).toStringAsFixed(0)}%',
                    style: AppTheme.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text('Done',
                    style: AppTheme.dmSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final answered = answers.length;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.title,
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: isLoading || questions.isEmpty
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: total > 0 ? answered / total : 0,
                    backgroundColor:
                        AppTheme.accentBlue.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(
                        AppTheme.accentBlue),
                    minHeight: 3,
                  ),
                ),
        ),
        body: isLoading
            ? _buildShimmer()
            : Column(
                children: [
                  // ── Progress bar + info strip ─────────────────
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        // Answered count badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.80),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.90)),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.accentBlue
                                      .withOpacity(0.08),
                                  blurRadius: 10)
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 14,
                                  color: AppTheme.accentTeal),
                              const SizedBox(width: 6),
                              Text(
                                '$answered / $total answered',
                                style: AppTheme.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Question number dots
                        Flexible(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 4,
                            alignment: WrapAlignment.end,
                            children: List.generate(total, (i) {
                              final isActive = i == _currentPage;
                              final isDone = answers.containsKey(i);
                              return GestureDetector(
                                onTap: () => _pageCtrl.animateToPage(
                                  i,
                                  duration: const Duration(
                                      milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 200),
                                  width: isActive ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isDone
                                        ? AppTheme.accentBlue
                                        : isActive
                                            ? AppTheme.accentBlue
                                                .withOpacity(0.45)
                                            : AppTheme.textPrimary
                                                .withOpacity(0.18),
                                    borderRadius:
                                        BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Questions pager ──────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageCtrl,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      itemCount: total,
                      itemBuilder: (ctx, i) {
                        final q = questions[i];
                        final opts =
                            List<String>.from(q['options']);
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                              16, 4, 16, 16),
                          physics: const BouncingScrollPhysics(),
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Q badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentViolet
                                            .withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: AppTheme.accentViolet
                                                .withOpacity(0.25)),
                                      ),
                                      child: Text(
                                        'Question ${i + 1} of $total',
                                        style: AppTheme.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.accentViolet,
                                        ),
                                      ),
                                    ),
                                    if (answers.containsKey(i))
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.statusAccepted
                                              .withOpacity(0.10),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(children: [
                                          Icon(
                                              Icons
                                                  .check_circle_rounded,
                                              size: 12,
                                              color: AppTheme
                                                  .statusAccepted),
                                          const SizedBox(width: 4),
                                          Text('Answered',
                                              style: AppTheme.dmSans(
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: AppTheme
                                                      .statusAccepted)),
                                        ]),
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                // Question text
                                Text(
                                  q['question_text'],
                                  style: AppTheme.sora(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    height: 1.45,
                                  ),
                                ),

                                const SizedBox(height: 18),
                                const Divider(height: 1),
                                const SizedBox(height: 16),

                                // Options
                                ...opts.asMap().entries.map((e) {
                                  final isSelected =
                                      answers[i] == e.key;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 10),
                                    child: _OptionTile(
                                      label: e.value,
                                      index: e.key,
                                      isSelected: isSelected,
                                      onTap: () {
                                        setState(() =>
                                            answers[i] = e.key);
                                        // Auto-advance if not last
                                        if (i < total - 1) {
                                          Future.delayed(
                                            const Duration(
                                                milliseconds: 380),
                                            () {
                                              if (mounted) {
                                                _pageCtrl.nextPage(
                                                  duration: const Duration(
                                                      milliseconds:
                                                          320),
                                                  curve: Curves
                                                      .easeOutCubic,
                                                );
                                              }
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ── Bottom nav bar ───────────────────────────
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      MediaQuery.of(context).padding.bottom + 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      border: Border(
                        top: BorderSide(
                            color: Colors.white.withOpacity(0.90),
                            width: 1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentBlue.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Prev button
                        if (_currentPage > 0) ...[
                          GestureDetector(
                            onTap: () => _pageCtrl.previousPage(
                              duration:
                                  const Duration(milliseconds: 280),
                              curve: Curves.easeOutCubic,
                            ),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F8FF),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color: AppTheme.accentBlue
                                        .withOpacity(0.22)),
                              ),
                              child: const Center(
                                child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: AppTheme.accentBlue),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        // Next / Submit button
                        Expanded(
                          child: _currentPage < total - 1
                              ? GlowButton(
                                  onPressed: () =>
                                      _pageCtrl.nextPage(
                                    duration: const Duration(
                                        milliseconds: 280),
                                    curve: Curves.easeOutCubic,
                                  ),
                                  accent: AppTheme.accentBlue,
                                  label: 'Next',
                                  icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18),
                                  height: 50,
                                )
                              : GlowButton(
                                  isLoading: isSubmitting,
                                  onPressed: isSubmitting
                                      ? null
                                      : _submitAnswers,
                                  accent: AppTheme.accentTeal,
                                  label: 'Submit Test',
                                  icon: const Icon(Icons.send_rounded,
                                      color: Colors.white, size: 18),
                                  height: 50,
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

  Widget _buildShimmer() => Padding(
        padding: const EdgeInsets.all(16),
        child: _TestShimmer(),
      );
}

// ─── Option tile ─────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  static const _letters = ['A', 'B', 'C', 'D'];

  const _OptionTile({
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letter = index < _letters.length ? _letters[index] : '?';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentBlue.withOpacity(0.08)
              : Colors.white.withOpacity(0.60),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentBlue
                : AppTheme.textPrimary.withOpacity(0.12),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppTheme.accentBlue.withOpacity(0.10),
                      blurRadius: 8)
                ]
              : null,
        ),
        child: Row(
          children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accentBlue
                    : AppTheme.accentBlue.withOpacity(0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: AppTheme.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.accentBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTheme.dmSans(
                  fontSize: 15,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.accentBlue, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Test shimmer ─────────────────────────────────────────────────
class _TestShimmer extends StatefulWidget {
  @override
  State<_TestShimmer> createState() => _TestShimmerState();
}

class _TestShimmerState extends State<_TestShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.25, end: 0.55)
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.72),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.80), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: AppTheme.accentBlue.withOpacity(0.06),
                blurRadius: 20)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Q badge shimmer
            Container(
              width: 140,
              height: 26,
              decoration: BoxDecoration(
                color: AppTheme.accentViolet
                    .withOpacity(_a.value * 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            // Question text shimmer
            Container(
              height: 18,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue
                    .withOpacity(_a.value * 0.40),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 18,
              width: 200,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue
                    .withOpacity(_a.value * 0.30),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            // Option shimmers
            ...List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue
                      .withOpacity(_a.value * (0.15 + i * 0.03)),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}