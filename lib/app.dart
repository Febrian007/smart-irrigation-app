import 'package:material_ui/material_ui.dart';

import 'screens/dashboard_screen.dart';

class SmartIrrigationApp extends StatelessWidget {
  const SmartIrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Irrigation Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F3D91),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
