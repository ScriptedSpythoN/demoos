// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import '../../config/app_config.dart';
// import '../../services/api_service.dart';
// import '../../theme/app_theme.dart';

// class CreateTestScreen extends StatefulWidget {
//   final int classId;
//   const CreateTestScreen({Key? key, required this.classId}) : super(key: key);

//   @override
//   State<CreateTestScreen> createState() => _CreateTestScreenState();
// }

// class _CreateTestScreenState extends State<CreateTestScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _titleController = TextEditingController();
//   DateTime _startTime = DateTime.now();
//   DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
//   bool isSubmitting = false;
  
//   List<Map<String, dynamic>> _questions = [
//     {
//       "question_text": "",
//       "options": ["", "", "", ""],
//       "correct_option_index": 0,
//       "controllers": List.generate(4, (_) => TextEditingController())
//     }
//   ];

//   Future<void> _selectDateTime(bool isStart) async {
//     final date = await showDatePicker(
//       context: context, initialDate: isStart ? _startTime : _endTime,
//       firstDate: DateTime.now(), lastDate: DateTime(2030),
//     );
//     if (date == null) return;

//     final time = await showTimePicker(
//       context: context, initialTime: TimeOfDay.fromDateTime(isStart ? _startTime : _endTime),
//     );
//     if (time == null) return;

//     setState(() {
//       final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//       if (isStart) _startTime = dt; else _endTime = dt;
//     });
//   }

//   void _addQuestion() {
//     setState(() {
//       _questions.add({
//         "question_text": "", "options": ["", "", "", ""], "correct_option_index": 0,
//         "controllers": List.generate(4, (_) => TextEditingController())
//       });
//     });
//   }

//   void _removeQuestion(int index) {
//     if (_questions.length > 1) setState(() => _questions.removeAt(index));
//   }

//   Future<void> _submitTest() async {
//     if (!_formKey.currentState!.validate()) return;
//     _formKey.currentState!.save();

//     if (_endTime.isBefore(_startTime) || _endTime.isAtSameMomentAs(_startTime)) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("End time must be after Start time")));
//       return;
//     }

//     setState(() => isSubmitting = true);

//     final testPayload = {
//       "title": _titleController.text,
//       "start_time": _startTime.toUtc().toIso8601String(),
//       "end_time": _endTime.toUtc().toIso8601String(),
//       "questions": _questions.map((q) {
//         List<String> options = (q['controllers'] as List<TextEditingController>).map((c) => c.text).toList();
//         return {
//           "question_text": q['question_text'], "options": options, "correct_option_index": q['correct_option_index']
//         };
//       }).toList()
//     };

//     try {
//       final token = await ApiService.getToken();
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/${widget.classId}/tests'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
//         body: jsonEncode(testPayload),
//       );

//       if (response.statusCode == 200) {
//         Navigator.pop(context, true); 
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: ${response.body}")));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => isSubmitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(title: const Text("Create New Test")),
//         body: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 style: AppTheme.dmSans(),
//                 decoration: const InputDecoration(labelText: "Test Title"),
//                 validator: (v) => v!.isEmpty ? "Required" : null,
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GlassCard(
//                       onTap: () => _selectDateTime(true),
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Starts At", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(DateFormat('MMM dd, HH:mm').format(_startTime), style: AppTheme.dmSans(fontWeight: FontWeight.bold)),
//                               const Icon(Icons.calendar_today, size: 16, color: AppTheme.accentBlue),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: GlassCard(
//                       onTap: () => _selectDateTime(false),
//                       padding: const EdgeInsets.all(12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Ends At", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
//                           const SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(DateFormat('MMM dd, HH:mm').format(_endTime), style: AppTheme.dmSans(fontWeight: FontWeight.bold)),
//                               const Icon(Icons.event, size: 16, color: AppTheme.accentPink),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 24),
//                 child: Divider(),
//               ),
//               Text("Questions", style: AppTheme.sora(fontSize: 20)),
//               const SizedBox(height: 16),
//               ..._questions.asMap().entries.map((entry) {
//                 int idx = entry.key;
//                 Map q = entry.value;
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 20),
//                   child: GlassCard(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextFormField(
//                                 style: AppTheme.dmSans(),
//                                 decoration: InputDecoration(labelText: "Question ${idx + 1}"),
//                                 onSaved: (v) => q['question_text'] = v,
//                                 validator: (v) => v!.isEmpty ? "Required" : null,
//                               ),
//                             ),
//                             if (_questions.length > 1)
//                               IconButton(
//                                 icon: const Icon(Icons.delete, color: AppTheme.accentPink), 
//                                 onPressed: () => _removeQuestion(idx)
//                               )
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         Text("Options (Select correct via Radio):", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textMuted)),
//                         const SizedBox(height: 8),
//                         ...List.generate(4, (optIdx) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: 8.0),
//                             child: Row(
//                               children: [
//                                 Radio<int>(
//                                   value: optIdx,
//                                   groupValue: q['correct_option_index'],
//                                   activeColor: AppTheme.statusAccepted,
//                                   onChanged: (val) => setState(() => q['correct_option_index'] = val),
//                                 ),
//                                 Expanded(
//                                   child: TextFormField(
//                                     controller: q['controllers'][optIdx],
//                                     style: AppTheme.dmSans(fontSize: 14),
//                                     decoration: InputDecoration(
//                                       hintText: "Option ${optIdx + 1}",
//                                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
//                                     ),
//                                     validator: (v) => v!.isEmpty ? "Required" : null,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         })
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//               OutlinedButton.icon(
//                 onPressed: _addQuestion,
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.all(16),
//                   side: BorderSide(color: AppTheme.accentViolet.withOpacity(0.5)),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
//                 ),
//                 icon: const Icon(Icons.add, color: AppTheme.accentViolet),
//                 label: Text("Add Another Question", style: AppTheme.dmSans(color: AppTheme.accentViolet, fontWeight: FontWeight.bold)),
//               ),
//               const SizedBox(height: 32),
//               GlowButton(
//                 isLoading: isSubmitting,
//                 onPressed: _submitTest,
//                 accent: AppTheme.accentBlue,
//                 label: "PUBLISH TEST",
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

// ─── Light-theme wrapper for date/time pickers ───────────────────
ThemeData _pickerTheme(BuildContext context) => Theme.of(context).copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppTheme.accentBlue,
        onPrimary: Colors.white,
        surface: Colors.white,
        onSurface: AppTheme.textPrimary,
        background: Colors.white,
        onBackground: AppTheme.textPrimary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppTheme.accentBlue),
      ),
      dialogBackgroundColor: Colors.white,
    );

// ─── Reusable visible InputDecoration ─────────────────────────────
InputDecoration _inputDeco({
  required String label,
  String? hint,
  Widget? prefix,
}) =>
    InputDecoration(
      labelText: label,
      labelStyle: AppTheme.dmSans(
          fontSize: 14,
          color: AppTheme.textPrimary.withOpacity(0.60)),
      hintText: hint,
      hintStyle: AppTheme.dmSans(
          fontSize: 14,
          color: AppTheme.textPrimary.withOpacity(0.35)),
      prefixIcon: prefix,
      filled: true,
      fillColor: const Color(0xFFF5F8FF),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppTheme.accentBlue.withOpacity(0.22)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.accentBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.accentPink, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: AppTheme.accentPink, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );

class CreateTestScreen extends StatefulWidget {
  final int classId;
  const CreateTestScreen({Key? key, required this.classId})
      : super(key: key);

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  DateTime _startTime =
      DateTime.now().add(const Duration(minutes: 10));
  DateTime _endTime =
      DateTime.now().add(const Duration(hours: 1, minutes: 10));
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _questions = [_emptyQ()];

  static Map<String, dynamic> _emptyQ() => {
        'question_text': '',
        'correct_option_index': 0,
        'questionCtrl': TextEditingController(),
        'optionCtrls':
            List.generate(4, (_) => TextEditingController()),
      };

  @override
  void dispose() {
    _titleCtrl.dispose();
    _scrollCtrl.dispose();
    for (final q in _questions) {
      (q['questionCtrl'] as TextEditingController).dispose();
      for (final c
          in (q['optionCtrls'] as List<TextEditingController>)) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _pickDateTime(bool isStart) async {
    final init = isStart ? _startTime : _endTime;
    final date = await showDatePicker(
      context: context,
      initialDate: init,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (c, child) =>
          Theme(data: _pickerTheme(c), child: child!),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(init),
      builder: (c, child) =>
          Theme(data: _pickerTheme(c), child: child!),
    );
    if (time == null) return;

    final dt = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? _startTime = dt : _endTime = dt);
  }

  void _addQuestion() {
    setState(() => _questions.add(_emptyQ()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _removeQuestion(int idx) {
    if (_questions.length <= 1) return;
    setState(() {
      final q = _questions.removeAt(idx);
      (q['questionCtrl'] as TextEditingController).dispose();
      for (final c
          in (q['optionCtrls'] as List<TextEditingController>)) {
        c.dispose();
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_endTime.isAfter(_startTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = {
      'title': _titleCtrl.text.trim(),
      'start_time': _startTime.toUtc().toIso8601String(),
      'end_time': _endTime.toUtc().toIso8601String(),
      'questions': _questions
          .map((q) => {
                'question_text':
                    (q['questionCtrl'] as TextEditingController)
                        .text
                        .trim(),
                'options':
                    (q['optionCtrls'] as List<TextEditingController>)
                        .map((c) => c.text.trim())
                        .toList(),
                'correct_option_index': q['correct_option_index'],
              })
          .toList(),
    };

    try {
      final token = await ApiService.getToken();
      final response = await http.post(
        Uri.parse(
            '${AppConfig.baseUrl}/api/classroom/${widget.classId}/tests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: ${response.body}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String get _durationLabel {
    final diff = _endTime.difference(_startTime);
    if (diff.isNegative || diff.inMinutes == 0) return 'Invalid range';
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  bool get _validRange => _endTime.isAfter(_startTime);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Create Test',
              style: AppTheme.sora(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── Test title ─────────────────────────────────────
              TextFormField(
                controller: _titleCtrl,
                style: AppTheme.dmSans(
                    fontSize: 15, color: AppTheme.textPrimary),
                decoration: _inputDeco(
                  label: 'Test Title',
                  hint: 'e.g. Mid-Term Chemistry Test',
                  prefix: Icon(Icons.title_rounded,
                      size: 18,
                      color: AppTheme.textPrimary.withOpacity(0.45)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              // ── Schedule section ───────────────────────────────
              _SectionHeader(
                  icon: Icons.schedule_rounded, label: 'Schedule'),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DateTimeCard(
                      label: 'Starts',
                      dateTime: _startTime,
                      accent: AppTheme.accentBlue,
                      icon: Icons.play_circle_rounded,
                      onTap: () => _pickDateTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateTimeCard(
                      label: 'Ends',
                      dateTime: _endTime,
                      accent: AppTheme.accentPink,
                      icon: Icons.stop_circle_rounded,
                      onTap: () => _pickDateTime(false),
                    ),
                  ),
                ],
              ),

              // Duration pill
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: (_validRange
                            ? AppTheme.accentTeal
                            : AppTheme.accentPink)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: (_validRange
                                ? AppTheme.accentTeal
                                : AppTheme.accentPink)
                            .withOpacity(0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _validRange
                            ? Icons.timer_rounded
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: _validRange
                            ? AppTheme.accentTeal
                            : AppTheme.accentPink,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Duration: $_durationLabel',
                        style: AppTheme.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _validRange
                              ? AppTheme.accentTeal
                              : AppTheme.accentPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Questions section ──────────────────────────────
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  _SectionHeader(
                      icon: Icons.quiz_rounded,
                      label: 'Questions'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              AppTheme.accentViolet.withOpacity(0.25)),
                    ),
                    child: Text(
                      '${_questions.length} Q',
                      style: AppTheme.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentViolet),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ..._questions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _QuestionCard(
                    index: entry.key,
                    data: entry.value,
                    canDelete: _questions.length > 1,
                    onDelete: () => _removeQuestion(entry.key),
                    onCorrectChanged: (val) => setState(
                        () => entry.value['correct_option_index'] = val),
                  ),
                );
              }),

              // ── Add question button ────────────────────────────
              GlassCard(
                onTap: _addQuestion,
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentViolet.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: AppTheme.accentViolet, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Add Question',
                      style: AppTheme.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentViolet),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Publish button — full width ─────────────────────
              GlowButton(
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
                accent: AppTheme.accentBlue,
                label: 'Publish Test',
                icon: const Icon(Icons.rocket_launch_rounded,
                    color: Colors.white, size: 18),
                height: 56,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentBlue),
        const SizedBox(width: 7),
        Text(label,
            style: AppTheme.sora(
                fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ─── Date-time card ───────────────────────────────────────────────
class _DateTimeCard extends StatelessWidget {
  final String label;
  final DateTime dateTime;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _DateTimeCard({
    required this.label,
    required this.dateTime,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: accent),
              const SizedBox(width: 5),
              Text(label,
                  style: AppTheme.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('MMM dd').format(dateTime),
            style: AppTheme.sora(
                fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            DateFormat('HH:mm').format(dateTime),
            style: AppTheme.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.edit_rounded, size: 11, color: accent.withOpacity(0.6)),
            const SizedBox(width: 3),
            Text('Tap to change',
                style: AppTheme.dmSans(
                    fontSize: 10,
                    color: accent.withOpacity(0.6))),
          ]),
        ],
      ),
    );
  }
}

// ─── Question card ────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final int index;
  final Map<String, dynamic> data;
  final bool canDelete;
  final VoidCallback onDelete;
  final ValueChanged<int?> onCorrectChanged;

  const _QuestionCard({
    required this.index,
    required this.data,
    required this.canDelete,
    required this.onDelete,
    required this.onCorrectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final questionCtrl = data['questionCtrl'] as TextEditingController;
    final optionCtrls =
        data['optionCtrls'] as List<TextEditingController>;
    final correctIdx = data['correct_option_index'] as int;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppTheme.accentViolet.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    'Q${index + 1}',
                    style: AppTheme.sora(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentViolet,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Question ${index + 1}',
                  style: AppTheme.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary),
                ),
              ),
              if (canDelete)
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.accentPink, size: 16),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Question text ──────────────────────────────────────
          TextFormField(
            controller: questionCtrl,
            style: AppTheme.dmSans(
                fontSize: 14, color: AppTheme.textPrimary),
            maxLines: 2,
            decoration: _inputDeco(
              label: 'Question text',
              hint: 'Type your question here…',
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),

          const SizedBox(height: 14),

          Row(children: [
            Icon(Icons.radio_button_checked_rounded,
                size: 13, color: AppTheme.statusAccepted),
            const SizedBox(width: 5),
            Text(
              'Tap the circle to mark the correct answer',
              style: AppTheme.dmSans(
                  fontSize: 11,
                  color: AppTheme.textPrimary.withOpacity(0.50)),
            ),
          ]),

          const SizedBox(height: 8),

          // ── Options ────────────────────────────────────────────
          ...List.generate(4, (optIdx) {
            final isCorrect = optIdx == correctIdx;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => onCorrectChanged(optIdx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect
                            ? AppTheme.statusAccepted
                                .withOpacity(0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: isCorrect
                              ? AppTheme.statusAccepted
                              : AppTheme.textPrimary
                                  .withOpacity(0.30),
                          width: isCorrect ? 2 : 1.5,
                        ),
                      ),
                      child: isCorrect
                          ? Center(
                              child: Icon(Icons.check_rounded,
                                  size: 14,
                                  color: AppTheme.statusAccepted),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: optionCtrls[optIdx],
                      style: AppTheme.dmSans(
                          fontSize: 14,
                          color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Option ${optIdx + 1}',
                        hintStyle: AppTheme.dmSans(
                            fontSize: 14,
                            color: AppTheme.textPrimary
                                .withOpacity(0.35)),
                        filled: true,
                        fillColor: isCorrect
                            ? AppTheme.statusAccepted.withOpacity(0.06)
                            : const Color(0xFFF5F8FF),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 11),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isCorrect
                                ? AppTheme.statusAccepted
                                    .withOpacity(0.45)
                                : AppTheme.accentBlue.withOpacity(0.20),
                            width: isCorrect ? 1.5 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppTheme.accentBlue, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppTheme.accentPink),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppTheme.accentPink, width: 1.5),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? 'Required'
                              : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}