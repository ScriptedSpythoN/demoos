import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';
import 'medical_detail_screen.dart'; // We will create this next
import 'login_screen.dart';

class HoDDashboardScreen extends StatefulWidget {
  const HoDDashboardScreen({super.key, required this.departmentId});
  final String departmentId;

  @override
  State<HoDDashboardScreen> createState() => _HoDDashboardScreenState();
}

class _HoDDashboardScreenState extends State<HoDDashboardScreen> {
  List<MedicalEntry> pendingRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    // Capture what we need from context before awaiting to avoid using
    // BuildContext across async gaps.
    final messenger = ScaffoldMessenger.of(context);
    try {
      final requests =
          await ApiService.fetchPendingMedical(widget.departmentId);
      if (!mounted) return;
      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadPendingRequests();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await ApiService.logout();
              if (!mounted) return;
              nav.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    return _buildRequestCard(pendingRequests[index]);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: Colors.green.shade200),
          const SizedBox(height: 16),
          Text('All caught up!',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildRequestCard(MedicalEntry req) {
    // Check for AI flags (requires updating MedicalEntry model to include 'isDateMismatch')
    // Assuming you update the model as shown in the previous turn's fix
    // For now, we simulate visual logic based on data presence

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Text(
              req.studentRollNo.substring(req.studentRollNo.length > 2
                  ? req.studentRollNo.length - 2
                  : 0),
              style: TextStyle(
                  color: Colors.indigo.shade700, fontWeight: FontWeight.bold)),
        ),
        title: Text(
          req.studentRollNo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
                "${req.fromDate.toString().split(' ')[0]} to ${req.toDate.toString().split(' ')[0]}"),
            const SizedBox(height: 4),
            Text(req.reason, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          // Navigate to Detail Screen for decision
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MedicalDetailScreen(entry: req),
            ),
          );

          // Refresh if a decision was made
          if (result == true) {
            _loadPendingRequests();
          }
        },
      ),
    );
  }
}
