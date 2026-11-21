import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
import 'charts.dart';
import 'sensor_meta.dart';
import 'ui_kit.dart';

/// Grafik riwayat (pilih sensor lewat chip) + daftar pembacaan terbaru.
class SensorLogCard extends StatefulWidget {
  final IrrigationState state;

  const SensorLogCard({super.key, required this.state});

  @override
  State<SensorLogCard> createState() => _SensorLogCardState();
}

class _SensorLogCardState extends State<SensorLogCard> {
  SensorKind _kind = SensorKind.soil;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final logs = state.logs;
    final visibleLogs = logs.take(8).toList();

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(icon: Icons.show_chart_rounded, color: _kind.color),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Grafik Riwayat',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppPalette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  StatusPill(
                    label: '${logs.length} data',
                    color: AppPalette.textSecondary,
                    showDot: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final k in SensorKind.values) ...[
                    Expanded(
                      child: _KindChip(
                        kind: k,
                        selected: k == _kind,
                        onTap: () => setState(() => _kind = k),
                      ),
                    ),
                    if (k != SensorKind.values.last) const SizedBox(width: 6),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              HistoryChart(
                values: seriesOf(logs, _kind),
                times: timesOf(logs),
                color: _kind.color,
                unit: _kind.unit,
                threshold: _kind.threshold(state),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  IconBadge(
                    icon: Icons.history_rounded,
                    color: AppPalette.primary,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Riwayat Pembacaan Terbaru',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppPalette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (visibleLogs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppPalette.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Belum ada data. Hubungkan ESP32 atau aktifkan Mode '
                    'Simulasi.',
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                )
              else
                for (var i = 0; i < visibleLogs.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 18, color: AppPalette.divider),
                  _LogRow(entry: visibleLogs[i], latest: i == 0),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  final SensorKind kind;
  final bool selected;
  final VoidCallback onTap;

  const _KindChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppPalette.onAccent : AppPalette.textSecondary;
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 44,
        decoration: BoxDecoration(
          color: selected ? kind.color : AppPalette.background,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: selected ? kind.color : AppPalette.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(kind.icon, size: 15, color: fg),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                kind.shortLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final SensorLogEntry entry;
  final bool latest;

  const _LogRow({required this.entry, required this.latest});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: latest ? AppPalette.primarySoft : AppPalette.background,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            formatClock(entry.time),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: latest ? AppPalette.primary : AppPalette.textSecondary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              for (final k in SensorKind.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(k.icon, size: 13, color: k.color),
                    const SizedBox(width: 3),
                    Text(
                      '${k.read(entry).toStringAsFixed(1)}${k.unit}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppPalette.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusPill(
          label: entry.pumpOn ? 'ON' : 'OFF',
          color: entry.pumpOn ? AppPalette.mint : AppPalette.textMuted,
          showDot: false,
        ),
      ],
    );
  }
}
