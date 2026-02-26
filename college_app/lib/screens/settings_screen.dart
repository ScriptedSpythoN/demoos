// lib/screens/settings_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_widgets.dart';

// ─────────────────────────────────────────────────────────────────
//  Settings Root Screen
// ─────────────────────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(children: [
                  _sectionHeader('Privacy & Security', Icons.shield_outlined),
                  const SizedBox(height: 10),
                  _buildCard(children: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => Navigator.push(
                        context,
                        AppTheme.slideRoute(const SettingsChangePasswordScreen()),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  _sectionHeader('App', Icons.settings_outlined),
                  const SizedBox(height: 10),
                  _buildCard(children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage notification preferences',
                      onTap: () => _comingSoon(context),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: Icons.language_outlined,
                      title: 'Language',
                      subtitle: 'English (default)',
                      onTap: () => _comingSoon(context),
                    ),
                    _divider(),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App Version',
                      subtitle: 'EduFlow v1.0.0',
                      onTap: null,
                      showArrow: false,
                    ),
                  ]),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Coming Soon',
          style: AppTheme.dmSans(fontSize: 13, color: Colors.white)),
      backgroundColor: AppTheme.accentBlue.withOpacity(0.92),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ));
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _glassBtn(Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textSecondary, size: 17)),
        ),
        const SizedBox(width: 14),
        Text('Settings',
            style:
                AppTheme.sora(fontSize: 17, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: AppTheme.textMuted, size: 15),
      const SizedBox(width: 8),
      Text(title.toUpperCase(),
          style: AppTheme.dmSans(
              fontSize: 11,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8)),
    ]);
  }

  Widget _buildCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSecondary.withOpacity(0.68),
            borderRadius: BorderRadius.circular(18),
            border:
                Border.all(color: Colors.white.withOpacity(0.10), width: 1.2),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _divider() => Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withOpacity(0.06));

  Widget _glassBtn(Widget child) => ClipRRect(
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
            child: Center(child: child),
          ),
        ),
      );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(icon, color: AppTheme.accentBlue, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: AppTheme.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: AppTheme.dmSans(
                        fontSize: 12, color: AppTheme.textMuted)),
              ]),
            ),
            if (showArrow)
              Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted, size: 18),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Change Password Screen (Settings flow)
// ─────────────────────────────────────────────────────────────────
class SettingsChangePasswordScreen extends StatefulWidget {
  const SettingsChangePasswordScreen({super.key});

  @override
  State<SettingsChangePasswordScreen> createState() => _SettingsChangePasswordScreenState();
}

class _SettingsChangePasswordScreenState extends State<SettingsChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _saving = false;

  late AnimationController _entryCtrl;
  late Animation<double> _fade;

  Color get _accent {
    switch (ApiService.userRole) {
      case 'TEACHER': return AppTheme.accentTeal;
      case 'HOD':     return AppTheme.accentViolet;
      default:        return AppTheme.accentBlue;
    }
  }

  // Password rule checks
  bool get _hasLen     => _newCtrl.text.length >= 8;
  bool get _hasUpper   => _newCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber  => _newCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _newCtrl.text.contains(
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]'));
  bool get _passValid  => _hasLen && _hasUpper && _hasNumber && _hasSpecial;

  int get _strength {
    int s = 0;
    if (_hasLen)     s++;
    if (_hasUpper)   s++;
    if (_hasNumber)  s++;
    if (_hasSpecial) s++;
    return s;
  }

  Color get _strengthColor {
    switch (_strength) {
      case 1: return AppTheme.accentPink;
      case 2: return AppTheme.accentAmber;
      case 3: return const Color(0xFF60C8F5);
      case 4: return AppTheme.accentTeal;
      default: return AppTheme.textMuted;
    }
  }

  @override
  void initState() {
    super.initState();
    _newCtrl.addListener(() => setState(() {}));
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_currentCtrl.text.isEmpty ||
        _newCtrl.text.isEmpty ||
        _confirmCtrl.text.isEmpty) {
      _snack('All fields are required.', isError: true);
      return;
    }
    if (!_passValid) {
      _snack('Password must be 8+ chars with uppercase, number & special char.',
          isError: true);
      return;
    }
    if (_newCtrl.text != _confirmCtrl.text) {
      _snack('New password and confirm password do not match.',
          isError: true);
      return;
    }

    setState(() => _saving = true);
    // TODO: await ApiService.changePassword(current, newPass)
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _saving = false);

    // Show success dialog — stay on same screen
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgSecondary,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withOpacity(0.12),
              border:
                  Border.all(color: _accent.withOpacity(0.40), width: 1.5),
            ),
            child: Icon(Icons.check_circle_rounded,
                color: _accent, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Password Changed\nSuccessfully',
              textAlign: TextAlign.center,
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _accent.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog, stay on screen
                _currentCtrl.clear();
                _newCtrl.clear();
                _confirmCtrl.clear();
              },
              child: Text('OK',
                  style: AppTheme.dmSans(
                      fontSize: 14,
                      color: _accent,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white, size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg,
              style: AppTheme.dmSans(fontSize: 13, color: Colors.white))),
        ]),
        backgroundColor: isError
            ? AppTheme.accentPink.withOpacity(0.92)
            : AppTheme.accentTeal.withOpacity(0.92),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ));
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.bgSecondary.withOpacity(0.68),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.10),
                              width: 1.2),
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          _sectionHeader('Change Password',
                              Icons.lock_reset_rounded, _accent),
                          const SizedBox(height: 16),

                          // Current password
                          ProfileGlassField(
                              controller: _currentCtrl,
                              label: 'Current Password',
                              hint: 'e.g. John@2018',
                              icon: Icons.lock_outline_rounded,
                              accentColor: _accent,
                              isPassword: true),
                          const SizedBox(height: 14),

                          // New password
                          ProfileGlassField(
                              controller: _newCtrl,
                              label: 'New Password',
                              hint: 'e.g. John@2018',
                              icon: Icons.lock_reset_rounded,
                              accentColor: _accent,
                              isPassword: true),

                          // Strength bar
                          if (_newCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _strengthBar(),
                          ],
                          const SizedBox(height: 14),

                          // Confirm password
                          ProfileGlassField(
                              controller: _confirmCtrl,
                              label: 'Confirm Password',
                              hint: 'e.g. John@2018',
                              icon: Icons.lock_person_outlined,
                              accentColor: _accent,
                              isPassword: true),
                          const SizedBox(height: 14),

                          // Rules chips
                          _rulesRow(),
                          const SizedBox(height: 8),

                          // Subtle rule info text
                          Text(
                            'Must be 8 characters, include 1 special character, '
                            '1 capital letter & 1 number',
                            style: AppTheme.dmSans(
                                fontSize: 11,
                                color: AppTheme.textMuted.withOpacity(0.65),
                                height: 1.5),
                          ),
                          const SizedBox(height: 24),

                          // Submit
                          ProfileActionButton(
                              label: 'Submit',
                              icon: Icons.check_rounded,
                              accent: _accent,
                              onTap: _handleSubmit,
                              loading: _saving),
                        ]),
                      ),
                    ),
                  ),
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
          Text('Change Password',
              style: AppTheme.sora(
                  fontSize: 17, fontWeight: FontWeight.w700)),
        ]),
      );

  Widget _sectionHeader(String title, IconData icon, Color color) =>
      Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: AppTheme.sora(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ]);

  Widget _strengthBar() => Row(children: [
        Expanded(
          child: Row(
            children: List.generate(4, (i) {
              final filled = i < _strength;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: filled
                        ? _strengthColor
                        : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                                color: _strengthColor.withOpacity(0.40),
                                blurRadius: 6)
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          ['', 'Weak', 'Fair', 'Good', 'Strong'][_strength],
          style: AppTheme.dmSans(
              fontSize: 11,
              color: _strengthColor,
              fontWeight: FontWeight.w700),
        ),
      ]);

  Widget _rulesRow() => Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _chip('8+ chars', _hasLen),
          _chip('Uppercase', _hasUpper),
          _chip('Number', _hasNumber),
          _chip('Special char', _hasSpecial),
        ],
      );

  Widget _chip(String label, bool met) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: met
              ? AppTheme.accentTeal.withOpacity(0.12)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: met
                ? AppTheme.accentTeal.withOpacity(0.40)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            met
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: met
                ? AppTheme.accentTeal
                : AppTheme.textMuted.withOpacity(0.50),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(label,
              style: AppTheme.dmSans(
                  fontSize: 11,
                  color: met
                      ? AppTheme.accentTeal
                      : AppTheme.textMuted.withOpacity(0.55),
                  fontWeight: FontWeight.w500)),
        ]),
      );

  Widget _glassBtn(Widget child) => ClipRRect(
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
            child: Center(child: child),
          ),
        ),
      );
}