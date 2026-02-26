// ignore_for_file: unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for inputFormatters
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

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
        AppTheme.accentAmber,
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
        AppTheme.accentTeal,
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
        AppTheme.accentPink,
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
                style: AppTheme.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor.withOpacity(0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    // Logic Fix: Prevent negative date ranges
    final initialFirstDate = isFrom
        ? DateTime(2020)
        : (_fromDate ?? DateTime(2020));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime.now())
          : (_toDate ?? _fromDate ?? DateTime.now()),
      firstDate: initialFirstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.accentBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
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
        "Please complete all required fields",
        AppTheme.accentAmber,
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
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Medical Leave", style: AppTheme.sora(fontSize: 18)),
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${(((_currentStep + 1) / 3) * 100).toInt()}%",
                  style: AppTheme.mono(
                    color: AppTheme.accentBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 96), // Safely clears the transparent AppBar
              _buildStepperIndicator(),
              Expanded(
                child: _buildStepContent(),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Glassmorphic Stepper ──────────────────────────────────────────
  Widget _buildStepperIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

    Color color;
    if (isCompleted) {
      color = AppTheme.accentTeal;
    } else if (isActive) {
      color = AppTheme.accentBlue;
    } else {
      color = AppTheme.textMuted.withOpacity(0.3);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isActive || isCompleted) ? color : Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: (isActive || isCompleted) ? color : Colors.white,
                width: 2,
              ),
              boxShadow: isActive || isCompleted
                  ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : [],
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              color: (isActive || isCompleted) ? Colors.white : AppTheme.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTheme.dmSans(
              fontSize: 11,
              fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w500,
              color: isActive || isCompleted ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
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
        height: 3,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isCompleted ? AppTheme.accentTeal : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // ── Scrollable Content Area ───────────────────────────────────────
  Widget _buildStepContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SingleChildScrollView(
        key: ValueKey<int>(_currentStep),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) _buildStep1LeaveDetails(),
            if (_currentStep == 1) _buildStep2MedicalDetails(),
            if (_currentStep == 2) _buildStep3DocumentUpload(),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Leave Duration ────────────────────────────────────────
  Widget _buildStep1LeaveDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle("Leave Duration", "Choose start and end dates", Icons.date_range_rounded),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateCard(isFrom: true),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.accentBlue.withOpacity(0.15), thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_downward_rounded, size: 16, color: AppTheme.textMuted),
                    ),
                    Expanded(child: Divider(color: AppTheme.accentBlue.withOpacity(0.15), thickness: 1)),
                  ],
                ),
              ),
              _buildDateCard(isFrom: false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildLeaveSummaryCard(),
      ],
    );
  }

  // ── Step 2: Medical Details ───────────────────────────────────────
  Widget _buildStep2MedicalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle("Medical Information", "Provide illness and doctor details", Icons.local_hospital_rounded),
        const SizedBox(height: 24),
        _buildInputField(
          label: "Medical Reason",
          hint: "e.g., Viral fever with severe cold",
          controller: _reasonController,
          icon: Icons.sick_outlined,
          maxLines: 3,
          onChanged: (val) => setState(() => _reason = val),
          required: true,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: "Doctor's Name",
          hint: "Dr. John Smith",
          controller: _doctorNameController,
          icon: Icons.medical_services_outlined,
          onChanged: (val) => setState(() => _doctorName = val),
          required: true,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: "Hospital / Clinic Name",
          hint: "City General Hospital",
          controller: _hospitalController,
          icon: Icons.business_rounded,
          onChanged: (val) => setState(() => _hospitalName = val),
          required: true,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          label: "Emergency Contact",
          hint: "10-digit mobile number",
          controller: _contactController,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          maxLength: 10, // Logic Fix: Restrict to 10 digits
          inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Logic Fix: Only allow numbers
          onChanged: (val) => setState(() => _contactNumber = val),
          required: false,
        ),
      ],
    );
  }

  // ── Step 3: Document Upload ───────────────────────────────────────
  Widget _buildStep3DocumentUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepTitle("Medical Certificate", "Upload the supporting document", Icons.description_outlined),
        const SizedBox(height: 24),
        _buildDocumentUploadCard(),
        const SizedBox(height: 20),
        _buildUploadGuidelines(),
      ],
    );
  }

  // ── UI Helpers ────────────────────────────────────────────────────
  Widget _buildStepTitle(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Icon(icon, color: AppTheme.accentBlue, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard({required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final label = isFrom ? "Start Date" : "End Date";
    final hasDate = date != null;

    return InkWell(
      onTap: () => _pickDate(isFrom: isFrom),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasDate ? AppTheme.accentBlue.withOpacity(0.05) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDate ? AppTheme.accentBlue.withOpacity(0.3) : Colors.white.withOpacity(0.6),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: hasDate ? AppTheme.accentBlue.withOpacity(0.15) : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: hasDate ? AppTheme.accentBlue : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    hasDate
                        ? "${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}"
                        : "Select date",
                    style: AppTheme.sora(
                      fontSize: 15,
                      color: hasDate ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 22),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  Widget _buildLeaveSummaryCard() {
    if (_fromDate == null || _toDate == null) return const SizedBox.shrink();
    final duration = _toDate!.difference(_fromDate!).inDays + 1;

    return GlassCard(
      glowColor: AppTheme.accentBlue,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.1), blurRadius: 8)],
            ),
            child: const Icon(Icons.info_outline_rounded, color: AppTheme.accentBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Leave Duration", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  "$duration ${duration == 1 ? 'day' : 'days'}",
                  style: AppTheme.sora(fontSize: 16, color: AppTheme.accentBlue, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    required bool required,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTheme.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            children: [if (required) TextSpan(text: ' *', style: TextStyle(color: AppTheme.accentPink))],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.9)),
            boxShadow: [BoxShadow(color: AppTheme.accentBlue.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: maxLines,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            style: AppTheme.dmSans(fontSize: 15),
            decoration: InputDecoration(
              counterText: "", // Hides the "0/10" text at the bottom
              hintText: hint,
              hintStyle: AppTheme.dmSans(color: AppTheme.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: AppTheme.accentBlue, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard() {
    final hasFile = _selectedFile != null;
    final color = hasFile ? AppTheme.accentTeal : AppTheme.accentBlue;

    return GestureDetector(
      onTap: _pickFile,
      child: GlassCard(
        borderColor: hasFile ? AppTheme.accentTeal.withOpacity(0.4) : null,
        glowColor: hasFile ? AppTheme.accentTeal : AppTheme.accentBlue,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFile ? Icons.task_rounded : Icons.cloud_upload_outlined,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              hasFile ? "Document Ready" : "Upload Medical Certificate",
              style: AppTheme.sora(fontSize: 16, fontWeight: FontWeight.w700, color: hasFile ? color : AppTheme.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFile ? _selectedFile!.path.split("/").last : "Tap to browse PDF files",
              style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (hasFile) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text("Tap to change", style: AppTheme.dmSans(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildUploadGuidelines() {
    return GlassCard(
      color: AppTheme.accentAmber.withOpacity(0.05),
      borderColor: AppTheme.accentAmber.withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.accentAmber, size: 18),
              const SizedBox(width: 8),
              Text("Document Guidelines", style: AppTheme.sora(fontSize: 14, color: AppTheme.accentAmber, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem("PDF format only (max 5MB)"),
          _buildGuidelineItem("Must be a clear and readable copy"),
          _buildGuidelineItem("Doctor's signature required"),
          _buildGuidelineItem("Hospital/Clinic letterhead needed"),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5, height: 5,
              decoration: const BoxDecoration(color: AppTheme.accentAmber, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: AppTheme.dmSans(fontSize: 13, color: AppTheme.textPrimary.withOpacity(0.7)))),
        ],
      ),
    );
  }

  // ── Bottom Navigation ─────────────────────────────────────────────
  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 2;
    final canProceed = _validateStep(_currentStep);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: GestureDetector(
                onTap: _previousStep,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_rounded, size: 18, color: AppTheme.accentBlue),
                        const SizedBox(width: 8),
                        Text("Back", style: AppTheme.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.accentBlue)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: GlowButton(
              label: isLastStep ? "Submit Request" : "Continue",
              accent: isLastStep ? AppTheme.accentTeal : AppTheme.accentBlue,
              isLoading: submitting,
              icon: isLastStep ? null : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
              onPressed: canProceed ? (isLastStep ? _submit : _nextStep) : null,
            ),
          ),
        ],
      ),
    );
  }
}