// lib/screens/simple_screen.dart
//
// Reusable screen used by Share App, Rate Us, and Help.
// Pass [title] and [bodyText] from the drawer.
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SimpleComingSoonScreen extends StatelessWidget {
  final String title;
  final String bodyText;

  const SimpleComingSoonScreen({
    super.key,
    required this.title,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _topBar(context),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppTheme.accentBlue.withOpacity(0.20)),
                        ),
                        child: Icon(
                          _iconForTitle(title),
                          color: AppTheme.accentBlue,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        bodyText,
                        textAlign: TextAlign.center,
                        style: AppTheme.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  IconData _iconForTitle(String t) {
    if (t.toLowerCase().contains('share')) return Icons.share_outlined;
    if (t.toLowerCase().contains('rate'))  return Icons.star_outline_rounded;
    return Icons.help_outline_rounded;
  }

  Widget _topBar(BuildContext context) {
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
        Text(title,
            style: AppTheme.sora(fontSize: 17, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}