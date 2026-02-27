// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:file_picker/file_picker.dart'; 
// import 'package:url_launcher/url_launcher.dart'; 
// import 'package:intl/intl.dart';
// import 'dart:io';
// import 'dart:convert';
// import '../../config/app_config.dart';
// import '../../services/api_service.dart';
// import '../../models/classroom_models.dart';
// import '../../theme/app_theme.dart';
// import 'create_test_screen.dart';
// import 'take_test_screen.dart';
// import 'analytics_screen.dart';

// class ClassroomDetailScreen extends StatelessWidget {
//   final Classroom classroom;

//   const ClassroomDetailScreen({Key? key, required this.classroom}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return AppBackground(
//       child: DefaultTabController(
//         length: 3,
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             title: Text(classroom.name),
//             bottom: TabBar(
//               indicatorColor: AppTheme.accentBlue,
//               labelColor: AppTheme.accentBlue,
//               unselectedLabelColor: AppTheme.textMuted,
//               labelStyle: AppTheme.dmSans(fontWeight: FontWeight.w700),
//               tabs: const [
//                 Tab(icon: Icon(Icons.book), text: "Notes"),
//                 Tab(icon: Icon(Icons.assignment), text: "Assignments"),
//                 Tab(icon: Icon(Icons.quiz), text: "Tests"),
//               ],
//             ),
//           ),
//           body: TabBarView(
//             children: [
//               _ResourceTab(classId: classroom.id, isTeacher: classroom.isTeacher, type: 'notes'),
//               _ResourceTab(classId: classroom.id, isTeacher: classroom.isTeacher, type: 'assignments'),
//               _TestsTab(classId: classroom.id, isTeacher: classroom.isTeacher),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ResourceTab extends StatefulWidget {
//   final int classId;
//   final bool isTeacher;
//   final String type; 

//   const _ResourceTab({required this.classId, required this.isTeacher, required this.type});

//   @override
//   State<_ResourceTab> createState() => _ResourceTabState();
// }

// class _ResourceTabState extends State<_ResourceTab> {
//   List<dynamic> items = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchItems();
//   }

//   Future<void> _fetchItems() async {
//     try {
//       final token = await ApiService.getToken();
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/${widget.classId}/${widget.type}'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           items = jsonDecode(response.body);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _pickAndUpload() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom, allowedExtensions: ['pdf'],
//     );

//     if (result != null) {
//       File file = File(result.files.single.path!);
//       final titleController = TextEditingController();
//       DateTime? selectedDateTime;

//       await showDialog(
//         context: context,
//         builder: (ctx) => StatefulBuilder(
//           builder: (context, setStateDialog) {
//             return AlertDialog(
//               backgroundColor: AppTheme.glassFillHi,
//               title: Text("Upload ${widget.type == 'notes' ? 'Note' : 'Assignment'}", style: AppTheme.sora(fontSize: 18)),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   TextField(
//                     controller: titleController,
//                     style: AppTheme.dmSans(),
//                     decoration: const InputDecoration(labelText: "Title"),
//                   ),
//                   if (widget.type == 'assignments') ...[
//                     const SizedBox(height: 16),
//                     ListTile(
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       tileColor: AppTheme.bgWhite.withOpacity(0.5),
//                       title: Text(selectedDateTime == null 
//                         ? "Select Date & Time" 
//                         : DateFormat('MMM dd, yyyy - HH:mm').format(selectedDateTime!),
//                         style: AppTheme.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
//                       ),
//                       trailing: const Icon(Icons.schedule, color: AppTheme.accentBlue),
//                       onTap: () async {
//                         final date = await showDatePicker(
//                           context: context, initialDate: DateTime.now(), 
//                           firstDate: DateTime.now(), lastDate: DateTime(2030)
//                         );
//                         if (date != null) {
//                           final time = await showTimePicker(
//                             context: context, initialTime: TimeOfDay.now()
//                           );
//                           if (time != null) {
//                             setStateDialog(() {
//                               selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
//                             });
//                           }
//                         }
//                       },
//                     )
//                   ]
//                 ],
//               ),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Cancel", style: AppTheme.dmSans(color: AppTheme.textMuted))),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue),
//                   onPressed: () async {
//                     if (titleController.text.isEmpty) return;
//                     if (widget.type == 'assignments' && selectedDateTime == null) return;
                    
//                     Navigator.pop(ctx);
//                     _uploadFile(file, titleController.text, selectedDateTime);
//                   },
//                   child: Text("Upload", style: AppTheme.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
//                 )
//               ],
//             );
//           }
//         ),
//       );
//     }
//   }

//   Future<void> _uploadFile(File file, String title, DateTime? deadline) async {
//     setState(() => isLoading = true);
//     try {
//       await ApiService.uploadClassroomFile(
//         classId: widget.classId, title: title, file: file, type: widget.type, deadline: deadline,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Upload Successful")));
//       _fetchItems(); 
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//       setState(() => isLoading = false);
//     }
//   }

//   Future<void> _studentSubmitAssignment(int assignId) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom, allowedExtensions: ['pdf'],
//     );
//     if (result != null) {
//       File file = File(result.files.single.path!);
//       setState(() => isLoading = true);
//       try {
//         await ApiService.submitAssignment(assignId: assignId, file: file);
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Assignment Submitted Successfully!")));
//         _fetchItems();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
//         setState(() => isLoading = false);
//       }
//     }
//   }

//   Future<void> _downloadFile(String url) async {
//     final uri = Uri.parse('${AppConfig.baseUrl}$url');
//     if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not open file")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: widget.isTeacher
//           ? GlowButton(
//               onPressed: _pickAndUpload,
//               accent: AppTheme.accentBlue,
//               icon: const Icon(Icons.upload_file, color: Colors.white),
//               label: widget.type == 'notes' ? "Upload Note" : "Create Assignment",
//               height: 48,
//             )
//           : null,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : items.isEmpty
//               ? Center(child: Text("No ${widget.type} available yet.", style: AppTheme.dmSans(color: AppTheme.textMuted)))
//               : ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//                   itemCount: items.length,
//                   itemBuilder: (ctx, i) {
//                     final item = items[i];
//                     final isAssignment = widget.type == 'assignments';
                    
//                     DateTime? deadline;
//                     bool isPassed = false;
//                     bool isSubmitted = item['is_submitted'] ?? false;

//                     if (isAssignment && item['deadline'] != null) {
//                       deadline = DateTime.parse(item['deadline']);
//                       isPassed = DateTime.now().isAfter(deadline);
//                     }

//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 16),
//                       child: GlassCard(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.all(12),
//                                   decoration: BoxDecoration(
//                                     color: isAssignment ? AppTheme.accentAmber.withOpacity(0.15) : AppTheme.accentBlue.withOpacity(0.15),
//                                     borderRadius: BorderRadius.circular(12)
//                                   ),
//                                   child: Icon(
//                                     isAssignment ? Icons.assignment : Icons.description, 
//                                     color: isAssignment ? AppTheme.accentAmber : AppTheme.accentBlue
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(item['title'], style: AppTheme.sora(fontSize: 16)),
//                                       if (isAssignment && deadline != null) ...[
//                                         const SizedBox(height: 6),
//                                         Text(
//                                           "Due: ${DateFormat('MMM dd, yyyy - HH:mm').format(deadline.toLocal())}",
//                                           style: AppTheme.dmSans(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                             color: isPassed && !isSubmitted ? AppTheme.accentPink : AppTheme.textSecondary
//                                           )
//                                         )
//                                       ]
//                                     ],
//                                   ),
//                                 ),
//                                 IconButton(
//                                   icon: const Icon(Icons.download_rounded, color: AppTheme.accentBlue),
//                                   onPressed: () => _downloadFile(item['file_url']),
//                                 )
//                               ],
//                             ),
                            
//                             if (isAssignment) ...[
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 12),
//                                 child: Divider(),
//                               ),
//                               if (widget.isTeacher)
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: OutlinedButton.icon(
//                                     onPressed: () {
//                                       Navigator.push(context, AppTheme.slideRoute(
//                                         AnalyticsScreen(contentId: item['id'], title: item['title'], type: 'assignments')
//                                       ));
//                                     },
//                                     icon: const Icon(Icons.analytics, color: AppTheme.accentBlue),
//                                     label: Text("View Submissions", style: AppTheme.dmSans(color: AppTheme.accentBlue, fontWeight: FontWeight.bold)),
//                                     style: OutlinedButton.styleFrom(
//                                       side: BorderSide(color: AppTheme.accentBlue.withOpacity(0.5)),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                       padding: const EdgeInsets.symmetric(vertical: 12)
//                                     ),
//                                   ),
//                                 )
//                               else
//                                 isSubmitted 
//                                   ? const StatusBadge("Turned In", fontSize: 13)
//                                   : isPassed 
//                                       ? const StatusBadge("Missing", fontSize: 13)
//                                       : GlowButton(
//                                           onPressed: () => _studentSubmitAssignment(item['id']),
//                                           accent: AppTheme.accentTeal,
//                                           icon: const Icon(Icons.upload_file, color: Colors.white),
//                                           label: "Upload Submission (PDF)",
//                                           height: 46,
//                                         )
//                             ]
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

// class _TestsTab extends StatefulWidget {
//   final int classId;
//   final bool isTeacher;
//   const _TestsTab({required this.classId, required this.isTeacher});

//   @override
//   State<_TestsTab> createState() => _TestsTabState();
// }

// class _TestsTabState extends State<_TestsTab> {
//   List<dynamic> tests = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTests();
//   }

//   Future<void> _fetchTests() async {
//     try {
//       final token = await ApiService.getToken();
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/${widget.classId}/tests'),
//         headers: {'Authorization': 'Bearer $token'},
//       );
//       if (response.statusCode == 200) {
//         setState(() {
//           tests = jsonDecode(response.body);
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   void _onTestTap(Map test) {
//     if (widget.isTeacher) {
//       Navigator.push(context, AppTheme.slideRoute(
//         AnalyticsScreen(contentId: test['id'], title: test['title'], type: 'tests')
//       ));
//     } else {
//       final startTime = DateTime.parse(test['start_time']);
//       final endTime = DateTime.parse(test['end_time']);
//       final now = DateTime.now();

//       if (now.isBefore(startTime)) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Test hasn't started yet.")));
//       } else if (now.isAfter(endTime)) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Test has ended.")));
//       } else {
//         Navigator.push(context, AppTheme.slideRoute(
//           TakeTestScreen(testId: test['id'], title: test['title'])
//         ));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       floatingActionButton: widget.isTeacher
//           ? GlowButton(
//               onPressed: () async {
//                 final result = await Navigator.push(context, AppTheme.slideRoute(CreateTestScreen(classId: widget.classId)));
//                 if (result == true) _fetchTests();
//               },
//               accent: AppTheme.accentViolet,
//               icon: const Icon(Icons.add, color: Colors.white),
//               label: "Create Test",
//               height: 48,
//             )
//           : null,
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : tests.isEmpty
//               ? Center(child: Text("No tests scheduled", style: AppTheme.dmSans(color: AppTheme.textMuted)))
//               : ListView.builder(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//                   itemCount: tests.length,
//                   itemBuilder: (ctx, i) {
//                     final test = tests[i];
//                     final start = DateTime.parse(test['start_time']);
//                     final end = DateTime.parse(test['end_time']);
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: GlassCard(
//                         onTap: () => _onTestTap(test),
//                         padding: const EdgeInsets.all(16),
//                         child: Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.accentViolet.withOpacity(0.15),
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(Icons.quiz, color: AppTheme.accentViolet),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(test['title'], style: AppTheme.sora(fontSize: 16)),
//                                   const SizedBox(height: 6),
//                                   Text("Starts: ${DateFormat('MMM dd, HH:mm').format(start.toLocal())}", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
//                                   Text("Ends: ${DateFormat('MMM dd, HH:mm').format(end.toLocal())}", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
//                                 ],
//                               ),
//                             ),
//                             const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.bgDeepBlue),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/classroom_models.dart';
import '../../theme/app_theme.dart';
import 'create_test_screen.dart';
import 'take_test_screen.dart';
import 'analytics_screen.dart';

// ─── Helper: wrap date/time pickers with light theme ─────────────
ThemeData _pickerTheme(BuildContext context) {
  return Theme.of(context).copyWith(
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
}

class ClassroomDetailScreen extends StatelessWidget {
  final Classroom classroom;

  const ClassroomDetailScreen({Key? key, required this.classroom})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: NestedScrollView(
            headerSliverBuilder: (ctx, _) => [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18),
                  onPressed: () => Navigator.pop(ctx),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 90, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroom.name,
                          style: AppTheme.sora(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        if (classroom.isTeacher) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.vpn_key_rounded,
                                  size: 13,
                                  color: AppTheme.accentAmber),
                              const SizedBox(width: 5),
                              Text(
                                'Join Code: ${classroom.joinCode}',
                                style: AppTheme.mono(
                                    fontSize: 12,
                                    color: AppTheme.accentAmber,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // ── Pill tab bar ─────────────────────────────────
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.85),
                            width: 1.2),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.accentBlue.withOpacity(0.08),
                              blurRadius: 16)
                        ],
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color:
                                  AppTheme.accentBlue.withOpacity(0.35)),
                        ),
                        labelColor: AppTheme.accentBlue,
                        unselectedLabelColor:
                            AppTheme.textPrimary.withOpacity(0.45),
                        labelStyle: AppTheme.dmSans(
                            fontSize: 12, fontWeight: FontWeight.w700),
                        unselectedLabelStyle:
                            AppTheme.dmSans(fontSize: 12),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(
                            icon:
                                Icon(Icons.description_rounded, size: 15),
                            text: 'Notes',
                            iconMargin: EdgeInsets.only(bottom: 2),
                          ),
                          Tab(
                            icon:
                                Icon(Icons.assignment_rounded, size: 15),
                            text: 'Assignments',
                            iconMargin: EdgeInsets.only(bottom: 2),
                          ),
                          Tab(
                            icon: Icon(Icons.quiz_rounded, size: 15),
                            text: 'Tests',
                            iconMargin: EdgeInsets.only(bottom: 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            body: TabBarView(
              children: [
                _ResourceTab(
                    classId: classroom.id,
                    isTeacher: classroom.isTeacher,
                    type: 'notes'),
                _ResourceTab(
                    classId: classroom.id,
                    isTeacher: classroom.isTeacher,
                    type: 'assignments'),
                _TestsTab(
                    classId: classroom.id,
                    isTeacher: classroom.isTeacher),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Resource Tab ────────────────────────────────────────────────
class _ResourceTab extends StatefulWidget {
  final int classId;
  final bool isTeacher;
  final String type;

  const _ResourceTab({
    required this.classId,
    required this.isTeacher,
    required this.type,
  });

  @override
  State<_ResourceTab> createState() => _ResourceTabState();
}

class _ResourceTabState extends State<_ResourceTab>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> items = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  bool get isAssignment => widget.type == 'assignments';

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/classroom/${widget.classId}/${widget.type}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          items = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || !mounted) return;

    final file = File(result.files.single.path!);
    final titleCtrl = TextEditingController();
    DateTime? selectedDT;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setD) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isAssignment
                          ? AppTheme.accentAmber
                          : AppTheme.accentBlue)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAssignment
                      ? Icons.assignment_rounded
                      : Icons.description_rounded,
                  color: isAssignment
                      ? AppTheme.accentAmber
                      : AppTheme.accentBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isAssignment ? 'New Assignment' : 'Upload Note',
                style: AppTheme.sora(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title field with visible placeholder ──────────
              TextField(
                controller: titleCtrl,
                style: AppTheme.dmSans(
                    fontSize: 15, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: AppTheme.dmSans(
                      fontSize: 14,
                      color: AppTheme.textPrimary.withOpacity(0.55)),
                  hintText: isAssignment
                      ? 'e.g. Chapter 3 Assignment'
                      : 'e.g. Lecture Notes Week 2',
                  hintStyle: AppTheme.dmSans(
                      fontSize: 14,
                      color: AppTheme.textPrimary.withOpacity(0.40)),
                  prefixIcon: Icon(Icons.title_rounded,
                      size: 18,
                      color: AppTheme.textPrimary.withOpacity(0.45)),
                  filled: true,
                  fillColor: const Color(0xFFF5F8FF),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: AppTheme.accentBlue.withOpacity(0.20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppTheme.accentBlue, width: 1.5),
                  ),
                ),
              ),
              if (isAssignment) ...[
                const SizedBox(height: 12),
                // ── Deadline picker ────────────────────────────
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: ctx2,
                        initialDate: DateTime.now()
                            .add(const Duration(days: 7)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                        builder: (c, child) =>
                            Theme(data: _pickerTheme(c), child: child!),
                      );
                      if (date == null || !mounted) return;
                      final time = await showTimePicker(
                        context: ctx2,
                        initialTime: const TimeOfDay(hour: 23, minute: 59),
                        builder: (c, child) =>
                            Theme(data: _pickerTheme(c), child: child!),
                      );
                      if (time == null) return;
                      setD(() {
                        selectedDT = DateTime(date.year, date.month,
                            date.day, time.hour, time.minute);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selectedDT != null
                            ? AppTheme.accentAmber.withOpacity(0.08)
                            : const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedDT != null
                              ? AppTheme.accentAmber.withOpacity(0.40)
                              : AppTheme.accentBlue.withOpacity(0.20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_rounded,
                            size: 18,
                            color: selectedDT != null
                                ? AppTheme.accentAmber
                                : AppTheme.textPrimary.withOpacity(0.45),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedDT == null
                                  ? 'Tap to set deadline'
                                  : DateFormat('MMM dd, yyyy — HH:mm')
                                      .format(selectedDT!),
                              style: AppTheme.dmSans(
                                fontSize: 14,
                                fontWeight: selectedDT != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: selectedDT != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textPrimary
                                        .withOpacity(0.45),
                              ),
                            ),
                          ),
                          if (selectedDT != null)
                            Icon(Icons.check_circle_rounded,
                                size: 16,
                                color: AppTheme.accentAmber),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: AppTheme.dmSans(
                      color: AppTheme.textPrimary.withOpacity(0.55))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAssignment
                    ? AppTheme.accentAmber
                    : AppTheme.accentBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 12),
              ),
              onPressed: () {
                if (titleCtrl.text.trim().isEmpty) return;
                if (isAssignment && selectedDT == null) return;
                Navigator.pop(ctx);
                _uploadFile(file, titleCtrl.text.trim(), selectedDT);
              },
              child: Text('Upload',
                  style: AppTheme.dmSans(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFile(
      File file, String title, DateTime? deadline) async {
    setState(() => isLoading = true);
    try {
      await ApiService.uploadClassroomFile(
        classId: widget.classId,
        title: title,
        file: file,
        type: widget.type,
        deadline: deadline,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Uploaded!')));
      }
      _fetchItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _studentSubmit(int assignId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    final file = File(result.files.single.path!);
    setState(() => isLoading = true);
    try {
      await ApiService.submitAssignment(assignId: assignId, file: file);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submitted successfully!')));
      }
      _fetchItems();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> _download(String url) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open file')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      // ── FAB centred at bottom ──────────────────────────────────
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.isTeacher
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              child: GlowButton(
                onPressed: _pickAndUpload,
                accent: isAssignment
                    ? AppTheme.accentAmber
                    : AppTheme.accentBlue,
                icon: const Icon(Icons.upload_file_rounded,
                    color: Colors.white, size: 18),
                label: isAssignment ? 'Add Assignment' : 'Upload Note',
                height: 52,
              ),
            )
          : null,
      body: isLoading
          ? _buildShimmer()
          : items.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _fetchItems,
                  color: AppTheme.accentBlue,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      DateTime? deadline;
                      bool isPassed = false;
                      final isSubmitted =
                          item['is_submitted'] as bool? ?? false;

                      if (isAssignment && item['deadline'] != null) {
                        deadline = DateTime.parse(item['deadline']);
                        isPassed = DateTime.now().isAfter(deadline);
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ResourceCard(
                          item: item,
                          isAssignment: isAssignment,
                          deadline: deadline,
                          isPassed: isPassed,
                          isSubmitted: isSubmitted,
                          isTeacher: widget.isTeacher,
                          onDownload: () => _download(item['file_url']),
                          onSubmit: () => _studentSubmit(item['id']),
                          onViewAnalytics: () => Navigator.push(
                            ctx,
                            AppTheme.slideRoute(AnalyticsScreen(
                              contentId: item['id'],
                              title: item['title'],
                              type: 'assignments',
                            )),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ShimmerCard(height: isAssignment ? 150 : 90),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: (isAssignment
                        ? AppTheme.accentAmber
                        : AppTheme.accentBlue)
                    .withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(
                    color: (isAssignment
                            ? AppTheme.accentAmber
                            : AppTheme.accentBlue)
                        .withOpacity(0.25)),
              ),
              child: Icon(
                isAssignment
                    ? Icons.assignment_outlined
                    : Icons.description_outlined,
                size: 44,
                color: isAssignment
                    ? AppTheme.accentAmber
                    : AppTheme.accentBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing here yet',
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              widget.isTeacher
                  ? 'Upload the first ${isAssignment ? 'assignment' : 'note'}'
                  : 'Check back later',
              style: AppTheme.dmSans(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
}

// ─── Resource card ────────────────────────────────────────────────
class _ResourceCard extends StatelessWidget {
  final dynamic item;
  final bool isAssignment;
  final DateTime? deadline;
  final bool isPassed;
  final bool isSubmitted;
  final bool isTeacher;
  final VoidCallback onDownload;
  final VoidCallback onSubmit;
  final VoidCallback onViewAnalytics;

  const _ResourceCard({
    required this.item,
    required this.isAssignment,
    required this.deadline,
    required this.isPassed,
    required this.isSubmitted,
    required this.isTeacher,
    required this.onDownload,
    required this.onSubmit,
    required this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    final accent =
        isAssignment ? AppTheme.accentAmber : AppTheme.accentBlue;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isAssignment
                      ? Icons.assignment_rounded
                      : Icons.description_rounded,
                  color: accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: AppTheme.sora(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    if (isAssignment && deadline != null) ...[
                      const SizedBox(height: 6),
                      _DeadlineChip(
                        deadline: deadline!,
                        isPassed: isPassed,
                        isSubmitted: isSubmitted,
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDownload,
                child: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.accentBlue.withOpacity(0.20)),
                  ),
                  child: const Icon(Icons.download_rounded,
                      color: AppTheme.accentBlue, size: 18),
                ),
              ),
            ],
          ),
          if (isAssignment) ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1)),
            if (isTeacher)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onViewAnalytics,
                  icon: const Icon(Icons.bar_chart_rounded,
                      size: 16, color: AppTheme.accentBlue),
                  label: Text('View Submissions',
                      style: AppTheme.dmSans(
                          color: AppTheme.accentBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: AppTheme.accentBlue.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              )
            else if (isSubmitted)
              _StatusRow(
                icon: Icons.check_circle_rounded,
                label: 'Submitted',
                color: AppTheme.statusAccepted,
              )
            else if (isPassed)
              _StatusRow(
                icon: Icons.cancel_rounded,
                label: 'Missing — deadline passed',
                color: AppTheme.statusRejected,
              )
            else
              SizedBox(
                width: double.infinity,
                child: GlowButton(
                  onPressed: onSubmit,
                  accent: AppTheme.accentTeal,
                  icon: const Icon(Icons.upload_file_rounded,
                      color: Colors.white, size: 16),
                  label: 'Submit PDF',
                  height: 46,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _DeadlineChip extends StatelessWidget {
  final DateTime deadline;
  final bool isPassed;
  final bool isSubmitted;

  const _DeadlineChip({
    required this.deadline,
    required this.isPassed,
    required this.isSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = isPassed && !isSubmitted;
    final color =
        isOverdue ? AppTheme.accentPink : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue
                ? Icons.warning_amber_rounded
                : Icons.schedule_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            'Due ${DateFormat('MMM dd, HH:mm').format(deadline.toLocal())}',
            style: AppTheme.dmSans(
                fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusRow(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: AppTheme.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

// ─── Tests Tab ────────────────────────────────────────────────────
class _TestsTab extends StatefulWidget {
  final int classId;
  final bool isTeacher;

  const _TestsTab({required this.classId, required this.isTeacher});

  @override
  State<_TestsTab> createState() => _TestsTabState();
}

class _TestsTabState extends State<_TestsTab>
    with AutomaticKeepAliveClientMixin {
  List<dynamic> tests = [];
  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchTests();
  }

  Future<void> _fetchTests() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse(
            '${AppConfig.baseUrl}/api/classroom/${widget.classId}/tests'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() {
          tests = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _onTestTap(Map test) {
    if (widget.isTeacher) {
      Navigator.push(
        context,
        AppTheme.slideRoute(AnalyticsScreen(
          contentId: test['id'],
          title: test['title'],
          type: 'tests',
        )),
      );
    } else {
      final start = DateTime.parse(test['start_time']);
      final end = DateTime.parse(test['end_time']);
      final now = DateTime.now();

      if (now.isBefore(start)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Test hasn't started yet.")));
      } else if (now.isAfter(end)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test has ended.')));
      } else {
        Navigator.push(
          context,
          AppTheme.slideRoute(
              TakeTestScreen(testId: test['id'], title: test['title'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: widget.isTeacher
          ? SizedBox(
              width: MediaQuery.of(context).size.width - 48,
              child: GlowButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    AppTheme.slideRoute(
                        CreateTestScreen(classId: widget.classId)),
                  );
                  if (result == true) _fetchTests();
                },
                accent: AppTheme.accentViolet,
                icon: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 18),
                label: 'Create Test',
                height: 52,
              ),
            )
          : null,
      body: isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _ShimmerCard(height: 110),
              ),
            )
          : tests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.accentViolet.withOpacity(0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.accentViolet
                                  .withOpacity(0.25)),
                        ),
                        child: Icon(Icons.quiz_outlined,
                            size: 44, color: AppTheme.accentViolet),
                      ),
                      const SizedBox(height: 16),
                      Text('No tests scheduled',
                          style: AppTheme.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(
                        widget.isTeacher
                            ? 'Create your first test'
                            : 'Check back later',
                        style: AppTheme.dmSans(
                            fontSize: 14,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTests,
                  color: AppTheme.accentViolet,
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    physics: const BouncingScrollPhysics(),
                    itemCount: tests.length,
                    itemBuilder: (ctx, i) {
                      final test = tests[i];
                      final start =
                          DateTime.parse(test['start_time']);
                      final end = DateTime.parse(test['end_time']);
                      final now = DateTime.now();

                      String statusLabel;
                      Color statusColor;
                      IconData statusIcon;

                      if (now.isBefore(start)) {
                        statusLabel = 'Upcoming';
                        statusColor = AppTheme.statusPending;
                        statusIcon = Icons.hourglass_top_rounded;
                      } else if (now.isAfter(end)) {
                        statusLabel = 'Ended';
                        statusColor =
                            AppTheme.textPrimary.withOpacity(0.40);
                        statusIcon = Icons.lock_rounded;
                      } else {
                        statusLabel = 'Live Now';
                        statusColor = AppTheme.statusAccepted;
                        statusIcon = Icons.circle;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GlassCard(
                          onTap: () => _onTestTap(test),
                          padding: const EdgeInsets.all(16),
                          glowColor:
                              statusLabel == 'Live Now'
                                  ? AppTheme.statusAccepted
                                  : null,
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentViolet
                                      .withOpacity(0.12),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.quiz_rounded,
                                    color: AppTheme.accentViolet,
                                    size: 22),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(test['title'],
                                        style: AppTheme.sora(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Row(children: [
                                      Icon(
                                          Icons
                                              .play_circle_outline_rounded,
                                          size: 12,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, HH:mm')
                                            .format(start.toLocal()),
                                        style: AppTheme.dmSans(
                                            fontSize: 12,
                                            color: AppTheme
                                                .textSecondary),
                                      ),
                                    ]),
                                    const SizedBox(height: 2),
                                    Row(children: [
                                      Icon(
                                          Icons
                                              .stop_circle_outlined,
                                          size: 12,
                                          color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM dd, HH:mm')
                                            .format(end.toLocal()),
                                        style: AppTheme.dmSans(
                                            fontSize: 12,
                                            color: AppTheme
                                                .textSecondary),
                                      ),
                                    ]),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor
                                          .withOpacity(0.12),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: statusColor
                                              .withOpacity(0.30)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(statusIcon,
                                            size: 8,
                                            color: statusColor),
                                        const SizedBox(width: 4),
                                        Text(statusLabel,
                                            style: AppTheme.dmSans(
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: statusColor)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Icon(
                                      Icons
                                          .arrow_forward_ios_rounded,
                                      size: 14,
                                      color: AppTheme.bgDeepBlue),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Reusable shimmer card ────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  final double height;
  const _ShimmerCard({required this.height});

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
        height: widget.height,
        padding: const EdgeInsets.all(16),
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
            Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(_a.value * 0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue
                            .withOpacity(_a.value * 0.45),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue
                            .withOpacity(_a.value * 0.30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}