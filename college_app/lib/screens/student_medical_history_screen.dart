import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';

class StudentMedicalHistoryScreen extends StatefulWidget {
  const StudentMedicalHistoryScreen({super.key, required this.studentRollNo});

  final String studentRollNo;

  @override
  State<StudentMedicalHistoryScreen> createState() =>
      _StudentMedicalHistoryScreenState();
}

class _StudentMedicalHistoryScreenState
    extends State<StudentMedicalHistoryScreen> {
  List<MedicalEntry> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final allDeptIds = ['CSE']; // Replace with actual student dept
      List<MedicalEntry> allRequests = [];
      for (var dept in allDeptIds) {
        final reqs = await ApiService.fetchPendingMedical(dept);
        allRequests
            .addAll(reqs.where((r) => r.studentRollNo == widget.studentRollNo));
      }
      if (!mounted) return;
      setState(() {
        submissions = allRequests;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Error fetching history: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (submissions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No submissions found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Medical History')),
      body: ListView.builder(
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final entry = submissions[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(
                  "${entry.fromDate.toLocal().toString().split(' ')[0]} → ${entry.toDate.toLocal().toString().split(' ')[0]}"),
              subtitle: Text(
                  "Status: ${entry.status} | HoD Remark: ${entry.hodRemark ?? 'None'}"),
            ),
          );
        },
      ),
    );
  }
}
