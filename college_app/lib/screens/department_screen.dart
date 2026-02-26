// lib/screens/department_screen.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../theme/app_theme.dart';

class DepartmentScreen extends StatelessWidget {
  const DepartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profiles = ProfileStore().sortedForDepartment();

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _buildTopBar(context),
            Expanded(
              child: profiles.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: profiles.length,
                      itemBuilder: (_, i) {
                        final p = profiles[i];
                        if (p is HodProfile) return _FacultyCard(profile: p);
                        if (p is FacultyProfile) return _FacultyCard(profile: p);
                        return const SizedBox.shrink();
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textSecondary, size: 17),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Know About The Department',
                style: AppTheme.sora(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            Text('Faculty & HOD directory',
                style: AppTheme.dmSans(
                    fontSize: 12, color: AppTheme.textMuted)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.groups_outlined, size: 56, color: AppTheme.textMuted),
        const SizedBox(height: 16),
        Text('No faculty profiles yet',
            style: AppTheme.sora(
                fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          'Faculty and HOD profiles will appear here\nonce they complete their profiles.',
          textAlign: TextAlign.center,
          style: AppTheme.dmSans(
              fontSize: 13,
              color: AppTheme.textMuted,
              height: 1.5),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _FacultyCard extends StatelessWidget {
  final dynamic profile; // HodProfile | FacultyProfile

  const _FacultyCard({required this.profile});

  bool get _isHod => profile is HodProfile;

  String get _name => _isHod
      ? (profile as HodProfile).name
      : (profile as FacultyProfile).name;

  String get _roleLabel =>
      _isHod ? 'HOD' : (profile as FacultyProfile).role.label;

  String get _education => _isHod
      ? (profile as HodProfile).education
      : (profile as FacultyProfile).education;

  String get _expertise => _isHod
      ? (profile as HodProfile).fieldsOfExpertise
      : (profile as FacultyProfile).fieldsOfExpertise;

  String get _courses => _isHod
      ? (profile as HodProfile).coursesTypicallyTaught
      : (profile as FacultyProfile).coursesTypicallyTaught;

  String get _research => _isHod
      ? (profile as HodProfile).researchAndPublications
      : (profile as FacultyProfile).researchAndPublications;

  String? get _imagePath => _isHod
      ? (profile as HodProfile).profileImagePath
      : (profile as FacultyProfile).profileImagePath;

  Color get _accent => _isHod
      ? AppTheme.accentViolet
      : (profile as FacultyProfile).role == FacultyRole.professor
          ? AppTheme.accentBlue
          : (profile as FacultyProfile).role == FacultyRole.assistantProfessor
              ? AppTheme.accentTeal
              : AppTheme.accentAmber;

  String get _initials {
    final parts = _name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return _name.isNotEmpty ? _name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgSecondary.withOpacity(0.68),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: _accent.withOpacity(_isHod ? 0.25 : 0.12),
                  width: 1.2),
              boxShadow: _isHod
                  ? [
                      BoxShadow(
                          color: _accent.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4))
                    ]
                  : null,
            ),
            child: Column(children: [
              // ── HOD banner ──────────────────────────────────
              if (_isHod)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.12),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: Row(children: [
                    Icon(Icons.admin_panel_settings_rounded,
                        color: _accent, size: 14),
                    const SizedBox(width: 6),
                    Text('Head of Department',
                        style: AppTheme.dmSans(
                            fontSize: 11,
                            color: _accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ]),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  // ── Header row ───────────────────────────────
                  Row(children: [
                    // Avatar
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [
                          _accent,
                          _accent.withOpacity(0.65),
                        ]),
                        boxShadow: [
                          BoxShadow(
                              color: _accent.withOpacity(0.30),
                              blurRadius: 12)
                        ],
                        border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                            width: 2),
                      ),
                      child: _imagePath != null
                          ? ClipOval(
                              child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _initCircle()))
                          : _initCircle(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(_name,
                            style: AppTheme.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _accent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _accent.withOpacity(0.25)),
                          ),
                          child: Text(_roleLabel,
                              style: AppTheme.dmSans(
                                  fontSize: 10,
                                  color: _accent,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3)),
                        ),
                      ]),
                    ),
                  ]),
                  if (_education.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _detail(Icons.school_outlined, 'Education', _education),
                  ],
                  if (_expertise.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _detail(Icons.psychology_outlined,
                        'Fields of Expertise', _expertise),
                  ],
                  if (_courses.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _detail(Icons.class_outlined,
                        'Courses Typically Taught', _courses),
                  ],
                  if (_research.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _detail(Icons.article_outlined,
                        'Research & Publications', _research),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _initCircle() => Center(
        child: Text(_initials,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
      );

  Widget _detail(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: _accent.withOpacity(0.70), size: 15),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: AppTheme.dmSans(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTheme.dmSans(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.4)),
        ]),
      ),
    ]);
  }
}