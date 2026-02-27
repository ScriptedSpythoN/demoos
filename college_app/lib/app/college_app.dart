// lib/app/college_app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../screens/authentication/login_screen.dart';

class CollegeApp extends StatelessWidget {
  const CollegeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force dark status bar icons on transparent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduFlow',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppTheme.bgPrimary,
        colorScheme: ColorScheme.dark(
          primary: AppTheme.accentBlue,
          secondary: AppTheme.accentViolet,
          surface: AppTheme.bgSecondary,
          background: AppTheme.bgPrimary,
          error: AppTheme.accentPink,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.bgPrimary,
          elevation: 0,
          foregroundColor: AppTheme.textPrimary,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        // Dialog / bottom sheet dark styling
        dialogTheme: DialogThemeData(
          backgroundColor: AppTheme.bgSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          titleTextStyle: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppTheme.bgSecondary,
          contentTextStyle: const TextStyle(color: AppTheme.textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}