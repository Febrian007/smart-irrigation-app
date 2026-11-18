import 'package:material_ui/material_ui.dart';

class ThresholdCard extends StatelessWidget {
  final double soilThreshold;
  final double tankThreshold;
  final ValueChanged<double> onSoilChanged;
  final ValueChanged<double> onTankChanged;
  final VoidCallback onSave;

  const ThresholdCard({
    super.key,
    required this.soilThreshold,
    required this.tankThreshold,
    required this.onSoilChanged,
    required this.onTankChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kalibrasi Ambang Batas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambang Kelembapan Tanah: ${soilThreshold.toStringAsFixed(0)}%',
            ),
            Slider(
              value: soilThreshold,
              min: 10,
              max: 85,
              divisions: 75,
              label: '${soilThreshold.toStringAsFixed(0)}%',
              onChanged: onSoilChanged,
            ),
            Text(
              'Ambang Level Air Tangki: ${tankThreshold.toStringAsFixed(0)}%',
            ),
            Slider(
              value: tankThreshold,
              min: 5,
              max: 50,
              divisions: 45,
              label: '${tankThreshold.toStringAsFixed(0)}%',
              onChanged: onTankChanged,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: onSave,
                child: const Text('Simpan Ambang ke ESP32'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
