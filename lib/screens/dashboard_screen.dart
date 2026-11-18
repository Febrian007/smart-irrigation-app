import 'package:material_ui/material_ui.dart';

import '../controllers/irrigation_controller.dart';
import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
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
  int _activeTab = 0;

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

  void _handleModeChanged(ConnectionMode mode) {
    _controller.setConnectionMode(mode);
    if (mode == ConnectionMode.firebase &&
        _ipController.text.contains('192.168.')) {
      _ipController.text =
          'https://NAMA-PROJECT-default-rtdb.asia-southeast1.firebasedatabase.app';
    } else if (mode == ConnectionMode.local &&
        _ipController.text.contains('firebasedatabase')) {
      _ipController.text = 'http://192.168.137.10';
    }
  }

  void _openConnectionSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final state = _controller.state;
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppPalette.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  ConnectionCard(
                    ipController: _ipController,
                    mode: state.connectionMode,
                    health: state.connectionHealth,
                    statusLabel: state.connectionLabel,
                    onModeChanged: _handleModeChanged,
                    onConnect: () {
                      Navigator.of(sheetContext).pop();
                      _controller.connect(_ipController.text);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return Scaffold(
          backgroundColor: AppPalette.primary,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _DashboardHeader(
                  state: state,
                  onToggleSimulation: _controller.toggleSimulation,
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppPalette.background,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      children: [
                        _SheetTabBar(
                          activeTab: _activeTab,
                          logCount: state.logs.length,
                          onTabSelected: (index) {
                            setState(() => _activeTab = index);
                          },
                        ),
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            children: [
                              if (state.isTankLow) ...[
                                const _TankLowBanner(),
                                const SizedBox(height: 10),
                              ],
                              if (_activeTab == 0) ...[
                                CompactConnectionBar(
                                  endpoint: _ipController.text,
                                  mode: state.connectionMode,
                                  health: state.connectionHealth,
                                  statusLabel: state.connectionLabel,
                                  onEditTap: _openConnectionSheet,
                                  onConnect: () =>
                                      _controller.connect(_ipController.text),
                                ),
                                const SizedBox(height: 10),
                                SensorGrid(state: state),
                                const SizedBox(height: 10),
                                PumpControlCard(
                                  pumpMode: state.pumpMode,
                                  pumpOn: state.irrigationPumpOn,
                                  pumpActiveSec: state.pumpActiveSec,
                                  onCommand: _handlePumpCommand,
                                ),
                              ] else ...[
                                ThresholdCard(
                                  soilThreshold: state.soilThreshold,
                                  tankThreshold: state.tankThreshold,
                                  onSoilChanged: (v) =>
                                      _controller.updateLocalThresholds(
                                        soil: v,
                                      ),
                                  onTankChanged: (v) =>
                                      _controller.updateLocalThresholds(
                                        tank: v,
                                      ),
                                  onSave: _handleSaveThresholds,
                                ),
                                const SizedBox(height: 12),
                                SensorLogCard(logs: state.logs),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final IrrigationState state;
  final ValueChanged<bool> onToggleSimulation;

  const _DashboardHeader({
    required this.state,
    required this.onToggleSimulation,
  });

  @override
  Widget build(BuildContext context) {
    final modeText = state.isSimulation
        ? 'Mode Simulasi Aktif'
        : (state.connectionMode == ConnectionMode.firebase
              ? 'Firebase RTDB'
              : 'ESP32 Lokal');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    modeText,
                    style: const TextStyle(
                      color: Color(0xFFD9DDFB),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, right: 4),
                decoration: BoxDecoration(
                  color: AppPalette.headerOverlay,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppPalette.headerBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Simulasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      height: 28,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Switch(
                          value: state.isSimulation,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppPalette.mint,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Colors.white24,
                          onChanged: onToggleSimulation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Smart Irrigation Monitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      state.irrigationPumpOn ? 'ON' : 'OFF',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: state.irrigationPumpOn
                            ? AppPalette.mint
                            : AppPalette.primary,
                      ),
                    ),
                    const Text(
                      'Pompa',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetTabBar extends StatelessWidget {
  final int activeTab;
  final int logCount;
  final ValueChanged<int> onTabSelected;

  const _SheetTabBar({
    required this.activeTab,
    required this.logCount,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(bottom: BorderSide(color: AppPalette.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _SheetTabItem(
              label: 'Monitoring',
              selected: activeTab == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          Expanded(
            child: _SheetTabItem(
              label: 'Kalibrasi & Log',
              badgeCount: logCount,
              selected: activeTab == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTabItem extends StatelessWidget {
  final String label;
  final int? badgeCount;
  final bool selected;
  final VoidCallback onTap;

  const _SheetTabItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected
                        ? AppPalette.textPrimary
                        : AppPalette.textMuted,
                  ),
                ),
                if (badgeCount != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppPalette.primarySoft
                          : AppPalette.background,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? AppPalette.primary
                            : AppPalette.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2.5,
            width: selected ? 84 : 0,
            decoration: BoxDecoration(
              color: AppPalette.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _TankLowBanner extends StatelessWidget {
  const _TankLowBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.coralSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.coral.withValues(alpha: 0.35)),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppPalette.coral),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'PERINGATAN: Level air tangki di bawah ambang batas! Segera isi ulang.',
              style: TextStyle(
                color: AppPalette.coral,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
