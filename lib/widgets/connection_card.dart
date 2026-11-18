import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';

class ConnectionCard extends StatelessWidget {
  final TextEditingController ipController;
  final ConnectionMode mode;
  final ConnectionHealth health;
  final String statusLabel;
  final ValueChanged<ConnectionMode> onModeChanged;
  final VoidCallback onConnect;

  const ConnectionCard({
    super.key,
    required this.ipController,
    required this.mode,
    required this.health,
    required this.statusLabel,
    required this.onModeChanged,
    required this.onConnect,
  });

  Color get _badgeColor {
    switch (health) {
      case ConnectionHealth.connected:
        return Colors.green;
      case ConnectionHealth.connecting:
      case ConnectionHealth.disconnected:
        return Colors.orange;
      case ConnectionHealth.reconnecting:
        return Colors.red;
      case ConnectionHealth.simulation:
        return Colors.deepPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFirebase = mode == ConnectionMode.firebase;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Koneksi Sistem',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _badgeColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ConnectionMode>(
                segments: const [
                  ButtonSegment(
                    value: ConnectionMode.local,
                    icon: Icon(Icons.lan, size: 18),
                    label: Text('Lokal (ESP32)'),
                  ),
                  ButtonSegment(
                    value: ConnectionMode.firebase,
                    icon: Icon(Icons.cloud_outlined, size: 18),
                    label: Text('Jarak Jauh (Firebase)'),
                  ),
                ],
                selected: {mode},
                onSelectionChanged: (set) => onModeChanged(set.first),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    decoration: InputDecoration(
                      labelText:
                          isFirebase ? 'URL Firebase RTDB' : 'Alamat IP ESP32',
                      hintText: isFirebase
                          ? 'https://xxx-default-rtdb.asia-southeast1.firebasedatabase.app'
                          : 'http://192.168.137.10',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: onConnect,
                  icon: Icon(isFirebase ? Icons.cloud_done : Icons.wifi),
                  label: const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
