import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';

class SensorGrid extends StatelessWidget {
  final IrrigationState state;

  const SensorGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        _SensorCard(
          title: 'Temperature',
          value: '${state.temperature.toStringAsFixed(2)} °C',
          icon: Icons.thermostat,
          color: Colors.deepOrange,
        ),
        _SensorCard(
          title: 'Humidity',
          value: '${state.humidity.toStringAsFixed(2)} %',
          icon: Icons.water_drop_outlined,
          color: Colors.blue,
        ),
        _SensorCard(
          title: 'Soil Moisture',
          value: '${state.soilMoisture.toStringAsFixed(2)} %',
          icon: Icons.grass,
          color: state.soilMoisture < state.soilThreshold
              ? Colors.amber.shade800
              : Colors.green,
          subtitle: 'Ambang: < ${state.soilThreshold.toStringAsFixed(0)}%',
        ),
        _SensorCard(
          title: 'Water Level',
          value: '${state.waterLevel.toStringAsFixed(2)} %',
          icon: Icons.waves,
          color: state.waterLevel < state.tankThreshold
              ? Colors.red
              : Colors.teal,
          subtitle: 'Ambang: < ${state.tankThreshold.toStringAsFixed(0)}%',
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
