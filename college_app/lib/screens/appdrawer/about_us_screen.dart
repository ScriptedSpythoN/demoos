// lib/screens/about_us_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: AppBackground(
        child: SafeArea(
          child: Column(children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Main heading ─────────────────────────
                    Text(
                      'Introducing Team HitTryDo',
                      textAlign: TextAlign.center,
                      style: AppTheme.sora(
                          fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 32),

                    // ── Leader ───────────────────────────────
                    _buildSectionLabel('Leader'),
                    const SizedBox(height: 12),
                    _buildNameRow('Shalini Behera', isLeader: true),
                    const SizedBox(height: 28),

                    // ── Divider ──────────────────────────────
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.08),
                    ),
                    const SizedBox(height: 28),

                    // ── Team members ─────────────────────────
                    _buildSectionLabel('Team Members'),
                    const SizedBox(height: 12),
                    _buildNameRow('Roshan Maharana'),
                    const SizedBox(height: 14),
                    _buildNameRow('Sriram Sahoo'),
                    const SizedBox(height: 14),
                    _buildNameRow('Ashutosh Dash'),
                    const SizedBox(height: 14),
                    _buildNameRow('Subham Samaddar'),
                  ],
                ),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.14)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppTheme.textSecondary, size: 17),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          'About Us',
          style: AppTheme.sora(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: AppTheme.dmSans(
          fontSize: 11,
          color: AppTheme.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNameRow(String name, {bool isLeader = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLeader
                ? AppTheme.accentViolet
                : AppTheme.textMuted.withOpacity(0.50),
          ),
        ),
        const SizedBox(width: 14),
        Text(
          name,
          style: AppTheme.dmSans(
            fontSize: 16,
            fontWeight:
                isLeader ? FontWeight.w700 : FontWeight.w500,
            color: isLeader
                ? AppTheme.textPrimary
                : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}