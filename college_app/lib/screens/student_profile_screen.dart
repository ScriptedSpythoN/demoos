// lib/screens/student_profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_widgets.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isSaving  = false;

  late StudentProfile _profile;

  // controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _regNoCtrl;
  late TextEditingController _rollCtrl;
  late TextEditingController _semCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _guardNameCtrl;
  late TextEditingController _guardContactCtrl;

  late AnimationController _entryCtrl;
  late Animation<double>   _fade;

  static const _accent = AppTheme.accentBlue;

  @override
  void initState() {
    super.initState();
    _profile = StudentProfile(
      name: ApiService.currentUserName ?? 'Student',
      registrationNumber: ApiService.currentUserId ?? '',
      rollNumber: ApiService.currentUserId ?? '',
      semester: StudentProfile.deriveSemester(
          ApiService.currentUserId ?? ''),
    );

    _nameCtrl         = TextEditingController(text: _profile.name);
    _regNoCtrl        = TextEditingController(text: _profile.registrationNumber);
    _rollCtrl         = TextEditingController(text: _profile.rollNumber);
    _semCtrl          = TextEditingController(text: _profile.semester);
    _contactCtrl      = TextEditingController(text: _profile.contactNumber);
    _emailCtrl        = TextEditingController(text: _profile.email);
    _guardNameCtrl    = TextEditingController(text: _profile.guardianName);
    _guardContactCtrl = TextEditingController(text: _profile.guardianContact);

    // Auto-derive semester when reg no changes
    _regNoCtrl.addListener(() {
      if (_isEditing) {
        final derived = StudentProfile.deriveSemester(_regNoCtrl.text);
        if (derived.isNotEmpty) _semCtrl.text = derived;
      }
    });

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    for (final c in [
      _nameCtrl, _regNoCtrl, _rollCtrl, _semCtrl,
      _contactCtrl, _emailCtrl, _guardNameCtrl, _guardContactCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────
  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty)         return 'Full name is required.';
    if (_regNoCtrl.text.trim().isEmpty)        return 'Registration number is required.';
    if (_rollCtrl.text.trim().isEmpty)         return 'Roll number is required.';
    if (_semCtrl.text.trim().isEmpty)          return 'Semester is required.';
    if (_contactCtrl.text.trim().length != 10) return 'Enter a valid 10-digit contact number.';
    if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.\w{2,}$')
        .hasMatch(_emailCtrl.text.trim()))      return 'Enter a valid email address.';
    if (_guardNameCtrl.text.trim().isEmpty)    return 'Guardian name is required.';
    if (_guardContactCtrl.text.trim().length != 10)
                                               return 'Enter a valid guardian contact number.';
    return null;
  }

  Future<void> _handleSave() async {
    final err = _validate();
    if (err != null) {
      _snack(err);
      return;
    }
    setState(() => _isSaving = true);
    // TODO: await ApiService.updateStudentProfile(...)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    _profile
      ..name                = _nameCtrl.text.trim()
      ..registrationNumber  = _regNoCtrl.text.trim()
      ..rollNumber          = _rollCtrl.text.trim()
      ..semester            = _semCtrl.text.trim()
      ..contactNumber       = _contactCtrl.text.trim()
      ..email               = _emailCtrl.text.trim()
      ..guardianName        = _guardNameCtrl.text.trim()
      ..guardianContact     = _guardContactCtrl.text.trim();
    setState(() { _isSaving = false; _isEditing = false; });
    await showProfileUpdatedDialog(context, _accent);
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: AppTheme.dmSans(fontSize: 13, color: Colors.white))),
        ]),
        backgroundColor: AppTheme.accentPink.withOpacity(0.92),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ));
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final initials = _profile.name.isNotEmpty
        ? _profile.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'ST';

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _buildTopBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(children: [
                    // ── Avatar + Edit button ──────────────────
                    _buildAvatarSection(initials),
                    const SizedBox(height: 24),

                    // ── Student Details ───────────────────────
                    _buildCard(children: [
                      ProfileSectionHeader(
                          title: 'Student Details',
                          accentColor: _accent,
                          icon: Icons.school_rounded),
                      _field(_nameCtrl, 'Full Name',
                          'e.g. Aryan Sharma', Icons.person_outline_rounded),
                      const SizedBox(height: 14),
                      _field(_regNoCtrl, 'Registration Number',
                          'e.g. 2301105277', Icons.badge_outlined),
                      const SizedBox(height: 14),
                      _field(_rollCtrl, 'Roll Number',
                          'e.g. 52', Icons.format_list_numbered_rounded),
                      const SizedBox(height: 14),
                      _field(_semCtrl, 'Semester',
                          'Auto-calculated', Icons.timeline_rounded),
                    ]),
                    const SizedBox(height: 14),

                    // ── Contact Details ───────────────────────
                    _buildCard(children: [
                      ProfileSectionHeader(
                          title: 'Contact Details',
                          accentColor: _accent,
                          icon: Icons.contact_phone_outlined),
                      PhoneField(
                          controller: _contactCtrl,
                          label: 'Contact Number',
                          accentColor: _accent,
                          enabled: _isEditing),
                      const SizedBox(height: 14),
                      ProfileGlassField(
                          controller: _emailCtrl,
                          label: 'Email Address',
                          hint: 'e.g. John23@gmail.com',
                          icon: Icons.email_outlined,
                          accentColor: _accent,
                          enabled: _isEditing,
                          keyboardType: TextInputType.emailAddress),
                    ]),
                    const SizedBox(height: 14),

                    // ── Guardian Details ──────────────────────
                    _buildCard(children: [
                      ProfileSectionHeader(
                          title: 'Guardian Details',
                          accentColor: _accent,
                          icon: Icons.family_restroom_rounded),
                      _field(_guardNameCtrl, "Guardian's Name",
                          'e.g. Mr. Sharma', Icons.person_2_outlined),
                      const SizedBox(height: 14),
                      PhoneField(
                          controller: _guardContactCtrl,
                          label: "Guardian's Contact",
                          accentColor: _accent,
                          enabled: _isEditing),
                    ]),
                    const SizedBox(height: 24),

                    // ── Save button ───────────────────────────
                    if (_isEditing)
                      ProfileActionButton(
                          label: 'Save Changes',
                          icon: Icons.save_rounded,
                          accent: _accent,
                          onTap: _handleSave,
                          loading: _isSaving),
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _glassBtn(
              Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textSecondary, size: 17)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text('My Profile',
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildAvatarSection(String initials) {
    return Column(children: [
      ProfileAvatar(
        initials: initials,
        accentColor: _accent,
        imagePath: _profile.profileImagePath,
        isEditing: _isEditing,
        onEditTap: () async {
          final path = await pickProfileImage();
          if (path != null) setState(() => _profile.profileImagePath = path);
        },
      ),
      const SizedBox(height: 14),
      Text(_profile.name,
          style: AppTheme.sora(fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      const RoleBadge('STUDENT'),
      const SizedBox(height: 16),
      SizedBox(
        width: 140,
        child: ProfileActionButton(
          label: _isEditing ? 'Cancel' : 'Edit Profile',
          icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
          accent: _isEditing ? AppTheme.accentPink : _accent,
          onTap: () {
            if (_isEditing) {
              // Reset fields
              _nameCtrl.text         = _profile.name;
              _regNoCtrl.text        = _profile.registrationNumber;
              _rollCtrl.text         = _profile.rollNumber;
              _semCtrl.text          = _profile.semester;
              _contactCtrl.text      = _profile.contactNumber;
              _emailCtrl.text        = _profile.email;
              _guardNameCtrl.text    = _profile.guardianName;
              _guardContactCtrl.text = _profile.guardianContact;
            }
            setState(() => _isEditing = !_isEditing);
          },
        ),
      ),
    ]);
  }

  Widget _buildCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary.withOpacity(0.68),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.10), width: 1.2),
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, String hint,
      IconData icon) {
    return ProfileGlassField(
        controller: ctrl,
        label: label,
        hint: hint,
        icon: icon,
        accentColor: _accent,
        enabled: _isEditing);
  }

  Widget _glassBtn(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.14)),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}