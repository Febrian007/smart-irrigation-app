import 'package:material_ui/material_ui.dart';

class PumpControlCard extends StatelessWidget {
  final String pumpMode;
  final bool pumpOn;
  final int pumpActiveSec;
  final void Function(String command) onCommand;

  const PumpControlCard({
    super.key,
    required this.pumpMode,
    required this.pumpOn,
    required this.pumpActiveSec,
    required this.onCommand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pompa Siram ($pumpMode)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: pumpOn ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    pumpOn ? 'POMPA ON' : 'POMPA OFF',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: pumpOn
                          ? Colors.green.shade900
                          : Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('Total durasi pompa aktif: $pumpActiveSec detik'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => onCommand('auto'),
                    child: const Text('AUTO'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => onCommand('on'),
                    child: const Text('ON'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => onCommand('off'),
                    child: const Text('OFF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
