// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// ─────────────────────────────────────────────────────────────────
//  AppTheme — White/Blue Glassmorphism Design System
//  Visual Reference: Frosted glass panels on white-to-blue gradient
// ─────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  // ── Background gradient stops (white → soft blue → vivid blue) ─
  static const Color bgWhite      = Color(0xFFFFFFFF);
  static const Color bgSoftBlue   = Color(0xFFEAF4FF);
  static const Color bgMidBlue    = Color(0xFFBFDEFF);
  static const Color bgDeepBlue   = Color(0xFF6AADEE);
  static const Color bgVividBlue  = Color(0xFF2B7DE9);

  // ── Legacy aliases (keep backward compat) ──────────────────────
  static const Color bgPrimary   = bgWhite;
  static const Color bgSecondary = bgSoftBlue;
  static const Color bgTertiary  = bgMidBlue;

  // ── Role accents ───────────────────────────────────────────────
  static const Color accentBlue   = Color(0xFF1A6FE8); // Student — vivid blue
  static const Color accentViolet = Color(0xFF7C5CFC); // HOD — indigo-violet
  static const Color accentTeal   = Color(0xFF0EB8A8); // Faculty — teal
  static const Color accentPink   = Color(0xFFEA4C89); // Alerts / Medical
  static const Color accentAmber  = Color(0xFFF5A623); // Warnings / Pending

  // ── Text (dark on light background) ───────────────────────────
  static const Color textPrimary = Color(0xFF0D1B3E);
  static Color get textSecondary => const Color(0xFF0D1B3E).withOpacity(0.55);
  static Color get textMuted     => const Color(0xFF0D1B3E).withOpacity(0.30);

  // ── Glass surface — white frosted panels ──────────────────────
  static Color get glassFill    => const Color(0xFFFFFFFF).withOpacity(0.55);
  static Color get glassFillHi  => const Color(0xFFFFFFFF).withOpacity(0.75);
  static Color get glassBorder  => const Color(0xFFFFFFFF).withOpacity(0.70);
  static Color get glassShadow  => const Color(0xFF2B7DE9).withOpacity(0.08);

  // ── Status colours ─────────────────────────────────────────────
  static const Color statusPending  = Color(0xFFF5A623);
  static const Color statusAccepted = Color(0xFF0EB8A8);
  static const Color statusRejected = Color(0xFFEA4C89);

  // ─────────────────────────────────────────────────────────────
  //  Full-screen background gradient widget
  // ─────────────────────────────────────────────────────────────
  static Widget background({Widget? child}) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFEBF4FF),
          Color(0xFFBDD8FF),
          Color(0xFF89BFFF),
          Color(0xFF4A9EFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.25, 0.55, 0.80, 1.0],
      ),
    ),
    child: child,
  );

  // ─────────────────────────────────────────────────────────────
  //  Role helpers
  // ─────────────────────────────────────────────────────────────
  static Color accentForRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'TEACHER': return accentTeal;
      case 'HOD':     return accentViolet;
      default:        return accentBlue;
    }
  }

  static Color glowForRole(String? role) =>
      accentForRole(role).withOpacity(0.20);

  // ─────────────────────────────────────────────────────────────
  //  BoxDecoration helpers
  // ─────────────────────────────────────────────────────────────
  static BoxDecoration glassCard({
    double radius = 20,
    Color? borderColor,
    Color? glowColor,
    Color? fillColor,
  }) =>
      BoxDecoration(
        color: fillColor ?? const Color(0xFFFFFFFF).withOpacity(0.55),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFFFFF).withOpacity(0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B7DE9).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFFFFFFFF).withOpacity(0.80),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      );

  static BoxDecoration statusBadgeDecor(String status) {
    final c = statusColor(status);
    return BoxDecoration(
      color: c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: c.withOpacity(0.35)),
      boxShadow: [BoxShadow(color: c.withOpacity(0.15), blurRadius: 8)],
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  Status helpers
  // ─────────────────────────────────────────────────────────────
  static Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'ACCEPTED':
        return statusAccepted;
      case 'REJECTED':
        return statusRejected;
      default:
        return statusPending;
    }
  }

  static String statusLabel(String status) {
    final s = status.toLowerCase();
    return s[0].toUpperCase() + s.substring(1);
  }

  // ─────────────────────────────────────────────────────────────
  //  Typography
  // ─────────────────────────────────────────────────────────────
  static TextStyle sora({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textPrimary,
    double letterSpacing = -0.02,
    double? height,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.sora(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );

  static TextStyle dmSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = textPrimary,
    double letterSpacing = 0.0,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  static TextStyle mono({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textPrimary,
    double letterSpacing = 0.0,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );

  // ─────────────────────────────────────────────────────────────
  //  Page transition
  // ─────────────────────────────────────────────────────────────
  static PageRouteBuilder<T> slideRoute<T>(Widget page) =>
      PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: anim,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      );

  // ─────────────────────────────────────────────────────────────
  //  MaterialApp ThemeData — LIGHT theme for white/blue system
  // ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: const ColorScheme(
        brightness:    Brightness.light,
        primary:       accentBlue,
        onPrimary:     Colors.white,
        secondary:     accentViolet,
        onSecondary:   Colors.white,
        tertiary:      accentTeal,
        onTertiary:    Colors.white,
        error:         accentPink,
        onError:       Colors.white,
        surface:       bgSoftBlue,
        onSurface:     textPrimary,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
        displayLarge:   GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w700),
        displayMedium:  GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w700),
        displaySmall:   GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w600),
        headlineLarge:  GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall:  GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge:     GoogleFonts.sora(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium:    GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall:     GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge:      GoogleFonts.dmSans(color: textPrimary),
        bodyMedium:     GoogleFonts.dmSans(color: textPrimary),
        bodySmall:      GoogleFonts.dmSans(color: textPrimary),
        labelLarge:     GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w600),
        labelMedium:    GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w500),
        labelSmall:     GoogleFonts.dmSans(color: textPrimary, fontWeight: FontWeight.w500),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sora(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: GoogleFonts.sora(
          color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          color: textPrimary, fontSize: 14, height: 1.5,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBackgroundColor: Colors.transparent,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFFFFFFFF).withOpacity(0.90),
        elevation: 0,
        contentTextStyle: GoogleFonts.dmSans(color: textPrimary, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: const Color(0xFFFFFFFF).withOpacity(0.80)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF).withOpacity(0.60),
        labelStyle: GoogleFonts.dmSans(
          color: const Color(0xFF0D1B3E).withOpacity(0.50), fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          color: accentBlue, fontSize: 12, fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: const Color(0xFF0D1B3E).withOpacity(0.30), fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFFFFFFFF).withOpacity(0.70)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: const Color(0xFFFFFFFF).withOpacity(0.70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentPink, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentPink, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentBlue,
        linearTrackColor: Colors.transparent,
        circularTrackColor: Colors.transparent,
      ),

      dividerTheme: DividerThemeData(
        color: const Color(0xFF1A6FE8).withOpacity(0.10),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Keep darkTheme for backward compat (returns lightTheme now)
  static ThemeData get darkTheme => lightTheme;
}

// ─────────────────────────────────────────────────────────────────
//  AppBackground — Persistent gradient background scaffold
// ─────────────────────────────────────────────────────────────────
class AppBackground extends StatelessWidget {
  final Widget child;
  final bool showOrb;
  const AppBackground({super.key, required this.child, this.showOrb = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFEBF4FF),
            Color(0xFFBDD8FF),
            Color(0xFF89BFFF),
            Color(0xFF4A9EFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.25, 0.55, 0.80, 1.0],
        ),
      ),
      child: Stack(
        children: [
          if (showOrb) ...[
            // Top-left white orb
            Positioned(
              top: -80,
              left: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.70),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Bottom-right blue orb
            Positioned(
              bottom: -60,
              right: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2B7DE9).withOpacity(0.35),
                      const Color(0xFF2B7DE9).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Mid-page accent orb
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7C5CFC).withOpacity(0.15),
                      const Color(0xFF7C5CFC).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlassCard — White frosted glassmorphism panel
// ─────────────────────────────────────────────────────────────────
class GlassCard extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Color? color;
  final Color? glowColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.sigmaX = 20,
    this.sigmaY = 20,
    this.radius = 20,
    this.padding,
    this.borderColor,
    this.color,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color ?? const Color(0xFFFFFFFF).withOpacity(0.55),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: borderColor ?? const Color(0xFFFFFFFF).withOpacity(0.75),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B7DE9).withOpacity(0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFFFFFFFF).withOpacity(0.90),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
                if (glowColor != null)
                  BoxShadow(
                    color: glowColor!.withOpacity(0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlassNavBar — Bottom navigation with glassmorphism
// ─────────────────────────────────────────────────────────────────
class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final List<GlassNavItem> items;
  final ValueChanged<int> onTap;
  final Color accentColor;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.accentColor = AppTheme.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF).withOpacity(0.70),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFFFFFFF).withOpacity(0.85),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B7DE9).withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final selected = i == currentIndex;
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? accentColor.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected
                                ? accentColor
                                : AppTheme.textPrimary.withOpacity(0.35),
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTheme.dmSans(
                            fontSize: 10,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            color: selected
                                ? accentColor
                                : AppTheme.textPrimary.withOpacity(0.35),
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─────────────────────────────────────────────────────────────────
//  StaggerEntry
// ─────────────────────────────────────────────────────────────────
class StaggerEntry extends StatelessWidget {
  final Widget child;
  final Animation<double> parent;
  final int index;
  final double interval;

  const StaggerEntry({
    super.key,
    required this.child,
    required this.parent,
    required this.index,
    this.interval = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final double start = (index * interval).clamp(0.0, 0.80);
    final double end   = (start + 0.35).clamp(0.0, 1.0);

    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: parent, curve: Interval(start, end, curve: Curves.easeOut)),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlowButton — Blue gradient pill CTA
// ─────────────────────────────────────────────────────────────────
class GlowButton extends StatefulWidget {
  final String label;
  final Color accent;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double height;
  final Widget? icon;

  const GlowButton({
    super.key,
    required this.label,
    required this.accent,
    this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.icon,
  });

  @override
  State<GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
    _glowAnim = Tween<double>(begin: 0.25, end: 0.50)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  void _down(TapDownDetails _) { _pressCtrl.forward(); }
  void _up(TapUpDetails _)    { _pressCtrl.reverse(); widget.onPressed?.call(); }
  void _cancel()              { _pressCtrl.reverse(); }

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null && !widget.isLoading;

    return GestureDetector(
      onTapDown:  disabled ? null : _down,
      onTapUp:    disabled ? null : _up,
      onTapCancel: disabled ? null : _cancel,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: disabled
                    ? [
                        const Color(0xFF1A6FE8).withOpacity(0.20),
                        const Color(0xFF1A6FE8).withOpacity(0.10),
                      ]
                    : [
                        widget.accent,
                        Color.lerp(widget.accent, const Color(0xFF0A4FBF), 0.3)!,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: disabled ? [] : [
                BoxShadow(
                  color: widget.accent.withOpacity(_glowAnim.value),
                  blurRadius: _glowAnim.value > 0.35 ? 24 : 14,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.30),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: child,
          ),
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[widget.icon!, const SizedBox(width: 8)],
                    Text(
                      widget.label,
                      style: AppTheme.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  StatusBadge
// ─────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  const StatusBadge(this.status, {super.key, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: AppTheme.statusBadgeDecor(status),
      child: Text(
        AppTheme.statusLabel(status),
        style: AppTheme.dmSans(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.statusColor(status),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  RoleBadge
// ─────────────────────────────────────────────────────────────────
class RoleBadge extends StatelessWidget {
  final String role;
  const RoleBadge(this.role, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.accentForRole(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        role.toUpperCase(),
        style: AppTheme.dmSans(
          fontSize: 10, fontWeight: FontWeight.w800,
          color: color, letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  ShimmerBox — Adapted for light background
// ─────────────────────────────────────────────────────────────────
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.15, end: 0.35)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: const Color(0xFF2B7DE9).withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}