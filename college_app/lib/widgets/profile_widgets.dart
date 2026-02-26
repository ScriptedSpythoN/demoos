// lib/widgets/profile_widgets.dart
//
// Reusable widgets shared by StudentProfileScreen, FacultyProfileScreen,
// and HodProfileScreen. Import this file in each profile screen.

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
//  Profile Avatar with optional camera overlay
// ─────────────────────────────────────────────────────────────────
class ProfileAvatar extends StatelessWidget {
  final String? imagePath;
  final String initials;
  final Color accentColor;
  final bool isEditing;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key,
    required this.initials,
    required this.accentColor,
    this.imagePath,
    this.isEditing = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withOpacity(0.65)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                  color: accentColor.withOpacity(0.35), blurRadius: 20),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 3),
          ),
          child: imagePath != null
              ? ClipOval(
                  child: Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _initText(),
                  ),
                )
              : _initText(),
        ),
        if (isEditing)
          GestureDetector(
            onTap: onEditTap,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.20), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: accentColor.withOpacity(0.40), blurRadius: 8),
                ],
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }

  Widget _initText() => Center(
        child: Text(
          initials,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────
//  Section title bar
// ─────────────────────────────────────────────────────────────────
class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;
  final IconData icon;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 16),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: AppTheme.sora(
                fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
              height: 1,
              color: accentColor.withOpacity(0.15)),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Glass text field for profile forms
// ─────────────────────────────────────────────────────────────────
class ProfileGlassField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color accentColor;
  final bool enabled;
  final bool isPassword;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final int? maxLines;

  const ProfileGlassField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.enabled = true,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixText,
    this.maxLines = 1,
  });

  @override
  State<ProfileGlassField> createState() => _ProfileGlassFieldState();
}

class _ProfileGlassFieldState extends State<ProfileGlassField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusAnim;
  late Animation<double> _border;
  final FocusNode _focus = FocusNode();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _border = CurvedAnimation(parent: _focusAnim, curve: Curves.easeOut);
    _focus.addListener(() =>
        _focus.hasFocus ? _focusAnim.forward() : _focusAnim.reverse());
  }

  @override
  void dispose() {
    _focusAnim.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _border,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(widget.enabled ? 0.08 + 0.05 * _border.value : 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Color.lerp(
                  Colors.white.withOpacity(0.14),
                  widget.accentColor.withOpacity(0.65),
                  _border.value,
                )!,
                width: 1.2 + 0.4 * _border.value,
              ),
              boxShadow: _border.value > 0.1
                  ? [
                      BoxShadow(
                          color: widget.accentColor
                              .withOpacity(0.10 * _border.value),
                          blurRadius: 16),
                    ]
                  : null,
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: widget.enabled,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? _obscure : false,
              inputFormatters: widget.inputFormatters,
              maxLines: widget.isPassword ? 1 : widget.maxLines,
              style: AppTheme.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: widget.enabled
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted),
              cursorColor: widget.accentColor,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                hintStyle: AppTheme.dmSans(
                    fontSize: 13,
                    color: AppTheme.textMuted.withOpacity(0.50),
                    fontStyle: FontStyle.italic),
                labelStyle: AppTheme.dmSans(
                    fontSize: 14,
                    color: AppTheme.textSecondary.withOpacity(0.55)),
                floatingLabelStyle: AppTheme.dmSans(
                    fontSize: 12,
                    color: widget.accentColor,
                    fontWeight: FontWeight.w600),
                prefixIcon: Icon(widget.icon,
                    color: Color.lerp(AppTheme.textMuted,
                        widget.accentColor, _border.value),
                    size: 19),
                prefixText: widget.prefixText,
                prefixStyle: AppTheme.dmSans(
                    fontSize: 15,
                    color: widget.enabled
                        ? AppTheme.textPrimary
                        : AppTheme.textMuted,
                    fontWeight: FontWeight.w500),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted,
                          size: 19,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Role dropdown (Faculty only)
// ─────────────────────────────────────────────────────────────────
class ProfileRoleDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final Color accentColor;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const ProfileRoleDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.accentColor,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(enabled ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: Colors.white.withOpacity(0.14), width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppTheme.bgSecondary,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: enabled ? accentColor : AppTheme.textMuted),
              onChanged: enabled ? onChanged : null,
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Row(children: [
                          Icon(Icons.person_pin_rounded,
                              color: AppTheme.textMuted, size: 18),
                          const SizedBox(width: 10),
                          Text(o,
                              style: AppTheme.dmSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textPrimary)),
                        ]),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Phone field with +91 non-editable prefix
// ─────────────────────────────────────────────────────────────────
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color accentColor;
  final bool enabled;

  const PhoneField({
    super.key,
    required this.controller,
    required this.label,
    required this.accentColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileGlassField(
      controller: controller,
      label: label,
      hint: '10-digit number',
      icon: Icons.phone_outlined,
      accentColor: accentColor,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      prefixText: '+91 ',
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Profile action buttons (Edit / Save)
// ─────────────────────────────────────────────────────────────────
class ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool loading;

  const ProfileActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accent, Color.lerp(accent, Colors.black, 0.22)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
                color: accent.withOpacity(loading ? 0.12 : 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(label,
                      style: AppTheme.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.8)),
                ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Profile Updated dialog
// ─────────────────────────────────────────────────────────────────
Future<void> showProfileUpdatedDialog(
    BuildContext context, Color accentColor) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.bgSecondary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accentColor.withOpacity(0.12),
            border:
                Border.all(color: accentColor.withOpacity(0.40), width: 1.5),
          ),
          child: Icon(Icons.check_circle_rounded,
              color: accentColor, size: 30),
        ),
        const SizedBox(height: 16),
        Text('Profile Updated',
            style: AppTheme.sora(
                fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Your changes have been saved.',
            textAlign: TextAlign.center,
            style: AppTheme.dmSans(
                fontSize: 13, color: AppTheme.textSecondary)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: accentColor.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('OK',
                style: AppTheme.dmSans(
                    fontSize: 14,
                    color: accentColor,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────
//  Image picker helper
// ─────────────────────────────────────────────────────────────────
Future<String?> pickProfileImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
      source: ImageSource.gallery, imageQuality: 80);
  return picked?.path;
}