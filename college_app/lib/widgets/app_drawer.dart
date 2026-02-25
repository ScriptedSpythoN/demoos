// lib/widgets/app_drawer.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Role-aware slide-in drawer matching the design in the screenshot.
/// Pass [userName], [userId], [role] ('STUDENT' | 'TEACHER' | 'HOD'),
/// [accentColor], and an [onLogout] callback.
class AppDrawer extends StatelessWidget {
  final String userName;
  final String userId;
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
      case 'TEACHER':
        return 'FACULTY';
      case 'HOD':
        return 'HOD';
      default:
        return 'STUDENT';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      width: MediaQuery.of(context).size.width * 0.78,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF0F4FB), // light blue-grey matching screenshot
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          onTap: () {
                            Navigator.pop(context);
                            // Navigate to profile tab (tab index 3)
                            final state = context
                                .findAncestorStateOfType<_DrawerHostState>();
                            state?.switchTab(3);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.info_outline_rounded,
                          label: 'Know About the Dept.',
                          onTap: () {
                            Navigator.pop(context);
                            _showComingSoon(context, 'Know About the Dept.');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          onTap: () {
                            Navigator.pop(context);
                            _showComingSoon(context, 'Settings');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.share_outlined,
                          label: 'Share App',
                          onTap: () {
                            Navigator.pop(context);
                            _shareApp(context);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.star_border_rounded,
                          label: 'Rate Us',
                          onTap: () {
                            Navigator.pop(context);
                            _showComingSoon(context, 'Rate Us');
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.groups_outlined,
                          label: 'About Us',
                          onTap: () {
                            Navigator.pop(context);
                            _showAboutDialog(context);
                          },
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.help_outline_rounded,
                          label: 'Help',
                          onTap: () {
                            Navigator.pop(context);
                            _showComingSoon(context, 'Help');
                          },
                        ),
                        const SizedBox(height: 8),
                        Divider(
                          color: Colors.grey.withOpacity(0.25),
                          thickness: 1,
                        ),
                        const SizedBox(height: 8),
                        _buildLogoutItem(context),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      'EduFlow v1.0.0',
                      style: AppTheme.dmSans(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header: avatar card ────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.7)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.30),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userName,
            style: AppTheme.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.textSecondary.withOpacity(0.40),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _roleLabel,
              style: AppTheme.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic menu item ──────────────────────────────────────────
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: AppTheme.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Log out item (red) ─────────────────────────────────────────
  Widget _buildLogoutItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
            onLogout();
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    size: 19,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Log Out',
                    style: AppTheme.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming Soon'),
        backgroundColor: AppTheme.accentBlue.withOpacity(0.90),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share feature — Coming Soon'),
        backgroundColor: AppTheme.accentTeal.withOpacity(0.90),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          'About EduFlow',
          style: AppTheme.sora(
              fontSize: 17, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'EduFlow v1.0.0\n\nA smart college management platform for students, faculty, and administration.\n\n© 2025 EduFlow Team',
          style: AppTheme.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.accentBlue,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

/// Marker interface — used only for Profile tab navigation shortcut.
/// Your dashboard State classes do NOT need to implement this;
/// the drawer falls back gracefully if it can't find the ancestor.
abstract class _DrawerHostState extends State<StatefulWidget> {
  void switchTab(int index);
}