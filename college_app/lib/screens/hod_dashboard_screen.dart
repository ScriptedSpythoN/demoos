import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';

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
    try {
      final requests = await ApiService.fetchPendingMedical(widget.departmentId);
      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading requests: $e")),
      );
    }
  }

  Future<void> _reviewRequest(MedicalEntry entry, String action) async {
    try {
      await ApiService.reviewMedical(entry.requestId, action, null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${entry.studentRollNo} marked $action")),
      );
      setState(() => pendingRequests.remove(entry));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error reviewing request: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (pendingRequests.isEmpty) return const Scaffold(body: Center(child: Text("No pending requests")));

    return Scaffold(
      appBar: AppBar(title: const Text("HoD Dashboard")),
      body: ListView.builder(
        itemCount: pendingRequests.length,
        itemBuilder: (context, index) {
          final req = pendingRequests[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(req.studentRollNo),
              subtitle: Text("${req.fromDate.toLocal().toString().split(' ')[0]} → ${req.toDate.toLocal().toString().split(' ')[0]}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _reviewRequest(req, "APPROVE"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _reviewRequest(req, "REJECT"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
