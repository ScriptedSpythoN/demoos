// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

// ─────────────────────────────────────────────────────────────────
//  AppTheme — Single source of truth for the entire design system
// ─────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._(); // non-instantiable

  // ── Backgrounds ────────────────────────────────────────────────
  static const Color bgPrimary   = Color(0xFF0A0A0F);
  static const Color bgSecondary = Color(0xFF0D0D1A);
  static const Color bgTertiary  = Color(0xFF12122A);

  // ── Role accents ───────────────────────────────────────────────
  static const Color accentBlue   = Color(0xFF4F8EF7); // Student
  static const Color accentViolet = Color(0xFF8B5CF6); // HOD
  static const Color accentTeal   = Color(0xFF2DD4BF); // Faculty
  static const Color accentPink   = Color(0xFFEC4899); // Alerts / Medical
  static const Color accentAmber  = Color(0xFFF59E0B); // Warnings / Pending

  // ── Text ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F0FF);
  // Getters because withValues() is a runtime call — cannot be const
  static Color get textSecondary => const Color(0xFFF0F0FF).withValues(alpha: 0.55);
  static Color get textMuted     => const Color(0xFFF0F0FF).withValues(alpha: 0.30);

  // ── Glass surface colours ──────────────────────────────────────
  static Color get glassFill   => const Color(0xFFFFFFFF).withValues(alpha: 0.07);
  static Color get glassFillHi => const Color(0xFFFFFFFF).withValues(alpha: 0.10);
  static Color get glassBorder => const Color(0xFFFFFFFF).withValues(alpha: 0.10);

  // ── Status colours ─────────────────────────────────────────────
  static const Color statusPending  = Color(0xFFF59E0B);
  static const Color statusAccepted = Color(0xFF2DD4BF);
  static const Color statusRejected = Color(0xFFEC4899);

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
      accentForRole(role).withValues(alpha: 0.35);

  // ─────────────────────────────────────────────────────────────
  //  BoxDecoration helpers
  // ─────────────────────────────────────────────────────────────

  /// Standard glass card decoration.
  /// Optionally accepts [glowColor] for role-specific glow shadow.
  static BoxDecoration glassCard({
    double radius = 20,
    Color? borderColor,
    Color? glowColor,
  }) =>
      BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? const Color(0xFFFFFFFF).withValues(alpha: 0.10),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
          // Inset top-highlight simulation
          BoxShadow(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.04),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
          if (glowColor != null)
            BoxShadow(
              color: glowColor,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
        ],
      );

  /// Status-coloured pill badge decoration.
  static BoxDecoration statusBadgeDecor(String status) {
    final c = statusColor(status);
    return BoxDecoration(
      color: c.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(50),
      border: Border.all(color: c.withValues(alpha: 0.40)),
      boxShadow: [BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 8)],
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

  /// Returns a capitalised display label — e.g. "PENDING" → "Pending"
  static String statusLabel(String status) {
    final s = status.toLowerCase();
    return s[0].toUpperCase() + s.substring(1);
  }

  // ─────────────────────────────────────────────────────────────
  //  Typography — Google Fonts helpers
  //  Always use these instead of hard-coding fontFamily strings.
  // ─────────────────────────────────────────────────────────────

  /// Sora — screen titles, hero numbers, display text.
  /// letterSpacing defaults to −0.02 em (spec).
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

  /// DM Sans — body copy, labels, subtitles, buttons.
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

  /// JetBrains Mono — attendance %, CGPA, time displays, counters.
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
  //  Page entry transition (use in Navigator.push)
  // ─────────────────────────────────────────────────────────────
  static PageRouteBuilder<T> slideRoute<T>(Widget page) =>
      PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          ),
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
  //  MaterialApp ThemeData
  // ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      colorScheme: const ColorScheme(
        brightness:    Brightness.dark,
        primary:       accentBlue,
        onPrimary:     Colors.white,
        secondary:     accentViolet,
        onSecondary:   Colors.white,
        tertiary:      accentTeal,
        onTertiary:    Colors.white,
        error:         accentPink,
        onError:       Colors.white,
        surface:       bgSecondary,
        onSurface:     textPrimary,
      ),
    );

    return base.copyWith(
      // ── Global text theme ─────────────────────────────────────
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

      // ── AppBar ────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.sora(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.02,
        ),
      ),

      // ── Dialog ────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: bgSecondary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.sora(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      // ── Bottom sheet ──────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        modalBackgroundColor: Colors.transparent,
      ),

      // ── SnackBar ──────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: bgSecondary,
        elevation: 0,
        contentTextStyle: GoogleFonts.dmSans(
          color: textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Input decoration ──────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
        labelStyle: GoogleFonts.dmSans(
          color: const Color(0xFFF0F0FF).withValues(alpha: 0.50),
          fontSize: 14,
        ),
        floatingLabelStyle: GoogleFonts.dmSans(
          color: accentBlue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.dmSans(
          color: const Color(0xFFF0F0FF).withValues(alpha: 0.30),
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.10),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFFFFFFFF).withValues(alpha: 0.10),
          ),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // ── Progress indicator ────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentBlue,
        linearTrackColor: Colors.transparent,
        circularTrackColor: Colors.transparent,
      ),

      // ── Divider ───────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.08),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlassCard — Reusable glassmorphism container widget
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
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? const Color(0xFFFFFFFF).withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ?? const Color(0xFFFFFFFF).withValues(alpha: 0.10),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.04),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
              if (glowColor != null)
                BoxShadow(
                  color: glowColor!,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  StaggerEntry — Staggered fade + slide-up card entry animation
//  Each card enters 80 ms after the previous one (design spec).
// ─────────────────────────────────────────────────────────────────
class StaggerEntry extends StatelessWidget {
  final Widget child;
  final Animation<double> parent;
  final int index;

  /// Gap between successive cards. 0.08 = ~80 ms at 1 s controller.
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
      CurvedAnimation(
        parent: parent,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06), // translateY(~24px) → 0
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  GlowButton — Full-width pill CTA with press-glow animation
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
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
    _glowAnim = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _)  { _pressCtrl.forward(); }
  void _up(TapUpDetails _)      { _pressCtrl.reverse(); widget.onPressed?.call(); }
  void _cancel()                 { _pressCtrl.reverse(); }

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
                        const Color(0xFFFFFFFF).withValues(alpha: 0.12),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.08),
                      ]
                    : [
                        widget.accent,
                        widget.accent.withValues(alpha: 0.75),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: disabled
                  ? []
                  : [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: _glowAnim.value),
                        blurRadius: _glowAnim.value > 0.45 ? 28 : 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: child,
          ),
        ),
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
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
//  StatusBadge — PENDING / APPROVED / REJECTED pill
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
//  RoleBadge — STUDENT / FACULTY / HOD coloured chip
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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        role.toUpperCase(),
        style: AppTheme.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  ShimmerBox — Animated loading skeleton block
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
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.03, end: 0.10).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}