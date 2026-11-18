import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';

class SensorLogCard extends StatelessWidget {
  final List<SensorLogEntry> logs;

  const SensorLogCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Riwayat Pembacaan Terbaru',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            if (logs.isEmpty)
              const Text(
                'Belum ada data. Hubungkan ESP32 atau aktifkan Mode Simulasi.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...logs.take(5).map((e) {
                final t =
                    '${e.time.hour.toString().padLeft(2, '0')}:'
                    '${e.time.minute.toString().padLeft(2, '0')}:'
                    '${e.time.second.toString().padLeft(2, '0')}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '[$t] Suhu ${e.temperature.toStringAsFixed(1)}°C | '
                    'RH ${e.humidity.toStringAsFixed(1)}% | '
                    'Tanah ${e.soilMoisture.toStringAsFixed(1)}% | '
                    'Air ${e.waterLevel.toStringAsFixed(1)}% | '
                    'Pompa ${e.pumpOn ? "ON" : "OFF"}',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
