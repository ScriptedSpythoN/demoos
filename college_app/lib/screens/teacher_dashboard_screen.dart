import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'attendance_screen.dart';
import 'login_screen.dart';
import 'ai_evaluation_screen.dart'; // <--- IMPORT THE HERO SCREEN

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  late Future<List<Map<String, dynamic>>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() {
    setState(() {
      _scheduleFuture = ApiService.fetchTeacherSchedule();
    });
  }

  void _logout(BuildContext context) {
    ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("EduPiece Teacher"),
        backgroundColor: Colors.indigo.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          
          // --- HERO FEATURE SECTION ---
          _buildAiToolsSection(context),
          
          // --- SECTION TITLE ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  "Assigned Classes",
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // --- SCHEDULE LIST ---
          Expanded(child: _buildScheduleList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.indigo.shade700,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.indigo.shade100,
              child: Icon(Icons.person, size: 35, color: Colors.indigo.shade700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome,",
                  style: TextStyle(color: Colors.indigo.shade100, fontSize: 14),
                ),
                Text(
                  ApiService.currentUserName ?? "Professor",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiToolsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.psychology, size: 32, color: Colors.purple.shade700),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("AI Answer Checker",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Auto-grade scanned papers",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the HERO Feature
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiEvaluationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text("Open"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _scheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final classes = snapshot.data ?? [];

        if (classes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  "No classes assigned",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final cls = classes[index];
            return _buildClassCard(
              context,
              subjectName: cls['subject_name'] ?? "Unknown",
              subjectCode: cls['subject_code'] ?? "---",
              timeSlot: cls['time_slot'] ?? "TBD",
              room: cls['room'] ?? "LH",
              className: cls['class_identifier'] ?? "General",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceScreen(
                      classId: cls['class_identifier'], // "CSE - 6th Sem"
                      subjectId: cls['subject_code'],   // "CS601"
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildClassCard(BuildContext context,
      {required String subjectName,
      required String subjectCode,
      required String timeSlot,
      required String room,
      required String className,
      required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Left Time Column
                Column(
                  children: [
                    Text(
                      timeSlot.split(' - ')[0],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 40, color: Colors.grey.shade200),
                const SizedBox(width: 16),
                // Center Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subjectName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              subjectCode,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            className,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}