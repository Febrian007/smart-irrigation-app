import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
import 'charts.dart';
import 'sensor_meta.dart';
import 'ui_kit.dart';

/// Kartu utama: gauge kelembapan tanah beranimasi + kondisi lahan saat ini.
class SoilHeroCard extends StatelessWidget {
  final IrrigationState state;
  final VoidCallback onTap;
  final VoidCallback onConnect;
  final VoidCallback onSimulate;

  const SoilHeroCard({
    super.key,
    required this.state,
    required this.onTap,
    required this.onConnect,
    required this.onSimulate,
  });

  @override
  Widget build(BuildContext context) {
    if (!state.isLive) {
      return _EmptyHero(onConnect: onConnect, onSimulate: onSimulate);
    }

    final dry = state.soilMoisture < state.soilThreshold;
    final color = dry ? AppPalette.amber : AppPalette.mint;
    final thr = state.soilThreshold.toStringAsFixed(0);
    final detail = state.irrigationPumpOn
        ? 'Pompa sedang menyiram lahan.'
        : dry
        ? 'Di bawah ambang $thr%, lahan perlu disiram.'
        : 'Di atas ambang $thr%, belum perlu disiram.';

    return AppCard(
      glow: color,
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(14, 16, 16, 16),
      child: Row(
        children: [
          SoilGauge(
            value: state.soilMoisture,
            threshold: state.soilThreshold,
            color: color,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  label: dry ? 'KERING' : 'LEMBAP',
                  color: color,
                  pulse: true,
                ),
                const SizedBox(height: 8),
                Text(
                  dry ? 'Tanah kering' : 'Tanah lembap',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppPalette.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Sparkline(
                  values: seriesOf(state.logs, SensorKind.soil),
                  color: color,
                  height: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHero extends StatelessWidget {
  final VoidCallback onConnect;
  final VoidCallback onSimulate;

  const _EmptyHero({required this.onConnect, required this.onSimulate});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              IconBadge(
                icon: Icons.sensors_off_rounded,
                color: AppPalette.primary,
                size: 44,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Belum ada data sensor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Hubungkan ke ESP32 atau nyalakan Mode Simulasi untuk melihat '
            'dashboard bekerja.',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onConnect,
                  icon: const Icon(Icons.wifi_rounded, size: 18),
                  label: const Text('Hubungkan'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSimulate,
                  icon: const Icon(Icons.science_rounded, size: 18),
                  label: const Text('Simulasi'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Gauge busur 270° dengan penanda ambang batas.
class SoilGauge extends StatelessWidget {
  final double value;
  final double threshold;
  final Color color;
  final double size;

  const SoilGauge({
    super.key,
    required this.value,
    required this.threshold,
    required this.color,
    this.size = 148,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Kelembapan tanah ${value.toStringAsFixed(1)} persen, '
          'ambang ${threshold.toStringAsFixed(0)} persen',
      child: SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: value),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) {
            return CustomPaint(
              painter: _GaugePainter(
                progress: (v / 100).clamp(0.0, 1.0),
                threshold: (threshold / 100).clamp(0.0, 1.0),
                color: color,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          v.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 34,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: AppPalette.textPrimary,
                            letterSpacing: -1,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const Text(
                          '%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppPalette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Soil Moisture',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  static const _start = math.pi * 0.75;
  static const _sweep = math.pi * 1.5;
  static const _stroke = 13.0;

  final double progress;
  final double threshold;
  final Color color;

  _GaugePainter({
    required this.progress,
    required this.threshold,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _stroke / 2 - 6;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..color = AppPalette.surfaceHigh
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    if (progress > 0.005) {
      final arc = _sweep * progress;
      canvas.drawArc(
        rect,
        _start,
        arc,
        false,
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
      );
      canvas.drawArc(
        rect,
        _start,
        arc,
        false,
        Paint()
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: math.max(arc, 0.4),
            colors: [AppPalette.sky, color],
            transform: const GradientRotation(_start - 0.14),
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Penanda ambang batas.
    final a = _start + _sweep * threshold;
    final dir = Offset(math.cos(a), math.sin(a));
    canvas.drawLine(
      center + dir * (radius - _stroke / 2 - 3),
      center + dir * (radius + _stroke / 2 + 3),
      Paint()
        ..color = AppPalette.textPrimary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress ||
      old.threshold != threshold ||
      old.color != color;
}
