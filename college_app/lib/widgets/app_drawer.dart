// lib/widgets/app_drawer.dart
//
// ── REPLACES the previous app_drawer.dart ──
// All menu items now navigate to their proper screens.
// Logout shows confirmation dialog: No (Red) | Yes (Blue).
// Profile → role-specific profile screen.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../screens/about_us_screen.dart';
import '../screens/department_screen.dart';
import '../screens/faculty_profile_screen.dart';
import '../screens/hod_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/simple_screen.dart';
import '../screens/student_profile_screen.dart';

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userId;

  /// 'STUDENT' | 'TEACHER' | 'HOD'
  final String role;
  final Color accentColor;
  final VoidCallback onLogout;

  const AppDrawer({
    super.key,
    required this.userName,
    required this.userId,
    required this.role,
    required this.accentColor,
    required this.onLogout,
  });

  String get _roleLabel {
    switch (role) {
      case 'TEACHER': return 'FACULTY';
      case 'HOD':     return 'HOD';
      default:        return 'STUDENT';
    }
  }

  String get _initials {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return userName.length >= 2
        ? userName.substring(0, 2).toUpperCase()
        : userName.toUpperCase();
  }

  void _openProfile(BuildContext context) {
    Navigator.pop(context);
    Widget screen;
    switch (role) {
      case 'TEACHER':
        screen = const FacultyProfileScreen();
        break;
      case 'HOD':
        screen = const HodProfileScreen();
        break;
      default:
        screen = const StudentProfileScreen();
    }
    Navigator.push(context, AppTheme.slideRoute(screen));
  }

  void _confirmLogout(BuildContext context) {
    // Capture the root navigator BEFORE closing the drawer.
    // Once Navigator.pop() is called below, the drawer's BuildContext
    // becomes deactivated — any Navigator/showDialog call using it after
    // that point throws "Looking up a deactivated widget's ancestor".
    // Using the root navigator's context (rootOverlay) keeps us safe.
    final NavigatorState rootNav = Navigator.of(context, rootNavigator: true);

    // Close the drawer first.
    Navigator.of(context).pop();

    // Now show the dialog using the safe root navigator context.
    showDialog(
      context: rootNav.context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPink.withOpacity(0.10),
              border: Border.all(
                  color: AppTheme.accentPink.withOpacity(0.40),
                  width: 1.5),
            ),
            child: const Icon(Icons.logout_rounded,
                color: AppTheme.accentPink, size: 26),
          ),
          const SizedBox(height: 16),
          Text('Are you sure?',
              style: AppTheme.sora(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(
            'You will be logged out of your account.',
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5),
          ),
          const SizedBox(height: 20),
          Row(children: [
            // No — Red: just close the dialog, stay on dashboard
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(dialogContext).pop(),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.accentPink.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.accentPink.withOpacity(0.40)),
                  ),
                  child: Center(
                    child: Text('No',
                        style: AppTheme.dmSans(
                            fontSize: 14,
                            color: AppTheme.accentPink,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Yes — Blue: close dialog then invoke logout callback
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  onLogout();
                },
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.accentBlue.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Center(
                    child: Text('Yes',
                        style: AppTheme.dmSans(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width * 0.78,
      child: Container(
        color: AppTheme.bgPrimary,
        child: SafeArea(
          child: Column(children: [
            _header(context),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _item(Icons.person_outline_rounded, 'Profile',
                      () => _openProfile(context)),
                  _item(Icons.info_outline_rounded, 'Know About the Dept.',
                      () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        AppTheme.slideRoute(const DepartmentScreen()));
                  }),
                  _item(Icons.settings_outlined, 'Settings', () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        AppTheme.slideRoute(const SettingsScreen()));
                  }),
                  _item(Icons.share_outlined, 'Share App', () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        AppTheme.slideRoute(const SimpleComingSoonScreen(
                            title: 'Share App',
                            bodyText: 'Coming Soon After Launch')));
                  }),
                  _item(Icons.star_border_rounded, 'Rate Us', () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        AppTheme.slideRoute(const SimpleComingSoonScreen(
                            title: 'Rate Us',
                            bodyText: 'Coming Soon After Launch')));
                  }),
                  _item(Icons.groups_outlined, 'About Us', () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        AppTheme.slideRoute(const AboutUsScreen()));
                  }),
                  _item(Icons.help_outline_rounded, 'Help', () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        AppTheme.slideRoute(const SimpleComingSoonScreen(
                            title: 'Help',
                            bodyText: 'Feature Coming Soon')));
                  }),
                  const SizedBox(height: 8),
                  Divider(
                      color: Colors.white.withOpacity(0.08), thickness: 1),
                  const SizedBox(height: 8),
                  _logoutItem(context),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text('EduFlow v1.0.0',
                  style: AppTheme.dmSans(
                      fontSize: 12, color: AppTheme.textMuted)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 76, height: 76,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.7)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: accentColor.withOpacity(0.28), blurRadius: 16),
              ],
            ),
            child: Center(
              child: Text(_initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          GestureDetector(
            onTap: () => _openProfile(context),
            child: Container(
              width: 26, height: 26,
              decoration: BoxDecoration(
                color: AppTheme.bgSecondary,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.12), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.18), blurRadius: 6)
                ],
              ),
              child: Icon(Icons.edit_rounded, size: 13, color: accentColor),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Text(userName,
            style: AppTheme.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.25)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(_roleLabel,
              style: AppTheme.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.2)),
        ),
      ]),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 13),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: accentColor.withOpacity(0.14)),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(label,
                      style: AppTheme.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary))),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppTheme.textMuted),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _logoutItem(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.selectionClick();
          _confirmLogout(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.20)),
              ),
              child:
                  const Icon(Icons.logout_rounded, size: 18, color: Colors.red),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text('Log Out',
                    style: AppTheme.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red))),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: Colors.red),
          ]),
        ),
      ),
    );
  }
}