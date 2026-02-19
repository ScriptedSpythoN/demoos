// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen>
    with TickerProviderStateMixin {
  // Form Controllers
  File? _selectedFile;
  DateTime? _fromDate;
  DateTime? _toDate;
  String _reason = '';
  String _doctorName = '';
  String _hospitalName = '';
  String _contactNumber = '';
  bool submitting = false;

  // Controllers
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  // Stepper
  int _currentStep = 0;

  // Animations
  late AnimationController _pageAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _pageAnimationController,
      curve: Curves.easeOut,
    );

    _pageAnimationController.forward();
  }

  @override
  void dispose() {
    _pageAnimationController.dispose();
    _reasonController.dispose();
    _doctorNameController.dispose();
    _hospitalController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (!_validateForm()) {
      _showSnackBar(
        "Please complete all required fields",
        Colors.orange.shade600,
        Icons.warning_rounded,
      );
      return;
    }

    setState(() => submitting = true);
    try {
      await ApiService.submitMedical(
        studentRollNo: ApiService.currentUserId ?? "CSE045",
        departmentId: "CSE",
        fromDate: _fromDate!,
        toDate: _toDate!,
        reason: _reason,
        pdfFile: _selectedFile!,
      );

      _showSnackBar(
        "Medical leave request submitted successfully!",
        Colors.green.shade600,
        Icons.check_circle_rounded,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentStep = 0;
          _selectedFile = null;
          _fromDate = null;
          _toDate = null;
          _reason = '';
          _doctorName = '';
          _hospitalName = '';
          _contactNumber = '';
          _reasonController.clear();
          _doctorNameController.clear();
          _hospitalController.clear();
          _contactController.clear();
        });
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar(
        "Failed to submit: ${e.toString()}",
        Colors.red.shade600,
        Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  bool _validateForm() {
    return _selectedFile != null &&
        _fromDate != null &&
        _toDate != null &&
        _reason.isNotEmpty &&
        _doctorName.isNotEmpty &&
        _hospitalName.isNotEmpty;
  }

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _fromDate != null && _toDate != null;
      case 1:
        return _reason.isNotEmpty &&
            _doctorName.isNotEmpty &&
            _hospitalName.isNotEmpty;
      case 2:
        return _selectedFile != null;
      default:
        return false;
    }
  }

  void _showSnackBar(String message, Color backgroundColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? _fromDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.grey.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_toDate != null && _toDate!.isBefore(picked)) {
            _toDate = null;
          }
        } else {
          _toDate = picked;
        }
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 2 && _validateStep(_currentStep)) {
      setState(() => _currentStep++);
    } else if (!_validateStep(_currentStep)) {
      _showSnackBar(
        "Please complete all fields in this section",
        Colors.orange.shade600,
        Icons.warning_rounded,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildModernAppBar(),
            _buildStepperIndicator(),
            Expanded(
              child: _buildStepContent(),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // Modern App Bar
  Widget _buildModernAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Medical Leave Application",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Step ${_currentStep + 1} of 3",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(((_currentStep + 1) / 3) * 100).toInt()}%",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Stepper Indicator - Mobile Optimized
  Widget _buildStepperIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      color: Colors.white,
      child: Row(
        children: [
          _buildStepCircle(0, "Duration", Icons.calendar_month_rounded),
          _buildStepConnector(0),
          _buildStepCircle(1, "Details", Icons.description_rounded),
          _buildStepConnector(1),
          _buildStepCircle(2, "Document", Icons.upload_file_rounded),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepIndex, String label, IconData icon) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.shade500
                  : isActive
                      ? Colors.indigo.shade600
                      : Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: (isActive || isCompleted) ? Colors.white : Colors.grey.shade500,
              size: 20,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? Colors.indigo.shade600
                  : isCompleted
                      ? Colors.green.shade600
                      : Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int stepIndex) {
    final isCompleted = _currentStep > stepIndex;

    return Expanded(
      flex: 1,
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.shade500 : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Step Content - Mobile Optimized
  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: SingleChildScrollView(
        key: ValueKey<int>(_currentStep),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) _buildStep1LeaveDetails(),
            if (_currentStep == 1) _buildStep2MedicalDetails(),
            if (_currentStep == 2) _buildStep3DocumentUpload(),
            const SizedBox(height: 90),
          ],
        ),
      ),
    );
  }

  // Step 1: Leave Duration
  Widget _buildStep1LeaveDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          "Leave Duration",
          "Choose start and end dates",
          Icons.event_rounded,
        ),
        const SizedBox(height: 18),
        _buildDateRangeCards(),
        const SizedBox(height: 14),
        _buildLeaveSummaryCard(),
      ],
    );
  }

  // Step 2: Medical Details
  Widget _buildStep2MedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          "Medical Information",
          "Provide medical details",
          Icons.local_hospital_rounded,
        ),
        const SizedBox(height: 18),
        _buildInputField(
          label: "Medical Reason",
          hint: "e.g., Viral fever with severe cold",
          controller: _reasonController,
          icon: Icons.sick_rounded,
          maxLines: 3,
          onChanged: (val) => setState(() => _reason = val),
          required: true,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          label: "Doctor's Name",
          hint: "Dr. John Smith",
          controller: _doctorNameController,
          icon: Icons.medical_services_rounded,
          onChanged: (val) => setState(() => _doctorName = val),
          required: true,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          label: "Hospital / Clinic Name",
          hint: "City General Hospital",
          controller: _hospitalController,
          icon: Icons.business_rounded,
          onChanged: (val) => setState(() => _hospitalName = val),
          required: true,
        ),
        const SizedBox(height: 14),
        _buildInputField(
          label: "Emergency Contact",
          hint: "+91 98765 43210",
          controller: _contactController,
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          onChanged: (val) => setState(() => _contactNumber = val),
          required: false,
        ),
      ],
    );
  }

  // Step 3: Document Upload
  Widget _buildStep3DocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle(
          "Medical Certificate",
          "Upload supporting document",
          Icons.description_rounded,
        ),
        const SizedBox(height: 18),
        _buildDocumentUploadCard(),
        const SizedBox(height: 16),
        _buildUploadGuidelines(),
      ],
    );
  }

  // Step Title Widget - Responsive
  Widget _buildStepTitle(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade500, Colors.indigo.shade700],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 0.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Date Range Cards - Compact
  Widget _buildDateRangeCards() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDateCard(isFrom: true),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    size: 16,
                    color: Colors.indigo.shade400,
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
              ],
            ),
          ),
          _buildDateCard(isFrom: false),
        ],
      ),
    );
  }

  Widget _buildDateCard({required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final label = isFrom ? "Start Date" : "End Date";
    final hasDate = date != null;

    return InkWell(
      onTap: () => _pickDate(isFrom: isFrom),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasDate ? Colors.indigo.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDate ? Colors.indigo.shade300 : Colors.grey.shade300,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasDate ? Colors.indigo.shade100 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: hasDate ? Colors.indigo.shade700 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasDate
                        ? "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}"
                        : "Select date",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: hasDate ? Colors.black87 : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Leave Summary Card - Compact
  Widget _buildLeaveSummaryCard() {
    if (_fromDate == null || _toDate == null) return const SizedBox.shrink();

    final duration = _toDate!.difference(_fromDate!).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.indigo.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: Colors.indigo.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Leave Duration",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$duration ${duration == 1 ? 'day' : 'days'}",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Input Field Widget - Compact
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    required bool required,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 3),
              Text(
                "*",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(icon, color: Colors.indigo.shade400, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    BorderSide(color: Colors.indigo.shade400, width: 1.8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Document Upload Card - Mobile Optimized
  Widget _buildDocumentUploadCard() {
    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _selectedFile != null
                ? Colors.green.shade400
                : Colors.grey.shade300,
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedFile != null
                  ? Colors.green.withOpacity(0.12)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _selectedFile != null
            ? _buildUploadedFileView()
            : _buildUploadPromptView(),
      ),
    );
  }

  Widget _buildUploadedFileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.green.shade600,
                size: 36,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          "Document Uploaded",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          _selectedFile!.path.split("/").last,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, size: 14, color: Colors.green.shade700),
              const SizedBox(width: 5),
              Text(
                "Tap to replace",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPromptView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.blue.shade50],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cloud_upload_rounded,
            size: 38,
            color: Colors.indigo.shade400,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Upload Medical Certificate",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Text(
          "Tap to select PDF document",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade700],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.upload_rounded, color: Colors.white, size: 16),
              SizedBox(width: 7),
              Text(
                "Select PDF",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Upload Guidelines - Compact
  Widget _buildUploadGuidelines() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.amber.shade700, size: 17),
              const SizedBox(width: 8),
              Text(
                "Document Guidelines",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildGuidelineItem("PDF format only (max 5MB)"),
          _buildGuidelineItem("Clear and readable copy"),
          _buildGuidelineItem("Doctor's signature required"),
          _buildGuidelineItem("Valid letterhead needed"),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.amber.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: Colors.amber.shade900,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Buttons - Mobile Optimized
  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 2;
    final canProceed = _validateStep(_currentStep);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.indigo.shade600,
                    side: BorderSide(color: Colors.indigo.shade300, width: 1.8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back_rounded, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Previous",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 10),
            Expanded(
              flex: _currentStep == 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: (submitting || !canProceed)
                    ? null
                    : (isLastStep ? _submit : _nextStep),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  elevation: canProceed ? 1.5 : 0,
                ),
                child: submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.3,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastStep ? "Submit" : "Continue",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLastStep
                                ? Icons.send_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}