// // lib/screens/student_dashboard_screen.dart
// import 'dart:math' as math;
// import 'dart:ui';
// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import '../theme/app_theme.dart';
// import '../widgets/app_drawer.dart';
// import '../widgets/dashboard_top_bar.dart';
// import 'login_screen.dart';
// import 'medical_screen.dart';
// import 'student_medical_history_screen.dart';
// // Announcement Integration
// import 'announcements/announcement_list_screen.dart';

// // ─────────────────────────────────────────────────────────────────
// //  StudentDashboardScreen — Shell with Bottom Navigation
// // ─────────────────────────────────────────────────────────────────
// class StudentDashboardScreen extends StatefulWidget {
//   const StudentDashboardScreen({super.key});

//   @override
//   State<StudentDashboardScreen> createState() =>
//       _StudentDashboardScreenState();
// }

// class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
//   int _currentTab = 0;

//   static const _navItems = [
//     GlassNavItem(
//         icon: Icons.home_outlined,
//         activeIcon: Icons.home_rounded,
//         label: 'Home'),
//     GlassNavItem(
//         icon: Icons.menu_book_outlined,
//         activeIcon: Icons.menu_book_rounded,
//         label: 'Classroom'),
//     GlassNavItem(
//         icon: Icons.campaign_outlined,
//         activeIcon: Icons.campaign_rounded,
//         label: 'Notices'),
//     GlassNavItem(
//         icon: Icons.person_outline_rounded,
//         activeIcon: Icons.person_rounded,
//         label: 'Profile'),
//   ];

//   void _logout() {
//     ApiService.logout();
//     Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false);
//   }

//   void _switchTab(int index) {
//     setState(() => _currentTab = index);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final name = ApiService.currentUserName ?? 'Student';
//     final userId = ApiService.currentUserId ?? '';

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       extendBody: true,
//       // ── Drawer ───────────────────────────────────────────────
//       drawer: AppDrawer(
//         userName: name,
//         userId: userId,
//         role: 'STUDENT',
//         accentColor: AppTheme.accentBlue,
//         onLogout: _logout,
//       ),
//       body: AppBackground(
//         child: SafeArea(
//           bottom: false,
//           child: Stack(
//             children: [
//               IndexedStack(
//                 index: _currentTab,
//                 children: [
//                   _StudentHomeTab(onSwitchTab: _switchTab),
//                   const _StudentClassroomTab(),
//                   const AnnouncementListScreen(), // Integrated Announcement Feature
//                   const _StudentProfileTab(),
//                 ],
//               ),
//               // ── New three-point top bar ─────────────────────
//               DashboardTopBar(
//                 accentColor: AppTheme.accentBlue,
//                 notificationCount: 3,
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: GlassNavBar(
//         currentIndex: _currentTab,
//         items: _navItems,
//         accentColor: AppTheme.accentBlue,
//         onTap: (i) => setState(() => _currentTab = i),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  TAB 0 — Home
// // ─────────────────────────────────────────────────────────────────
// class _StudentHomeTab extends StatefulWidget {
//   final void Function(int) onSwitchTab;
//   const _StudentHomeTab({required this.onSwitchTab});

//   @override
//   State<_StudentHomeTab> createState() => _StudentHomeTabState();
// }

// class _StudentHomeTabState extends State<_StudentHomeTab>
//     with TickerProviderStateMixin {
//   late AnimationController _staggerCtrl;
//   late AnimationController _numberCtrl;

//   bool _isLoading = true;
//   double _overallPct = 0.0;
//   List<Map<String, dynamic>> _subjects = [];

//   final List<Map<String, dynamic>> _schedule = [
//     { 'subject': 'Computer Networks', 'code': 'CN', 'time': '09:00', 'room': 'N-206', 'faculty': 'Dr. Niroj Pani' },
//     { 'subject': 'Machine Learning', 'code': 'ML', 'time': '11:00', 'room': 'N-205', 'faculty': 'Prof. M. Srinivas' },
//     { 'subject': 'Operating System', 'code': 'OS', 'time': '14:00', 'room': 'N-206', 'faculty': 'Dr. Dillip Sahoo' },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _staggerCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 900));
//     _numberCtrl = AnimationController(
//         vsync: this, duration: const Duration(milliseconds: 1200));
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     final studentId = ApiService.currentUserId ?? '2301105277';
//     final data = await ApiService.fetchStudentDashboard(studentId);

//     if (!mounted) return;

//     setState(() {
//       final List subjectsData = data['subjects'] ?? [];

//       if (subjectsData.isEmpty) {
//         // BEAUTIFUL FALLBACK: Keeps the UI looking great during demos if the DB is empty
//         _overallPct = 66.7;
//         _subjects = [
//           {'code': 'CN', 'name': 'Computer Networks', 'percentage': 84.5, 'color': AppTheme.accentBlue, 'attended': 33, 'total': 40},
//           {'code': 'CD', 'name': 'Compiler Design', 'percentage': 75.5, 'color': AppTheme.accentViolet, 'attended': 31, 'total': 40},
//           {'code': 'OS', 'name': 'Operating System', 'percentage': 50.0, 'color': const Color.fromARGB(255, 231, 147, 2), 'attended': 20, 'total': 40},
//           {'code': 'ML', 'name': 'Machine Learning', 'percentage': 75.0, 'color': const Color.fromARGB(255, 120, 28, 186), 'attended': 30, 'total': 40},
//           {'code': 'CC', 'name': 'Cloud Computing', 'percentage': 25.0, 'color': const Color.fromARGB(255, 195, 11, 11), 'attended': 10, 'total': 40},
//           {'code': 'ESSP', 'name': 'Enhancing Soft Skills', 'percentage': 90.0, 'color': AppTheme.accentTeal, 'attended': 36, 'total': 40},
//         ];
//       } else {
//         _overallPct = (data['percentage'] ?? 0.0).toDouble();
//         final colors = [AppTheme.accentBlue, AppTheme.accentViolet, const Color(0xFF3B82F6), AppTheme.accentTeal, AppTheme.accentPink, AppTheme.accentAmber];

//         _subjects = subjectsData.asMap().entries.map((e) {
//           final i = e.key;
//           final subj = e.value;
//           return {
//             'code': subj['code'],
//             'name': subj['name'],
//             'percentage': (subj['percentage'] ?? 0).toDouble(),
//             'color': colors[i % colors.length], // Dynamic role-compliant colors
//             'attended': subj['attended'] ?? 0,
//             'total': subj['total'] ?? 0,
//           };
//         }).toList();
//       }
//       _isLoading = false;
//     });

//     _staggerCtrl.reset();
//     _numberCtrl.reset();
//     _staggerCtrl.forward();
//     _numberCtrl.forward();
//   }

//   @override
//   void dispose() {
//     _staggerCtrl.dispose();
//     _numberCtrl.dispose();
//     super.dispose();
//   }

//   Color _colorForPct(double p) {
//     if (p >= 75) return AppTheme.accentTeal;
//     if (p >= 60) return AppTheme.accentAmber;
//     return AppTheme.accentPink;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       color: AppTheme.accentBlue,
//       backgroundColor: Colors.white,
//       onRefresh: _loadData, // Real API Pull-to-Refresh action wired!
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(
//             parent: BouncingScrollPhysics()),
//         // ⬆ increased top padding from 80 → 68 to account for the new top bar height
//         padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             StaggerEntry(
//                 parent: _staggerCtrl,
//                 index: 0,
//                 child: _buildWelcomeCard()),
//             const SizedBox(height: 12),
//             StaggerEntry(
//                 parent: _staggerCtrl,
//                 index: 1,
//                 child: _buildScheduleCard()),
//             const SizedBox(height: 12),
//             StaggerEntry(
//                 parent: _staggerCtrl,
//                 index: 2,
//                 child: _buildAttendanceCard()),
//             const SizedBox(height: 12),
//             StaggerEntry(
//                 parent: _staggerCtrl,
//                 index: 3,
//                 child: _buildMedicalCard()),
//           ],
//         ),
//       ),
//     );
//   }

//   // ── Welcome card ──────────────────────────────────────────────
//   Widget _buildWelcomeCard() {
//     return GlassCard(
//       padding: const EdgeInsets.all(20),
//       glowColor: AppTheme.accentBlue,
//       borderColor: AppTheme.accentBlue.withOpacity(0.25),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('Hello,',
//                     style: AppTheme.dmSans(
//                         fontSize: 13, color: AppTheme.textSecondary)),
//                 const SizedBox(height: 2),
//                 Text(ApiService.currentUserName ?? 'Student',
//                     style: AppTheme.sora(
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                         color: AppTheme.textPrimary)),
//                 const SizedBox(height: 8),
//                 GlassCard(
//                   radius: 20,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                   color: AppTheme.accentBlue.withOpacity(0.10),
//                   borderColor: AppTheme.accentBlue.withOpacity(0.20),
//                   child: Text('Dept. of Computer Science',
//                       style: AppTheme.dmSans(
//                           fontSize: 11,
//                           color: AppTheme.accentBlue,
//                           fontWeight: FontWeight.w600)),
//                 ),
//               ],
//             ),
//           ),
//           AnimatedBuilder(
//             animation: _numberCtrl,
//             builder: (_, __) =>
//                 _buildRing(_overallPct * _numberCtrl.value, 60),
//           ),
//         ],
//       ),
//     );
//   }

//   // ── Schedule card ─────────────────────────────────────────────
//   Widget _buildScheduleCard() {
//     return GlassCard(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionHeader(Icons.calendar_today_rounded, "Today's Schedule",
//               AppTheme.accentBlue),
//           const SizedBox(height: 12),
//           ..._schedule.map((cls) => _buildScheduleItem(cls)).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildScheduleItem(Map<String, dynamic> cls) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppTheme.accentBlue.withOpacity(0.06),
//               borderRadius: BorderRadius.circular(14),
//               border:
//                   Border.all(color: AppTheme.accentBlue.withOpacity(0.15)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 10, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: AppTheme.accentBlue.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(cls['time'],
//                       style: AppTheme.mono(
//                           fontSize: 12,
//                           color: AppTheme.accentBlue,
//                           fontWeight: FontWeight.w800)),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(cls['subject'],
//                           style: AppTheme.dmSans(
//                               fontSize: 13,
//                               fontWeight: FontWeight.w700,
//                               color: AppTheme.textPrimary),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis),
//                       Text('${cls['room']} • ${cls['faculty']}',
//                           style: AppTheme.dmSans(
//                               fontSize: 11, color: AppTheme.textMuted)),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 8, vertical: 3),
//                   decoration: BoxDecoration(
//                     color: AppTheme.accentTeal.withOpacity(0.10),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(cls['code'],
//                       style: AppTheme.dmSans(
//                           fontSize: 10,
//                           color: AppTheme.accentTeal,
//                           fontWeight: FontWeight.w700)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Attendance card ───────────────────────────────────────────
//   Widget _buildAttendanceCard() {
//     return GlassCard(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               _sectionHeader(
//                   Icons.bar_chart_rounded, 'Attendance', AppTheme.accentViolet),
//               const Spacer(),
//               AnimatedBuilder(
//                 animation: _numberCtrl,
//                 builder: (_, __) {
//                   final val = _overallPct * _numberCtrl.value;
//                   return GlassCard(
//                     radius: 20,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 10, vertical: 4),
//                     color: _colorForPct(_overallPct).withOpacity(0.10),
//                     borderColor: _colorForPct(_overallPct).withOpacity(0.20),
//                     child: Text('${val.toStringAsFixed(1)}%',
//                         style: AppTheme.mono(
//                             fontSize: 12,
//                             color: _colorForPct(_overallPct),
//                             fontWeight: FontWeight.w700)),
//                   );
//                 },
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               childAspectRatio: 0.92,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemCount: _subjects.length,
//             itemBuilder: (_, i) => _buildSubjectCell(_subjects[i]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectCell(Map<String, dynamic> sub) {
//     final pct = sub['percentage'] as double;
//     final color = _colorForPct(pct);
//     final accent = sub['color'] as Color;

//     return GestureDetector(
//       onTap: () => _showSubjectSheet(sub),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//           child: Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFFFFF).withOpacity(0.55),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: accent.withOpacity(0.20)),
//               boxShadow: [
//                 BoxShadow(color: accent.withOpacity(0.06), blurRadius: 12)
//               ],
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 AnimatedBuilder(
//                   animation: _numberCtrl,
//                   builder: (_, __) => SizedBox(
//                     width: 50,
//                     height: 50,
//                     child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         CustomPaint(
//                             size: const Size(50, 50),
//                             painter: _RingPainter(
//                                 percentage:
//                                     (pct * _numberCtrl.value) / 100,
//                                 color: color,
//                                 trackColor: color.withOpacity(0.12),
//                                 strokeWidth: 4.5)),
//                         Text(
//                             '${(pct * _numberCtrl.value).toInt()}',
//                             style: AppTheme.mono(
//                                 fontSize: 11,
//                                 color: AppTheme.textPrimary,
//                                 fontWeight: FontWeight.w800)),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(sub['code'],
//                     style: AppTheme.dmSans(
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                         color: AppTheme.textSecondary)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ── Medical card ──────────────────────────────────────────────
//   Widget _buildMedicalCard() {
//     return GlassCard(
//       padding: const EdgeInsets.all(16),
//       glowColor: AppTheme.accentPink,
//       borderColor: AppTheme.accentPink.withOpacity(0.15),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionHeader(Icons.medical_services_rounded, 'Medical',
//               AppTheme.accentPink),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                   child: _buildMedBtn(
//                       'Apply Leave',
//                       Icons.add_circle_outline_rounded,
//                       AppTheme.accentPink,
//                       () => Navigator.push(context,
//                           AppTheme.slideRoute(const MedicalScreen())))),
//               const SizedBox(width: 10),
//               Expanded(
//                   child: _buildMedBtn(
//                       'View History',
//                       Icons.history_rounded,
//                       AppTheme.accentAmber,
//                       () => Navigator.push(
//                           context,
//                           AppTheme.slideRoute(StudentMedicalHistoryScreen(
//                               studentRollNo:
//                                   ApiService.currentUserId ??
//                                       '2301105277'))))),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMedBtn(
//       String label, IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: color.withOpacity(0.20)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(icon, color: color, size: 16),
//                 const SizedBox(width: 6),
//                 Text(label,
//                     style: AppTheme.dmSans(
//                         fontSize: 12,
//                         color: color,
//                         fontWeight: FontWeight.w600)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(IconData icon, String title, Color color) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(7),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.12),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: color, size: 16),
//         ),
//         const SizedBox(width: 10),
//         Text(title,
//             style: AppTheme.sora(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w700,
//                 color: AppTheme.textPrimary)),
//       ],
//     );
//   }

//   Widget _buildRing(double pct, double size) {
//     final color = _colorForPct(pct);
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CustomPaint(
//               size: Size(size, size),
//               painter: _RingPainter(
//                   percentage: pct / 100,
//                   color: color,
//                   trackColor: color.withOpacity(0.12),
//                   strokeWidth: 5)),
//           Text('${pct.toInt()}%',
//               style: AppTheme.mono(
//                   fontSize: 13,
//                   color: AppTheme.textPrimary,
//                   fontWeight: FontWeight.w800)),
//         ],
//       ),
//     );
//   }

//   void _showSubjectSheet(Map<String, dynamic> sub) {
//     final pct = sub['percentage'] as double;
//     final color = _colorForPct(pct);
//     final accent = sub['color'] as Color;
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (_) => ClipRRect(
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.88),
//               borderRadius:
//                   const BorderRadius.vertical(top: Radius.circular(28)),
//               border: Border.all(color: accent.withOpacity(0.20)),
//             ),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Container(
//                   width: 36,
//                   height: 4,
//                   decoration: BoxDecoration(
//                       color: AppTheme.textMuted,
//                       borderRadius: BorderRadius.circular(2))),
//               const SizedBox(height: 20),
//               SizedBox(
//                   width: 100,
//                   height: 100,
//                   child: Stack(alignment: Alignment.center, children: [
//                     CustomPaint(
//                         size: const Size(100, 100),
//                         painter: _RingPainter(
//                             percentage: pct / 100,
//                             color: color,
//                             trackColor: color.withOpacity(0.12),
//                             strokeWidth: 8)),
//                     Text('${pct.toStringAsFixed(1)}%',
//                         style: AppTheme.mono(
//                             fontSize: 20,
//                             color: AppTheme.textPrimary,
//                             fontWeight: FontWeight.w800)),
//                   ])),
//               const SizedBox(height: 16),
//               Text(sub['name'],
//                   textAlign: TextAlign.center,
//                   style: AppTheme.sora(
//                       fontSize: 18, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 8),
//               StatusBadge(pct >= 75
//                   ? 'ACCEPTED'
//                   : pct >= 60
//                       ? 'PENDING'
//                       : 'REJECTED'),
//               const SizedBox(height: 24),
//               Row(children: [
//                 _sheetStat('Attended', '${sub['attended'] ?? '--'}', accent),
//                 _sheetStat('Total', '${sub['total'] ?? '--'}', accent),
//                 _sheetStat('Minimum', '75%', accent),
//               ]),
//               const SizedBox(height: 24),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _sheetStat(String label, String val, Color accent) {
//     return Expanded(
//         child: Column(children: [
//       Text(val,
//           style: AppTheme.mono(
//               fontSize: 22, color: accent, fontWeight: FontWeight.w800)),
//       const SizedBox(height: 4),
//       Text(label,
//           textAlign: TextAlign.center,
//           style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
//     ]));
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  TAB 1 — Classroom  (unchanged)
// // ─────────────────────────────────────────────────────────────────
// class _StudentClassroomTab extends StatelessWidget {
//   const _StudentClassroomTab();

//   @override
//   Widget build(BuildContext context) {
//     final subjects = [
//       {
//         'code': 'CN',
//         'name': 'Computer Networks',
//         'color': AppTheme.accentBlue,
//         'materials': 12,
//         'assignments': 2
//       },
//       {
//         'code': 'CD',
//         'name': 'Compiler Design',
//         'color': AppTheme.accentViolet,
//         'materials': 8,
//         'assignments': 1
//       },
//       {
//         'code': 'OS',
//         'name': 'Operating System',
//         'color': const Color(0xFF3B82F6),
//         'materials': 15,
//         'assignments': 3
//       },
//       {
//         'code': 'ML',
//         'name': 'Machine Learning',
//         'color': AppTheme.accentPink,
//         'materials': 10,
//         'assignments': 1
//       },
//     ];

//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Classroom',
//               style:
//                   AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
//           const SizedBox(height: 4),
//           Text('Access your course materials',
//               style: AppTheme.dmSans(
//                   fontSize: 13, color: AppTheme.textSecondary)),
//           const SizedBox(height: 16),
//           ...subjects
//               .map((s) => Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: _buildSubjectCard(s),
//                   ))
//               .toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubjectCard(Map<String, dynamic> s) {
//     final color = s['color'] as Color;
//     return GlassCard(
//       padding: const EdgeInsets.all(16),
//       borderColor: color.withOpacity(0.20),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               gradient:
//                   LinearGradient(colors: [color, color.withOpacity(0.6)]),
//               borderRadius: BorderRadius.circular(14),
//               boxShadow: [
//                 BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)
//               ],
//             ),
//             child: Center(
//                 child: Text(s['code'],
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w800))),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Text(s['name'],
//                   style: AppTheme.dmSans(
//                       fontSize: 14, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 4),
//               Row(children: [
//                 _chip('${s['materials']} Materials', color),
//                 const SizedBox(width: 6),
//                 _chip('${s['assignments']} Tasks', AppTheme.accentAmber),
//               ]),
//             ]),
//           ),
//           Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
//         ],
//       ),
//     );
//   }

//   Widget _chip(String label, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//           color: color.withOpacity(0.10),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: color.withOpacity(0.20))),
//       child: Text(label,
//           style: TextStyle(
//               color: color, fontSize: 10, fontWeight: FontWeight.w600)),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────
// //  TAB 3 — Profile  (unchanged)
// // ─────────────────────────────────────────────────────────────────
// class _StudentProfileTab extends StatelessWidget {
//   const _StudentProfileTab();

//   @override
//   Widget build(BuildContext context) {
//     final name = ApiService.currentUserName ?? 'Student';
//     final initials = name.length >= 2
//         ? name.substring(0, 2).toUpperCase()
//         : name.toUpperCase();
//     return SingleChildScrollView(
//       padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
//       physics: const BouncingScrollPhysics(),
//       child: Column(
//         children: [
//           GlassCard(
//             padding: const EdgeInsets.all(24),
//             child: Column(children: [
//               Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [AppTheme.accentBlue, AppTheme.accentViolet]),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                         color: AppTheme.accentBlue.withOpacity(0.30),
//                         blurRadius: 20)
//                   ],
//                   border: Border.all(color: Colors.white, width: 3),
//                 ),
//                 child: Center(
//                     child: Text(initials,
//                         style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 28,
//                             fontWeight: FontWeight.w700))),
//               ),
//               const SizedBox(height: 14),
//               Text(name,
//                   style: AppTheme.sora(
//                       fontSize: 20, fontWeight: FontWeight.w700)),
//               const SizedBox(height: 4),
//               Text('Roll: ${ApiService.currentUserId ?? '---'}',
//                   style: AppTheme.dmSans(
//                       fontSize: 13, color: AppTheme.textSecondary)),
//               const SizedBox(height: 12),
//               const RoleBadge('STUDENT'),
//             ]),
//           ),
//           const SizedBox(height: 12),
//           GlassCard(
//             padding: const EdgeInsets.all(16),
//             child: Column(children: [
//               _profileRow(Icons.school_rounded, 'Department',
//                   'Computer Science'),
//               _profileRow(Icons.calendar_month_rounded, 'Semester',
//                   '5th Semester'),
//               _profileRow(Icons.email_rounded, 'Email',
//                   '${ApiService.currentUserId ?? 'student'}@college.edu'),
//               _profileRow(Icons.badge_rounded, 'Student ID',
//                   ApiService.currentUserId ?? '---'),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _profileRow(IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(children: [
//         Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//                 color: AppTheme.accentBlue.withOpacity(0.10),
//                 borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: AppTheme.accentBlue, size: 16)),
//         const SizedBox(width: 14),
//         Expanded(
//             child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//               Text(label,
//                   style: AppTheme.dmSans(
//                       fontSize: 11, color: AppTheme.textMuted)),
//               Text(value,
//                   style: AppTheme.dmSans(
//                       fontSize: 13, fontWeight: FontWeight.w600)),
//             ])),
//       ]),
//     );
//   }
// }

// // ── Ring Painter ──────────────────────────────────────────────────
// class _RingPainter extends CustomPainter {
//   final double percentage;
//   final Color color;
//   final Color trackColor;
//   final double strokeWidth;

//   const _RingPainter({
//     required this.percentage,
//     required this.color,
//     required this.trackColor,
//     this.strokeWidth = 6,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = (size.width - strokeWidth) / 2;
//     final paint = Paint()
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = strokeWidth
//       ..strokeCap = StrokeCap.round;
//     canvas.drawCircle(center, radius, paint..color = trackColor);
//     if (percentage > 0) {
//       canvas.drawArc(
//           Rect.fromCircle(center: center, radius: radius),
//           -math.pi / 2,
//           2 * math.pi * percentage.clamp(0, 1),
//           false,
//           paint..color = color);
//     }
//   }

//   @override
//   bool shouldRepaint(_RingPainter old) =>
//       old.percentage != percentage || old.color != color;
// }


// lib/screens/student_dashboard_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/dashboard_top_bar.dart';

import '../authentication/login_screen.dart';
import '../medical/medical_screen.dart';
import '../medical/student_medical_history_screen.dart';
import '../announcements/announcement_list_screen.dart';

// Classroom Integration
import '../../models/classroom_models.dart';
import '../classroom/classroom_detail_screen.dart';

// ─────────────────────────────────────────────────────────────────
//  StudentDashboardScreen — Shell with Bottom Navigation
// ─────────────────────────────────────────────────────────────────
class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _currentTab = 0;

  static const _navItems = [
    GlassNavItem(
        icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    GlassNavItem(
        icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: 'Classroom'),
    GlassNavItem(
        icon: Icons.campaign_outlined, activeIcon: Icons.campaign_rounded, label: 'Notices'),
    GlassNavItem(
        icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  void _logout() {
    ApiService.logout();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false);
  }

  void _switchTab(int index) {
    setState(() => _currentTab = index);
  }

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Student';
    final userId = ApiService.currentUserId ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      drawer: AppDrawer(
        userName: name,
        userId: userId,
        role: 'STUDENT',
        accentColor: AppTheme.accentBlue,
        onLogout: _logout,
      ),
      body: AppBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              IndexedStack(
                index: _currentTab,
                children: [
                  _StudentHomeTab(onSwitchTab: _switchTab),
                  const _StudentClassroomTab(), // Integrated Real Classroom Tab
                  const AnnouncementListScreen(), 
                  const _StudentProfileTab(),
                ],
              ),
              DashboardTopBar(
                accentColor: AppTheme.accentBlue,
                notificationCount: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentTab,
        items: _navItems,
        accentColor: AppTheme.accentBlue,
        onTap: (i) => setState(() => _currentTab = i),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 0 — Home
// ─────────────────────────────────────────────────────────────────
class _StudentHomeTab extends StatefulWidget {
  final void Function(int) onSwitchTab;
  const _StudentHomeTab({required this.onSwitchTab});

  @override
  State<_StudentHomeTab> createState() => _StudentHomeTabState();
}

class _StudentHomeTabState extends State<_StudentHomeTab>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;
  late AnimationController _numberCtrl;

  bool _isLoading = true;
  double _overallPct = 0.0;
  List<Map<String, dynamic>> _subjects = [];

  final List<Map<String, dynamic>> _schedule = [
    { 'subject': 'Computer Networks', 'code': 'CN', 'time': '09:00', 'room': 'N-206', 'faculty': 'Dr. Niroj Pani' },
    { 'subject': 'Machine Learning', 'code': 'ML', 'time': '11:00', 'room': 'N-205', 'faculty': 'Prof. M. Srinivas' },
    { 'subject': 'Operating System', 'code': 'OS', 'time': '14:00', 'room': 'N-206', 'faculty': 'Dr. Dillip Sahoo' },
  ];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _numberCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final studentId = ApiService.currentUserId ?? '2301105277';
    final data = await ApiService.fetchStudentDashboard(studentId);

    if (!mounted) return;

    setState(() {
      final List subjectsData = data['subjects'] ?? [];

      if (subjectsData.isEmpty) {
        _overallPct = 66.7;
        _subjects = [
          {'code': 'CN', 'name': 'Computer Networks', 'percentage': 84.5, 'color': AppTheme.accentBlue, 'attended': 33, 'total': 40},
          {'code': 'CD', 'name': 'Compiler Design', 'percentage': 75.5, 'color': AppTheme.accentViolet, 'attended': 31, 'total': 40},
          {'code': 'OS', 'name': 'Operating System', 'percentage': 50.0, 'color': const Color.fromARGB(255, 231, 147, 2), 'attended': 20, 'total': 40},
          {'code': 'ML', 'name': 'Machine Learning', 'percentage': 75.0, 'color': const Color.fromARGB(255, 120, 28, 186), 'attended': 30, 'total': 40},
        ];
      } else {
        _overallPct = (data['percentage'] ?? 0.0).toDouble();
        final colors = [AppTheme.accentBlue, AppTheme.accentViolet, const Color(0xFF3B82F6), AppTheme.accentTeal, AppTheme.accentPink, AppTheme.accentAmber];

        _subjects = subjectsData.asMap().entries.map((e) {
          final i = e.key;
          final subj = e.value;
          return {
            'code': subj['code'], 'name': subj['name'],
            'percentage': (subj['percentage'] ?? 0).toDouble(),
            'color': colors[i % colors.length], 
            'attended': subj['attended'] ?? 0, 'total': subj['total'] ?? 0,
          };
        }).toList();
      }
      _isLoading = false;
    });

    _staggerCtrl.reset();
    _numberCtrl.reset();
    _staggerCtrl.forward();
    _numberCtrl.forward();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  Color _colorForPct(double p) {
    if (p >= 75) return AppTheme.accentTeal;
    if (p >= 60) return AppTheme.accentAmber;
    return AppTheme.accentPink;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: Colors.white,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StaggerEntry(parent: _staggerCtrl, index: 0, child: _buildWelcomeCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 1, child: _buildClassroomActionCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 2, child: _buildScheduleCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 3, child: _buildAttendanceCard()),
            const SizedBox(height: 12),
            StaggerEntry(parent: _staggerCtrl, index: 4, child: _buildMedicalCard()),
          ],
        ),
      ),
    );
  }

  // ── Welcome card ──────────────────────────────────────────────
  Widget _buildWelcomeCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      glowColor: AppTheme.accentBlue,
      borderColor: AppTheme.accentBlue.withOpacity(0.25),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hello,', style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(ApiService.currentUserName ?? 'Student',
                    style: AppTheme.sora(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                GlassCard(
                  radius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  color: AppTheme.accentBlue.withOpacity(0.10),
                  borderColor: AppTheme.accentBlue.withOpacity(0.20),
                  child: Text('Dept. of Computer Science',
                      style: AppTheme.dmSans(fontSize: 11, color: AppTheme.accentBlue, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _numberCtrl,
            builder: (_, __) => _buildRing(_overallPct * _numberCtrl.value, 60),
          ),
        ],
      ),
    );
  }

  // ── Classroom Quick Access ────────────────────────────────────
  Widget _buildClassroomActionCard() {
    return GlassCard(
      onTap: () => widget.onSwitchTab(1), // Navigates directly to Classroom Tab
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentViolet.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: AppTheme.accentViolet),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("My Classrooms", style: AppTheme.sora(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text("Access Assignments & MCQ Tests", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.accentViolet),
        ],
      ),
    );
  }

  // ── Schedule card ─────────────────────────────────────────────
  Widget _buildScheduleCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.calendar_today_rounded, "Today's Schedule", AppTheme.accentBlue),
          const SizedBox(height: 12),
          ..._schedule.map((cls) => _buildScheduleItem(cls)).toList(),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Map<String, dynamic> cls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.accentBlue.withOpacity(0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: Text(cls['time'], style: AppTheme.mono(fontSize: 12, color: AppTheme.accentBlue, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls['subject'], style: AppTheme.dmSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('${cls['room']} • ${cls['faculty']}', style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.accentTeal.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
                  child: Text(cls['code'], style: AppTheme.dmSans(fontSize: 10, color: AppTheme.accentTeal, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Attendance card ───────────────────────────────────────────
  Widget _buildAttendanceCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionHeader(Icons.bar_chart_rounded, 'Attendance', AppTheme.accentViolet),
              const Spacer(),
              AnimatedBuilder(
                animation: _numberCtrl,
                builder: (_, __) {
                  final val = _overallPct * _numberCtrl.value;
                  return GlassCard(
                    radius: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: _colorForPct(_overallPct).withOpacity(0.10),
                    borderColor: _colorForPct(_overallPct).withOpacity(0.20),
                    child: Text('${val.toStringAsFixed(1)}%',
                        style: AppTheme.mono(fontSize: 12, color: _colorForPct(_overallPct), fontWeight: FontWeight.w700)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.92, crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: _subjects.length,
            itemBuilder: (_, i) => _buildSubjectCell(_subjects[i]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCell(Map<String, dynamic> sub) {
    final pct = sub['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = sub['color'] as Color;

    return GestureDetector(
      onTap: () => _showSubjectSheet(sub),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accent.withOpacity(0.20)),
              boxShadow: [BoxShadow(color: accent.withOpacity(0.06), blurRadius: 12)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _numberCtrl,
                  builder: (_, __) => SizedBox(
                    width: 50,
                    height: 50,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                            size: const Size(50, 50),
                            painter: _RingPainter(
                                percentage: (pct * _numberCtrl.value) / 100,
                                color: color, trackColor: color.withOpacity(0.12), strokeWidth: 4.5)),
                        Text('${(pct * _numberCtrl.value).toInt()}', style: AppTheme.mono(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(sub['code'], style: AppTheme.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Medical card ──────────────────────────────────────────────
  Widget _buildMedicalCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      glowColor: AppTheme.accentPink,
      borderColor: AppTheme.accentPink.withOpacity(0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(Icons.medical_services_rounded, 'Medical', AppTheme.accentPink),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMedBtn('Apply Leave', Icons.add_circle_outline_rounded, AppTheme.accentPink,
                  () => Navigator.push(context, AppTheme.slideRoute(const MedicalScreen())))),
              const SizedBox(width: 10),
              Expanded(child: _buildMedBtn('View History', Icons.history_rounded, AppTheme.accentAmber,
                  () => Navigator.push(context, AppTheme.slideRoute(StudentMedicalHistoryScreen(studentRollNo: ApiService.currentUserId ?? '2301105277'))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(label, style: AppTheme.dmSans(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTheme.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _buildRing(double pct, double size) {
    final color = _colorForPct(pct);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
              size: Size(size, size),
              painter: _RingPainter(percentage: pct / 100, color: color, trackColor: color.withOpacity(0.12), strokeWidth: 5)),
          Text('${pct.toInt()}%', style: AppTheme.mono(fontSize: 13, color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  void _showSubjectSheet(Map<String, dynamic> sub) {
    final pct = sub['percentage'] as double;
    final color = _colorForPct(pct);
    final accent = sub['color'] as Color;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.88),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: accent.withOpacity(0.20)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: AppTheme.textMuted, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(alignment: Alignment.center, children: [
                    CustomPaint(
                        size: const Size(100, 100),
                        painter: _RingPainter(percentage: pct / 100, color: color, trackColor: color.withOpacity(0.12), strokeWidth: 8)),
                    Text('${pct.toStringAsFixed(1)}%', style: AppTheme.mono(fontSize: 20, color: AppTheme.textPrimary, fontWeight: FontWeight.w800)),
                  ])),
              const SizedBox(height: 16),
              Text(sub['name'], textAlign: TextAlign.center, style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              StatusBadge(pct >= 75 ? 'ACCEPTED' : pct >= 60 ? 'PENDING' : 'REJECTED'),
              const SizedBox(height: 24),
              Row(children: [
                _sheetStat('Attended', '${sub['attended'] ?? '--'}', accent),
                _sheetStat('Total', '${sub['total'] ?? '--'}', accent),
                _sheetStat('Minimum', '75%', accent),
              ]),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _sheetStat(String label, String val, Color accent) {
    return Expanded(
        child: Column(children: [
      Text(val, style: AppTheme.mono(fontSize: 22, color: accent, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center, style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
    ]));
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 1 — Classroom (Fully Integrated API Tab)
// ─────────────────────────────────────────────────────────────────
class _StudentClassroomTab extends StatefulWidget {
  const _StudentClassroomTab();

  @override
  State<_StudentClassroomTab> createState() => _StudentClassroomTabState();
}

class _StudentClassroomTabState extends State<_StudentClassroomTab> {
  List<Classroom> classrooms = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClassrooms();
  }

  Future<void> fetchClassrooms() async {
    try {
      final token = await ApiService.getToken();
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/classroom/my-classes'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            classrooms = data.map((e) => Classroom.fromJson(e)).toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showJoinDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.glassFillHi,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Join a Class", style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          style: AppTheme.dmSans(),
          decoration: const InputDecoration(hintText: "Enter 6-digit Code"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Cancel", style: AppTheme.dmSans(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => isLoading = true);
              
              try {
                final token = await ApiService.getToken();
                await http.post(
                  Uri.parse('${AppConfig.baseUrl}/api/classroom/join'),
                  headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
                  body: jsonEncode({'code': controller.text}),
                );
                fetchClassrooms();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action failed: $e")));
                setState(() => isLoading = false);
              }
            },
            child: Text("Join", style: AppTheme.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.accentBlue,
      backgroundColor: Colors.white,
      onRefresh: fetchClassrooms,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Classroom', style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Access your course materials', style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _showJoinDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text("Join", style: AppTheme.dmSans(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (classrooms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No classrooms found.\nJoin one using a code!", textAlign: TextAlign.center, style: AppTheme.sora(color: AppTheme.textMuted, fontSize: 16)),
                ),
              )
            else
              ...classrooms.map((cls) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  onTap: () {
                    Navigator.push(context, AppTheme.slideRoute(ClassroomDetailScreen(classroom: cls)));
                  },
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.15), shape: BoxShape.circle),
                        child: Center(
                          child: Text(cls.name[0].toUpperCase(), style: AppTheme.sora(color: AppTheme.accentBlue, fontSize: 22, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(cls.name, style: AppTheme.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            const RoleBadge("STUDENT"),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.bgDeepBlue),
                    ],
                  ),
                ),
              )).toList(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  TAB 3 — Profile  
// ─────────────────────────────────────────────────────────────────
class _StudentProfileTab extends StatelessWidget {
  const _StudentProfileTab();

  @override
  Widget build(BuildContext context) {
    final name = ApiService.currentUserName ?? 'Student';
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 68, 16, 110),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.accentBlue, AppTheme.accentViolet]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.30), blurRadius: 20)],
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(height: 14),
              Text(name, style: AppTheme.sora(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Roll: ${ApiService.currentUserId ?? '---'}', style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              const RoleBadge('STUDENT'),
            ]),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _profileRow(Icons.school_rounded, 'Department', 'Computer Science'),
              _profileRow(Icons.calendar_month_rounded, 'Semester', '5th Semester'),
              _profileRow(Icons.email_rounded, 'Email', '${ApiService.currentUserId ?? 'student'}@college.edu'),
              _profileRow(Icons.badge_rounded, 'Student ID', ApiService.currentUserId ?? '---'),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _profileRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.accentBlue.withOpacity(0.10), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.accentBlue, size: 16)),
        const SizedBox(width: 14),
        Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTheme.dmSans(fontSize: 11, color: AppTheme.textMuted)),
          Text(value, style: AppTheme.dmSans(fontSize: 13, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}

// ── Ring Painter ──────────────────────────────────────────────────
class _RingPainter extends CustomPainter {
  final double percentage;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.percentage, required this.color, required this.trackColor, this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = strokeWidth..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint..color = trackColor);
    if (percentage > 0) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * percentage.clamp(0, 1), false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.percentage != percentage || old.color != color;
}