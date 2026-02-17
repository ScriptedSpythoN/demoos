import 'package:flutter/material.dart';
import '../models/medical_entry.dart';
import '../services/api_service.dart';

class MedicalDetailScreen extends StatefulWidget {
  final MedicalEntry entry;

  const MedicalDetailScreen({super.key, required this.entry});

  @override
  State<MedicalDetailScreen> createState() => _MedicalDetailScreenState();
}

class _MedicalDetailScreenState extends State<MedicalDetailScreen> {
  final TextEditingController _remarkController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _submitDecision(String action) async {
    if (action == 'REJECTED' && _remarkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a remark for rejection.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await ApiService.reviewMedical(
        widget.entry.requestId,
        action,
        _remarkController.text,
      );
      if (mounted) {
        Navigator.pop(context, true); // Return 'true' to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder for AI Data (In production, map this from the Entry model)
    // bool warning = widget.entry.ocrStatus == 'MISMATCH';

    return Scaffold(
      appBar: AppBar(title: Text('Review: ${widget.entry.studentRollNo}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            const Text('HOD Remarks',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _remarkController,
              decoration: const InputDecoration(
                hintText: 'Add notes (Required for Rejection)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _submitDecision('REJECTED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('REJECT'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _submitDecision('APPROVED'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('APPROVE'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Student ID', widget.entry.studentRollNo),
            const Divider(),
            _row('Claimed Dates',
                '${_fmt(widget.entry.fromDate)} to ${_fmt(widget.entry.toDate)}'),
            const Divider(),
            _row('Reason', widget.entry.reason),
            const Divider(),
            // In a real app, this would be a link to open the PDF
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    // Logic to open PDF URL
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening PDF Viewer...')));
                  },
                  child: const Text('View Attached Certificate'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
