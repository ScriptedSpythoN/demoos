// lib/screens/faculty_profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_widgets.dart';

class FacultyProfileScreen extends StatefulWidget {
  const FacultyProfileScreen({super.key});

  @override
  State<FacultyProfileScreen> createState() => _FacultyProfileScreenState();
}

class _FacultyProfileScreenState extends State<FacultyProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isSaving  = false;

  late FacultyProfile _profile;
  String _selectedRole = FacultyRole.professor.label;

  late TextEditingController _nameCtrl;
  late TextEditingController _idCtrl;
  late TextEditingController _contactCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _educationCtrl;
  late TextEditingController _expertiseCtrl;
  late TextEditingController _coursesCtrl;
  late TextEditingController _researchCtrl;

  late AnimationController _entryCtrl;
  late Animation<double> _fade;

  static const _accent = AppTheme.accentTeal;

  static const _roleOptions = [
    'Professor',
    'Assistant Professor',
    'Guest Faculty',
  ];

  @override
  void initState() {
    super.initState();
    _profile = FacultyProfile(
      name: ApiService.currentUserName ?? 'Faculty',
      facultyId: ApiService.currentUserId ?? '',
      role: FacultyRole.professor,
    );
    _selectedRole = _profile.role.label;

    _nameCtrl     = TextEditingController(text: _profile.name);
    _idCtrl       = TextEditingController(text: _profile.facultyId);
    _contactCtrl  = TextEditingController(text: _profile.contactNumber);
    _emailCtrl    = TextEditingController(text: _profile.email);
    _educationCtrl= TextEditingController(text: _profile.education);
    _expertiseCtrl= TextEditingController(text: _profile.fieldsOfExpertise);
    _coursesCtrl  = TextEditingController(text: _profile.coursesTypicallyTaught);
    _researchCtrl = TextEditingController(text: _profile.researchAndPublications);

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    for (final c in [
      _nameCtrl, _idCtrl, _contactCtrl, _emailCtrl,
      _educationCtrl, _expertiseCtrl, _coursesCtrl, _researchCtrl
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty)         return 'Name is required.';
    if (_idCtrl.text.trim().isEmpty)           return 'Faculty ID is required.';
    if (_contactCtrl.text.trim().length != 10) return 'Enter a valid 10-digit contact number.';
    if (!RegExp(r'^[\w.+\-]+@[\w\-]+\.\w{2,}$')
        .hasMatch(_emailCtrl.text.trim()))      return 'Enter a valid email address.';
    if (_educationCtrl.text.trim().isEmpty)    return 'Education is required.';
    if (_expertiseCtrl.text.trim().isEmpty)    return 'Fields of expertise are required.';
    if (_coursesCtrl.text.trim().isEmpty)      return 'Courses taught is required.';
    if (_researchCtrl.text.trim().isEmpty)     return 'Research & publications field is required.';
    return null;
  }

  Future<void> _handleSave() async {
    final err = _validate();
    if (err != null) { _snack(err); return; }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    _profile
      ..name                   = _nameCtrl.text.trim()
      ..facultyId              = _idCtrl.text.trim()
      ..role                   = FacultyRoleExt.fromLabel(_selectedRole)
      ..contactNumber          = _contactCtrl.text.trim()
      ..email                  = _emailCtrl.text.trim()
      ..education              = _educationCtrl.text.trim()
      ..fieldsOfExpertise      = _expertiseCtrl.text.trim()
      ..coursesTypicallyTaught = _coursesCtrl.text.trim()
      ..researchAndPublications= _researchCtrl.text.trim();

    // Push to shared store so Department screen can read it
    ProfileStore().upsertFaculty(_profile);

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

  @override
  Widget build(BuildContext context) {
    final initials = _profile.name.isNotEmpty
        ? _profile.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : 'FA';

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _topBar(),
            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(children: [
                    _avatarSection(initials),
                    const SizedBox(height: 24),
                    _buildCard(children: [
                      ProfileSectionHeader(
                          title: 'Faculty Details',
                          accentColor: _accent,
                          icon: Icons.person_rounded),
                      _f(_nameCtrl, 'Name', 'e.g. Dr. Priya Gupta',
                          Icons.person_outline_rounded),
                      const SizedBox(height: 14),
                      _f(_idCtrl, 'Faculty ID', 'e.g. FAC-001',
                          Icons.badge_outlined),
                      const SizedBox(height: 14),
                      // Role dropdown
                      Text('Role',
                          style: AppTheme.dmSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),
                      ProfileRoleDropdown(
                          value: _selectedRole,
                          options: _roleOptions,
                          accentColor: _accent,
                          enabled: _isEditing,
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedRole = v);
                          }),
                      const SizedBox(height: 14),
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
                    _buildCard(children: [
                      ProfileSectionHeader(
                          title: 'Academic Details',
                          accentColor: _accent,
                          icon: Icons.menu_book_rounded),
                      _f(_educationCtrl, 'Education',
                          'e.g. Ph.D Computer Science', Icons.school_outlined),
                      const SizedBox(height: 14),
                      _fMulti(_expertiseCtrl, 'Fields of Expertise',
                          'e.g. Machine Learning, Data Science',
                          Icons.psychology_outlined),
                      const SizedBox(height: 14),
                      _fMulti(_coursesCtrl, 'Courses Typically Taught',
                          'e.g. OS, CN, ML', Icons.class_outlined),
                      const SizedBox(height: 14),
                      _fMulti(_researchCtrl, 'Research & Publications',
                          'e.g. IEEE papers, journals',
                          Icons.article_outlined),
                    ]),
                    const SizedBox(height: 24),
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

  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: _glassBtn(Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textSecondary, size: 17)),
          ),
          const SizedBox(width: 14),
          Text('My Profile',
              style: AppTheme.sora(fontSize: 17, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _avatarSection(String initials) {
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
      const RoleBadge('TEACHER'),
      const SizedBox(height: 16),
      SizedBox(
        width: 140,
        child: ProfileActionButton(
          label: _isEditing ? 'Cancel' : 'Edit Profile',
          icon: _isEditing ? Icons.close_rounded : Icons.edit_rounded,
          accent: _isEditing ? AppTheme.accentPink : _accent,
          onTap: () {
            if (_isEditing) {
              _nameCtrl.text     = _profile.name;
              _idCtrl.text       = _profile.facultyId;
              _selectedRole      = _profile.role.label;
              _contactCtrl.text  = _profile.contactNumber;
              _emailCtrl.text    = _profile.email;
              _educationCtrl.text= _profile.education;
              _expertiseCtrl.text= _profile.fieldsOfExpertise;
              _coursesCtrl.text  = _profile.coursesTypicallyTaught;
              _researchCtrl.text = _profile.researchAndPublications;
            }
            setState(() => _isEditing = !_isEditing);
          },
        ),
      ),
    ]);
  }

  Widget _buildCard({required List<Widget> children}) => ClipRRect(
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

  Widget _f(TextEditingController c, String label, String hint, IconData icon) =>
      ProfileGlassField(
          controller: c,
          label: label,
          hint: hint,
          icon: icon,
          accentColor: _accent,
          enabled: _isEditing);

  Widget _fMulti(TextEditingController c, String label, String hint,
          IconData icon) =>
      ProfileGlassField(
          controller: c,
          label: label,
          hint: hint,
          icon: icon,
          accentColor: _accent,
          enabled: _isEditing,
          maxLines: 3);

  Widget _glassBtn(Widget child) => ClipRRect(
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