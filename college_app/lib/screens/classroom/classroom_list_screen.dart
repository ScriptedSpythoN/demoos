// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../../config/app_config.dart';
// import '../../services/api_service.dart';
// import '../../models/classroom_models.dart';
// import '../../theme/app_theme.dart';
// import 'classroom_detail_screen.dart';

// class ClassroomListScreen extends StatefulWidget {
//   const ClassroomListScreen({super.key});

//   @override
//   State<ClassroomListScreen> createState() => _ClassroomListScreenState();
// }

// class _ClassroomListScreenState extends State<ClassroomListScreen> {
//   List<Classroom> classrooms = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchClassrooms();
//   }

//   Future<void> fetchClassrooms() async {
//     try {
//       final token = await ApiService.getToken();
//       final response = await http.get(
//         Uri.parse('${AppConfig.baseUrl}/api/classroom/my-classes'),
//         headers: {'Authorization': 'Bearer $token'},
//       );

//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         setState(() {
//           classrooms = data.map((e) => Classroom.fromJson(e)).toList();
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//     }
//   }

//   void _showJoinCreateDialog() {
//     final isTeacher = ApiService.userRole == "TEACHER" || ApiService.userRole == "HOD";
//     final controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: AppTheme.glassFillHi,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//         title: Text(
//           isTeacher ? "Create New Class" : "Join a Class",
//           style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700),
//         ),
//         content: TextField(
//           controller: controller,
//           style: AppTheme.dmSans(),
//           decoration: InputDecoration(
//             hintText: isTeacher ? "Enter Class Name" : "Enter 6-digit Code",
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text("Cancel", style: AppTheme.dmSans(color: AppTheme.textMuted)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppTheme.accentBlue,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             ),
//             onPressed: () async {
//               Navigator.pop(ctx);
//               setState(() => isLoading = true);
              
//               final url = isTeacher ? '/create' : '/join';
//               final body = isTeacher
//                   ? jsonEncode({'name': controller.text})
//                   : jsonEncode({'code': controller.text});

//               try {
//                 final token = await ApiService.getToken();
//                 await http.post(
//                   Uri.parse('${AppConfig.baseUrl}/api/classroom$url'),
//                   headers: {
//                     'Content-Type': 'application/json',
//                     'Authorization': 'Bearer $token'
//                   },
//                   body: body,
//                 );
//                 fetchClassrooms();
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Action failed: $e")),
//                 );
//                 setState(() => isLoading = false);
//               }
//             },
//             child: Text("Confirm", style: AppTheme.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isTeacher = ApiService.userRole == "TEACHER" || ApiService.userRole == "HOD";

//     return AppBackground(
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         appBar: AppBar(
//           title: Text("My Classrooms"),
//         ),
//         floatingActionButton: Padding(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           child: GlowButton(
//             label: isTeacher ? "Create Class" : "Join Class",
//             accent: AppTheme.accentBlue,
//             icon: const Icon(Icons.add, color: Colors.white),
//             height: 50,
//             onPressed: _showJoinCreateDialog,
//           ),
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : classrooms.isEmpty 
//                 ? Center(
//                     child: Text(
//                       "No classrooms found.\nJoin or create one!",
//                       textAlign: TextAlign.center,
//                       style: AppTheme.sora(color: AppTheme.textMuted, fontSize: 16),
//                     ),
//                   )
//                 : ListView.builder(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
//                     itemCount: classrooms.length,
//                     itemBuilder: (ctx, i) {
//                       final cls = classrooms[i];
//                       return StaggerEntry(
//                         index: i,
//                         parent: ModalRoute.of(context)!.animation!,
//                         child: Padding(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: GlassCard(
//                             onTap: () {
//                               Navigator.push(context, AppTheme.slideRoute(
//                                 ClassroomDetailScreen(classroom: cls)
//                               ));
//                             },
//                             padding: const EdgeInsets.all(20),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 50,
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     color: AppTheme.accentBlue.withOpacity(0.15),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       cls.name[0].toUpperCase(), 
//                                       style: AppTheme.sora(color: AppTheme.accentBlue, fontSize: 22, fontWeight: FontWeight.w700)
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(cls.name, style: AppTheme.sora(fontSize: 18)),
//                                       const SizedBox(height: 6),
//                                       if (cls.isTeacher)
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                           decoration: BoxDecoration(
//                                             color: AppTheme.accentAmber.withOpacity(0.15),
//                                             borderRadius: BorderRadius.circular(8),
//                                             border: Border.all(color: AppTheme.accentAmber.withOpacity(0.3))
//                                           ),
//                                           child: Text("Code: ${cls.joinCode}", 
//                                             style: AppTheme.mono(color: AppTheme.accentAmber, fontSize: 12)),
//                                         )
//                                       else
//                                         const RoleBadge("STUDENT"),
//                                     ],
//                                   ),
//                                 ),
//                                 const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.bgDeepBlue),
//                               ],
//                             ),
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
import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../models/classroom_models.dart';
import '../../theme/app_theme.dart';
import 'classroom_detail_screen.dart';

class ClassroomListScreen extends StatefulWidget {
  const ClassroomListScreen({super.key});

  @override
  State<ClassroomListScreen> createState() => _ClassroomListScreenState();
}

class _ClassroomListScreenState extends State<ClassroomListScreen>
    with SingleTickerProviderStateMixin {
  List<Classroom> classrooms = [];
  bool isLoading = true;
  late AnimationController _animCtrl;

  bool get _isTeacher =>
      ApiService.userRole == 'TEACHER' || ApiService.userRole == 'HOD';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    fetchClassrooms();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> fetchClassrooms() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/classroom/my-classes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          classrooms = data.map((e) => Classroom.fromJson(e)).toList();
          isLoading = false;
        });
        _animCtrl.forward(from: 0);
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _showJoinCreateDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // ── Pure white dialog so text is always readable ─────────
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isTeacher ? Icons.add_rounded : Icons.login_rounded,
                color: AppTheme.accentBlue,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _isTeacher ? 'Create Class' : 'Join Class',
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isTeacher
                  ? 'Give your class a name that students will recognise.'
                  : 'Ask your teacher for the 6-digit join code.',
              style: AppTheme.dmSans(
                  fontSize: 13,
                  color: AppTheme.textPrimary.withOpacity(0.60),
                  height: 1.5),
            ),
            const SizedBox(height: 16),
            // ── Visible input field ─────────────────────────────
            TextField(
              controller: controller,
              autofocus: true,
              style: AppTheme.dmSans(
                  fontSize: 15, color: AppTheme.textPrimary),
              decoration: InputDecoration(
                labelText:
                    _isTeacher ? 'Class Name' : '6-digit Code',
                labelStyle: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary.withOpacity(0.55)),
                hintText: _isTeacher ? 'e.g. Math – Grade 10' : 'A1B2C3',
                hintStyle: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.textPrimary.withOpacity(0.35)),
                prefixIcon: Icon(
                  _isTeacher ? Icons.class_rounded : Icons.tag_rounded,
                  size: 18,
                  color: AppTheme.accentBlue,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F8FF),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: AppTheme.accentBlue.withOpacity(0.22)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppTheme.accentBlue, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTheme.dmSans(
                    color: AppTheme.textPrimary.withOpacity(0.50))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              setState(() => isLoading = true);

              final url = _isTeacher ? '/create' : '/join';
              final body = _isTeacher
                  ? jsonEncode({'name': controller.text.trim()})
                  : jsonEncode({'code': controller.text.trim()});

              try {
                final token = await ApiService.getToken();
                await http.post(
                  Uri.parse('${AppConfig.baseUrl}/api/classroom$url'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: body,
                );
                fetchClassrooms();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e')));
                }
                setState(() => isLoading = false);
              }
            },
            child: Text(
              _isTeacher ? 'Create' : 'Join',
              style: AppTheme.dmSans(
                  color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'My Classrooms',
            style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              onPressed: fetchClassrooms,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Refresh',
            ),
            const SizedBox(width: 4),
          ],
        ),
        // ── FAB centred, full-width ────────────────────────────────
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          width: MediaQuery.of(context).size.width - 48,
          child: GlowButton(
            label: _isTeacher ? 'Create Class' : 'Join Class',
            accent: AppTheme.accentBlue,
            icon: Icon(
              _isTeacher ? Icons.add_rounded : Icons.login_rounded,
              color: Colors.white,
              size: 18,
            ),
            height: 52,
            onPressed: _showJoinCreateDialog,
          ),
        ),
        body: isLoading
            ? _buildShimmer()
            : classrooms.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: fetchClassrooms,
                    color: AppTheme.accentBlue,
                    child: ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      physics: const BouncingScrollPhysics(),
                      itemCount: classrooms.length,
                      itemBuilder: (ctx, i) {
                        final cls = classrooms[i];
                        const palette = [
                          AppTheme.accentBlue,
                          AppTheme.accentViolet,
                          AppTheme.accentTeal,
                          AppTheme.accentAmber,
                          AppTheme.accentPink,
                        ];
                        final color = palette[i % palette.length];

                        return StaggerEntry(
                          index: i,
                          parent: _animCtrl,
                          interval: 0.09,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ClassroomCard(
                              classroom: cls,
                              accentColor: color,
                              onTap: () => Navigator.push(
                                context,
                                AppTheme.slideRoute(
                                  ClassroomDetailScreen(
                                      classroom: cls),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildShimmer() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ListShimmer(),
        ),
      );

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.accentBlue.withOpacity(0.25),
                    width: 1.5),
              ),
              child: const Icon(Icons.school_outlined,
                  size: 52, color: AppTheme.accentBlue),
            ),
            const SizedBox(height: 20),
            Text('No classrooms yet',
                style: AppTheme.sora(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              _isTeacher
                  ? 'Create your first class to get started'
                  : 'Ask your teacher for a join code',
              textAlign: TextAlign.center,
              style: AppTheme.dmSans(
                  fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 220,
              child: GlowButton(
                label: _isTeacher ? 'Create Class' : 'Join Class',
                accent: AppTheme.accentBlue,
                icon: Icon(
                  _isTeacher ? Icons.add_rounded : Icons.login_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                height: 50,
                onPressed: _showJoinCreateDialog,
              ),
            ),
          ],
        ),
      );
}

// ─── Classroom card ───────────────────────────────────────────────
class _ClassroomCard extends StatelessWidget {
  final Classroom classroom;
  final Color accentColor;
  final VoidCallback onTap;

  const _ClassroomCard({
    required this.classroom,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      glowColor: accentColor,
      child: Row(
        children: [
          // Initial avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.14),
              shape: BoxShape.circle,
              border:
                  Border.all(color: accentColor.withOpacity(0.35), width: 1.5),
            ),
            child: Center(
              child: Text(
                classroom.name[0].toUpperCase(),
                style: AppTheme.sora(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
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
                  classroom.name,
                  style: AppTheme.sora(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                if (classroom.isTeacher)
                  Row(children: [
                    Icon(Icons.vpn_key_rounded,
                        size: 12, color: AppTheme.accentAmber),
                    const SizedBox(width: 4),
                    Text(
                      classroom.joinCode,
                      style: AppTheme.mono(
                          fontSize: 12,
                          color: AppTheme.accentAmber,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    _PillBadge(
                        label: 'Teacher', color: AppTheme.accentAmber),
                  ])
                else
                  _PillBadge(label: 'Student', color: accentColor),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: accentColor),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PillBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: AppTheme.dmSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── List shimmer ─────────────────────────────────────────────────
class _ListShimmer extends StatefulWidget {
  @override
  State<_ListShimmer> createState() => _ListShimmerState();
}

class _ListShimmerState extends State<_ListShimmer>
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
        height: 88,
        padding: const EdgeInsets.all(18),
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
        child: Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(_a.value * 0.40),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 13,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue
                        .withOpacity(_a.value * 0.40),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue
                        .withOpacity(_a.value * 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}