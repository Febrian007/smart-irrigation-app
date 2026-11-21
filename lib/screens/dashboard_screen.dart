import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../controllers/irrigation_controller.dart';
import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
import '../widgets/charts.dart';
import '../widgets/connection_card.dart';
import '../widgets/pump_control_card.dart';
import '../widgets/sensor_grid.dart';
import '../widgets/sensor_log_card.dart';
import '../widgets/sensor_meta.dart';
import '../widgets/soil_hero_card.dart';
import '../widgets/threshold_card.dart';
import '../widgets/ui_kit.dart';

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

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handlePumpCommand(String command) async {
    try {
      await _controller.setPumpMode(_ipController.text, command);
    } catch (e) {
      _toast('Gagal mengirim perintah pompa: $e');
    }
  }

  Future<void> _handleSaveThresholds() async {
    try {
      await _controller.saveThresholds(_ipController.text);
      _toast(
        _controller.state.isSimulation
            ? 'Ambang batas diperbarui (Simulasi)'
            : 'Ambang batas disimpan ke ESP32',
      );
    } catch (e) {
      _toast('Gagal menyimpan ambang batas: $e');
    }
  }

  void _handleModeChanged(ConnectionMode mode) {
    _controller.setConnectionMode(mode);
    if (mode == ConnectionMode.firebase &&
        _ipController.text.contains('192.168.')) {
      _ipController.text = 'https://NAMA-PROJECT-default-rtdb.asia-southeast1.firebasedatabase.app';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  const SheetHandle(),
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

  void _openSensorSheet(SensorKind kind) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ListenableBuilder(
        listenable: _controller,
        builder: (context, _) =>
            _SensorDetailSheet(kind: kind, state: _controller.state),
      ),
    );
  }

  List<Widget> _tabChildren(IrrigationState state) {
    switch (_activeTab) {
      case 0:
        return [
          CompactConnectionBar(
            endpoint: _ipController.text,
            mode: state.connectionMode,
            health: state.connectionHealth,
            statusLabel: state.connectionLabel,
            onEditTap: _openConnectionSheet,
            onConnect: () => _controller.connect(_ipController.text),
          ),
          const SizedBox(height: 12),
          SoilHeroCard(
            state: state,
            onTap: () => _openSensorSheet(SensorKind.soil),
            onConnect: _openConnectionSheet,
            onSimulate: () => _controller.toggleSimulation(true),
          ),
          const SizedBox(height: 12),
          SensorGrid(state: state, onOpen: _openSensorSheet),
          const SizedBox(height: 12),
          PumpControlCard(
            pumpMode: state.pumpMode,
            pumpOn: state.irrigationPumpOn,
            pumpActiveSec: state.pumpActiveSec,
            onCommand: _handlePumpCommand,
          ),
        ];
      case 1:
        return [
          ThresholdCard(
            soilThreshold: state.soilThreshold,
            tankThreshold: state.tankThreshold,
            soilMoisture: state.soilMoisture,
            waterLevel: state.waterLevel,
            live: state.isLive,
            onSoilChanged: (v) => _controller.updateLocalThresholds(soil: v),
            onTankChanged: (v) => _controller.updateLocalThresholds(tank: v),
            onSave: _handleSaveThresholds,
          ),
        ];
      default:
        return [SensorLogCard(state: state)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;

          return Scaffold(
            backgroundColor: AppPalette.background,
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.9, -1.1),
                  radius: 1.1,
                  colors: [Color(0xFF1F2466), AppPalette.background],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _DashboardHeader(
                      state: state,
                      onToggleSimulation: _controller.toggleSimulation,
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: state.isTankLow
                          ? const Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
                              child: _TankLowBanner(),
                            )
                          : const SizedBox(width: double.infinity),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 280),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.03),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: ListView(
                          key: ValueKey(_activeTab),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          children: _tabChildren(state),
                        ),
                      ),
                    ),
                    _NavBar(
                      index: _activeTab,
                      logCount: state.logs.length,
                      onSelect: (i) => setState(() => _activeTab = i),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
    final statusColor = connectionColor(state.connectionHealth);
    final sim = state.isSimulation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppPalette.border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.primary.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.asset('assets/icon/app_icon.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Irrigation Monitor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppPalette.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    PulseDot(color: statusColor, size: 6, active: state.isLive),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        modeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppPalette.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            toggled: sim,
            label: 'Mode simulasi',
            child: Pressable(
              onTap: () => onToggleSimulation(!sim),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: sim ? AppPalette.primary : AppPalette.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: sim ? AppPalette.primary : AppPalette.border,
                  ),
                  boxShadow: [
                    if (sim)
                      BoxShadow(
                        color: AppPalette.primary.withValues(alpha: 0.45),
                        blurRadius: 18,
                        spreadRadius: -4,
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sim ? Icons.science_rounded : Icons.science_outlined,
                      size: 17,
                      color: sim ? AppPalette.onAccent : AppPalette.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Simulasi',
                      style: TextStyle(
                        color: sim
                            ? AppPalette.onAccent
                            : AppPalette.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final int index;
  final int logCount;
  final ValueChanged<int> onSelect;

  const _NavBar({
    required this.index,
    required this.logCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'Monitoring',
            selected: index == 0,
            onTap: () => onSelect(0),
          ),
          _NavItem(
            icon: Icons.tune_rounded,
            label: 'Kalibrasi',
            selected: index == 1,
            onTap: () => onSelect(1),
          ),
          _NavItem(
            icon: Icons.insights_rounded,
            label: 'Riwayat',
            badge: logCount,
            selected: index == 2,
            onTap: () => onSelect(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? badge;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppPalette.onAccent : AppPalette.textSecondary;
    final count = badge;
    return Expanded(
      flex: selected ? 14 : 10,
      child: Semantics(
        selected: selected,
        child: Pressable(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            height: 48,
            decoration: BoxDecoration(
              color: selected ? AppPalette.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                ),
                if (count != null && count > 0 && !selected) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.primarySoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppPalette.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TankLowBanner extends StatelessWidget {
  const _TankLowBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppPalette.coralSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.coral.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          PulseDot(color: AppPalette.coral, size: 9),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'PERINGATAN: Level air tangki di bawah ambang batas! Segera '
              'isi ulang.',
              style: TextStyle(
                color: AppPalette.coral,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Detail satu sensor: nilai sekarang, grafik interaktif, min/rata-rata/maks.
class _SensorDetailSheet extends StatelessWidget {
  final SensorKind kind;
  final IrrigationState state;

  const _SensorDetailSheet({required this.kind, required this.state});

  @override
  Widget build(BuildContext context) {
    final values = seriesOf(state.logs, kind);
    final has = values.isNotEmpty;
    final lo = has ? values.reduce(math.min) : 0.0;
    final hi = has ? values.reduce(math.max) : 0.0;
    final avg = has ? values.reduce((a, b) => a + b) / values.length : 0.0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Row(
              children: [
                IconBadge(icon: kind.icon, color: kind.color, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kind.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimatedNumber(
                            value: kind.current(state),
                            placeholder: !state.isLive,
                            style: const TextStyle(
                              fontSize: 30,
                              height: 1.1,
                              fontWeight: FontWeight.w800,
                              color: AppPalette.textPrimary,
                              letterSpacing: -0.6,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            kind.unit,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppPalette.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            HistoryChart(
              values: values,
              times: timesOf(state.logs),
              color: kind.color,
              unit: kind.unit,
              threshold: kind.threshold(state),
              height: 200,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _Stat(label: 'Min', value: lo, unit: kind.unit, has: has),
                const SizedBox(width: 8),
                _Stat(
                  label: 'Rata-rata',
                  value: avg,
                  unit: kind.unit,
                  has: has,
                ),
                const SizedBox(width: 8),
                _Stat(label: 'Maks', value: hi, unit: kind.unit, has: has),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final bool has;

  const _Stat({
    required this.label,
    required this.value,
    required this.unit,
    required this.has,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppPalette.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              has ? '${value.toStringAsFixed(1)}$unit' : '--',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppPalette.textPrimary,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
