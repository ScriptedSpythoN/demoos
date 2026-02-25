// lib/widgets/dashboard_top_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The three-point top bar used on all dashboard home tabs.
///
/// Left  → hamburger (opens scaffold drawer)
/// Center → app logo / wordmark
/// Right  → notification bell with badge
class DashboardTopBar extends StatelessWidget {
  final Color accentColor;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const DashboardTopBar({
    super.key,
    required this.accentColor,
    this.notificationCount = 0,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Hamburger ────────────────────────────────────────
            _GlassIconButton(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HamburgerLine(),
                  const SizedBox(height: 4),
                  _HamburgerLine(width: 14),
                  const SizedBox(height: 4),
                  _HamburgerLine(),
                ],
              ),
            ),

            // ── Logo (center) ────────────────────────────────────
            Expanded(
              child: Center(
                child: _AppLogo(accentColor: accentColor),
              ),
            ),

            // ── Notification bell ────────────────────────────────
            _GlassIconButton(
              onTap: onNotificationTap ??
                  () => _showNotificationSheet(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.textPrimary,
                    size: 22,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.red.shade500,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            notificationCount > 9
                                ? '9+'
                                : '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationSheet(
        notificationCount: notificationCount,
        accentColor: accentColor,
      ),
    );
  }
}

// ── Glassmorphic icon button ──────────────────────────────────────
class _GlassIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassIconButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.70)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

// ── Three hamburger lines ─────────────────────────────────────────
class _HamburgerLine extends StatelessWidget {
  final double width;
  const _HamburgerLine({this.width = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      decoration: BoxDecoration(
        color: AppTheme.textPrimary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── App logo / wordmark ───────────────────────────────────────────
class _AppLogo extends StatelessWidget {
  final Color accentColor;
  const _AppLogo({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accentColor, accentColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.30),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.school_rounded,
                color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'EduFlow',
          style: AppTheme.sora(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Notification bottom sheet ─────────────────────────────────────
class _NotificationSheet extends StatelessWidget {
  final int notificationCount;
  final Color accentColor;

  const _NotificationSheet({
    required this.notificationCount,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      _NotifData(
        icon: Icons.event_note_rounded,
        title: 'Exam Schedule Released',
        body: 'Mid-semester exam timetable is now available.',
        time: '2 hrs ago',
        color: Colors.red.shade400,
      ),
      _NotifData(
        icon: Icons.medical_services_rounded,
        title: 'Medical Request Update',
        body: 'Your leave request has been reviewed.',
        time: 'Yesterday',
        color: Colors.orange.shade400,
      ),
      _NotifData(
        icon: Icons.campaign_rounded,
        title: 'Holiday Notice',
        body: 'College closed on 26th January.',
        time: '3 days ago',
        color: Colors.blue.shade400,
      ),
    ];

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Notifications',
                      style: AppTheme.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary),
                    ),
                    const Spacer(),
                    if (notificationCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$notificationCount new',
                          style: AppTheme.dmSans(
                            fontSize: 11,
                            color: Colors.red.shade500,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 320,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: mockNotifications.length,
                  itemBuilder: (_, i) =>
                      _buildNotifTile(mockNotifications[i]),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifTile(_NotifData n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: n.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: n.color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: n.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(n.icon, color: n.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.title,
                    style: AppTheme.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 3),
                Text(n.body,
                    style: AppTheme.dmSans(
                        fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(n.time,
                    style: AppTheme.dmSans(
                        fontSize: 10, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifData {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final Color color;

  const _NotifData({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    required this.color,
  });
}