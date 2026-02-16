import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'medical_screen.dart';
import 'student_medical_history_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  bool _showOverallAttendance = false;

  // Subject data structure
  final List<Map<String, dynamic>> _subjects = [
    {
      'code': 'CN',
      'name': 'Computer Networks',
      'percentage': 82.5,
      'color': const Color(0xFF6366F1), // Indigo
    },
    {
      'code': 'CD',
      'name': 'Compiler Design',
      'percentage': 78.0,
      'color': const Color(0xFF8B5CF6), // Violet
    },
    {
      'code': 'OS',
      'name': 'Operating System',
      'percentage': 85.5,
      'color': const Color(0xFF3B82F6), // Blue
    },
    {
      'code': 'ESSP',
      'name': 'Enhancing Soft Skills And Personality',
      'percentage': 91.0,
      'color': const Color(0xFF10B981), // Green
    },
    {
      'code': 'ML',
      'name': 'Machine Learning',
      'percentage': 68.5,
      'color': const Color(0xFFEC4899), // Pink
    },
    {
      'code': 'DLD',
      'name': 'Digital Logic Design',
      'percentage': 72.0,
      'color': const Color(0xFFF59E0B), // Amber
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  void _loadStats() {
    setState(() {
      _statsFuture = ApiService.fetchStudentStats(
          ApiService.currentUserId ?? "2301105277");
    });
  }

  void _logout(BuildContext context) {
    ApiService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  double _calculateOverallPercentage() {
    if (_subjects.isEmpty) return 0.0;
    final total = _subjects.fold<double>(
        0.0, (sum, subject) => sum + (subject['percentage'] as double));
    return total / _subjects.length;
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 75) {
      return Colors.green;
    } else if (percentage >= 65) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Student Portal",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 16),
              _buildAttendanceSection(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              _buildNotificationsSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Header Section with Student Info
  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ApiService.currentUserName ?? 'Student',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Department of Computer Science",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Attendance Section
  Widget _buildAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Attendance Overview",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showOverallAttendance = !_showOverallAttendance;
                  });
                },
                icon: Icon(
                  _showOverallAttendance
                      ? Icons.grid_view_rounded
                      : Icons.analytics_rounded,
                  size: 18,
                ),
                label: Text(
                  _showOverallAttendance ? "View Subjects" : "View Overall",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Toggle between subject-wise and overall attendance
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _showOverallAttendance
                ? _buildOverallAttendanceCard()
                : _buildSubjectWiseAttendance(),
          ),
        ],
      ),
    );
  }

  // Subject-wise Attendance Cards
  Widget _buildSubjectWiseAttendance() {
    return GridView.builder(
      key: const ValueKey('subject_grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1, // Reduced from 1.25 to 1.1 to fix ESSP overflow
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _subjects.length,
      itemBuilder: (context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(
          code: subject['code'],
          name: subject['name'],
          percentage: subject['percentage'],
          color: subject['color'],
        );
      },
    );
  }

  // Individual Subject Card
  Widget _buildSubjectCard({
    required String code,
    required String name,
    required double percentage,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Show detailed attendance info
            _showSubjectDetails(code, name, percentage);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        code,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.trending_up_rounded,
                      size: 16,
                      color: _getAttendanceColor(percentage),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${percentage.toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "attendance",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Overall Attendance Card with Progress Bar
  Widget _buildOverallAttendanceCard() {
    final overallPercentage = _calculateOverallPercentage();
    final attendanceColor = _getAttendanceColor(overallPercentage);
    final bool isShortage = overallPercentage < 75;

    return Container(
      key: const ValueKey('overall_card'),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isShortage
              ? [Colors.red.shade700, Colors.orange.shade700]
              : overallPercentage >= 75 && overallPercentage < 80
                  ? [Colors.orange.shade600, Colors.amber.shade600]
                  : [Colors.green.shade600, Colors.teal.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: attendanceColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "Overall Attendance Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "${overallPercentage.toStringAsFixed(1)}%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isShortage
                ? "Attention Required!"
                : overallPercentage >= 75 && overallPercentage < 80
                    ? "Almost There!"
                    : "Excellent Performance!",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: overallPercentage / 100,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusInfo(
                icon: Icons.check_circle_outline_rounded,
                label: "Target",
                value: "75%",
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatusInfo(
                icon: Icons.school_rounded,
                label: "Subjects",
                value: "${_subjects.length}",
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildStatusInfo(
                icon: Icons.trending_up_rounded,
                label: "Status",
                value: isShortage
                    ? "Low"
                    : overallPercentage >= 80
                        ? "High"
                        : "Good",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // Quick Actions Section
  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildActionCard(
                context,
                title: "Apply Medical",
                subtitle: "Submit leave",
                icon: Icons.medical_services_rounded,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MedicalScreen()),
                ),
              ),
              const SizedBox(width: 12),
              _buildActionCard(
                context,
                title: "View History",
                subtitle: "Past requests",
                icon: Icons.history_rounded,
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentMedicalHistoryScreen(
                      studentRollNo:
                          ApiService.currentUserId ?? "2301105277",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Notifications Section
  Widget _buildNotificationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Notifications",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            "Medical request approved",
            "Your medical leave has been approved by HOD",
            "2 hours ago",
            Icons.check_circle_rounded,
            Colors.green,
          ),
          _buildNotificationItem(
            "Attendance updated",
            "Computer Networks attendance marked for today",
            "Yesterday",
            Icons.notifications_rounded,
            Colors.blue,
          ),
          _buildNotificationItem(
            "Low attendance alert",
            "Machine Learning attendance below 75%",
            "2 days ago",
            Icons.warning_rounded,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Show Subject Details Dialog
  void _showSubjectDetails(String code, String name, double percentage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getAttendanceColor(percentage).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: _getAttendanceColor(percentage),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${percentage.toStringAsFixed(1)}%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getAttendanceColor(percentage),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Current Attendance",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow("Classes Attended", "33"),
            _buildDetailRow("Total Classes", "40"),
            _buildDetailRow(
                "Status",
                percentage >= 75
                    ? "Good"
                    : percentage >= 65
                        ? "Warning"
                        : "Critical"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}