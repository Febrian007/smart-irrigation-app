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
      secondary: AppPalette.mint,
      surface: AppPalette.surface,
      error: AppPalette.coral,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Smart Irrigation Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppPalette.background,
        cardTheme: CardThemeData(
          color: AppPalette.surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppPalette.border),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: AppPalette.primary,
          inactiveTrackColor: AppPalette.primarySoft,
          thumbColor: AppPalette.primary,
          overlayColor: AppPalette.primary.withValues(alpha: 0.14),
          valueIndicatorColor: AppPalette.primary,
          trackHeight: 5,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
