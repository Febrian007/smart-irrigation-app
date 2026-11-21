import 'package:material_ui/material_ui.dart';

import 'screens/dashboard_screen.dart';
import 'theme/app_palette.dart';

class SmartIrrigationApp extends StatelessWidget {
  const SmartIrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      primary: AppPalette.primary,
      onPrimary: AppPalette.onAccent,
      secondary: AppPalette.mint,
      surface: AppPalette.surface,
      onSurface: AppPalette.textPrimary,
      error: AppPalette.coral,
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Smart Irrigation Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppPalette.background,
        splashFactory: InkSparkle.splashFactory,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.primary,
            foregroundColor: AppPalette.onAccent,
            elevation: 0,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.textPrimary,
            minimumSize: const Size(0, 48),
            side: const BorderSide(color: AppPalette.border),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppPalette.primary,
          inactiveTrackColor: AppPalette.surfaceHigh,
          thumbColor: Colors.white,
          overlayColor: AppPalette.primary.withValues(alpha: 0.18),
          valueIndicatorColor: AppPalette.primary,
          valueIndicatorTextStyle: const TextStyle(
            color: AppPalette.onAccent,
            fontWeight: FontWeight.w700,
          ),
          trackHeight: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppPalette.surfaceHigh,
          contentTextStyle: const TextStyle(
            color: AppPalette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppPalette.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
