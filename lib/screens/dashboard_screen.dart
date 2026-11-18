import 'package:material_ui/material_ui.dart';

import '../controllers/irrigation_controller.dart';
import '../models/irrigation_state.dart';
import '../widgets/connection_card.dart';
import '../widgets/pump_control_card.dart';
import '../widgets/sensor_grid.dart';
import '../widgets/sensor_log_card.dart';
import '../widgets/threshold_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _ipController = TextEditingController(
    text: 'http://192.168.43.135',
  );
  final IrrigationController _controller = IrrigationController();

  @override
  void dispose() {
    _controller.dispose();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _handlePumpCommand(String command) async {
    try {
      await _controller.setPumpMode(_ipController.text, command);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim perintah pompa: $e')),
        );
      }
    }
  }

  Future<void> _handleSaveThresholds() async {
    try {
      await _controller.saveThresholds(_ipController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _controller.state.isSimulation
                  ? 'Ambang batas diperbarui (Simulasi)'
                  : 'Ambang batas disimpan ke ESP32',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan ambang batas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Smart Irrigation Monitor'),
            backgroundColor: const Color(0xFF0F3D91),
            foregroundColor: Colors.white,
            actions: [
              Row(
                children: [
                  const Text('Simulasi', style: TextStyle(fontSize: 12)),
                  Switch(
                    value: state.isSimulation,
                    activeThumbColor: Colors.amber,
                    onChanged: _controller.toggleSimulation,
                  ),
                ],
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (state.isTankLow)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'PERINGATAN: Level air tangki di bawah ambang batas! Segera isi ulang.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ConnectionCard(
                ipController: _ipController,
                mode: state.connectionMode,
                health: state.connectionHealth,
                statusLabel: state.connectionLabel,
                onModeChanged: (mode) {
                  _controller.setConnectionMode(mode);
                  if (mode == ConnectionMode.firebase &&
                      _ipController.text.contains('192.168.')) {
                    _ipController.text =
                        'https://NAMA-PROJECT-default-rtdb.asia-southeast1.firebasedatabase.app';
                  } else if (mode == ConnectionMode.local &&
                      _ipController.text.contains('firebasedatabase')) {
                    _ipController.text = 'http://192.168.137.10';
                  }
                },
                onConnect: () => _controller.connect(_ipController.text),
              ),
              const SizedBox(height: 12),
              SensorGrid(state: state),
              const SizedBox(height: 12),
              PumpControlCard(
                pumpMode: state.pumpMode,
                pumpOn: state.irrigationPumpOn,
                pumpActiveSec: state.pumpActiveSec,
                onCommand: _handlePumpCommand,
              ),
              const SizedBox(height: 12),
              ThresholdCard(
                soilThreshold: state.soilThreshold,
                tankThreshold: state.tankThreshold,
                onSoilChanged: (v) =>
                    _controller.updateLocalThresholds(soil: v),
                onTankChanged: (v) =>
                    _controller.updateLocalThresholds(tank: v),
                onSave: _handleSaveThresholds,
              ),
              const SizedBox(height: 12),
              SensorLogCard(logs: state.logs),
            ],
          ),
        );
      },
    );
  }
}
