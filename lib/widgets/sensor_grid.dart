import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';
import 'charts.dart';
import 'sensor_meta.dart';
import 'ui_kit.dart';

/// Suhu, kelembapan udara, dan tangki air. Ketuk kartu untuk grafik detail.
class SensorGrid extends StatelessWidget {
  final IrrigationState state;
  final ValueChanged<SensorKind> onOpen;

  const SensorGrid({super.key, required this.state, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final live = state.isLive;
    final hot = state.temperature > 35;
    final tankLow = live && state.waterLevel < state.tankThreshold;
    final tankColor = tankLow ? AppPalette.coral : AppPalette.primary;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MiniTile(
                kind: SensorKind.temperature,
                value: state.temperature,
                live: live,
                color: hot ? AppPalette.coral : AppPalette.amber,
                badge: hot ? 'Panas' : 'Normal',
                badgeColor: hot ? AppPalette.coral : AppPalette.mint,
                series: seriesOf(state.logs, SensorKind.temperature),
                onTap: () => onOpen(SensorKind.temperature),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MiniTile(
                kind: SensorKind.humidity,
                value: state.humidity,
                live: live,
                color: AppPalette.sky,
                badge: 'Udara',
                badgeColor: AppPalette.sky,
                series: seriesOf(state.logs, SensorKind.humidity),
                onTap: () => onOpen(SensorKind.humidity),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AppCard(
          glow: tankLow ? AppPalette.coral : null,
          onTap: () => onOpen(SensorKind.water),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              WaveTank(
                level: live ? (state.waterLevel / 100).clamp(0.0, 1.0) : 0,
                threshold: (state.tankThreshold / 100).clamp(0.0, 1.0),
                color: tankColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Water Level',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppPalette.textSecondary,
                            ),
                          ),
                        ),
                        if (live)
                          StatusPill(
                            label: tankLow ? 'RENDAH' : 'AMAN',
                            color: tankLow ? AppPalette.coral : AppPalette.mint,
                            pulse: tankLow,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _ValueRow(
                      value: state.waterLevel,
                      unit: '%',
                      live: live,
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ambang < ${state.tankThreshold.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppPalette.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.show_chart_rounded,
                          size: 16,
                          color: AppPalette.textMuted,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Grafik',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ValueRow extends StatelessWidget {
  final double value;
  final String unit;
  final bool live;
  final double size;

  const _ValueRow({
    required this.value,
    required this.unit,
    required this.live,
    this.size = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        AnimatedNumber(
          value: value,
          placeholder: !live,
          style: TextStyle(
            fontSize: size,
            height: 1.1,
            fontWeight: FontWeight.w800,
            color: AppPalette.textPrimary,
            letterSpacing: -0.6,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 3),
        Text(
          unit,
          style: TextStyle(
            fontSize: size * 0.48,
            fontWeight: FontWeight.w700,
            color: AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniTile extends StatelessWidget {
  final SensorKind kind;
  final double value;
  final bool live;
  final Color color;
  final String badge;
  final Color badgeColor;
  final List<double> series;
  final VoidCallback onTap;

  const _MiniTile({
    required this.kind,
    required this.value,
    required this.live,
    required this.color,
    required this.badge,
    required this.badgeColor,
    required this.series,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: kind.icon, color: color, size: 36),
              const Spacer(),
              if (live)
                StatusPill(label: badge, color: badgeColor, showDot: false),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            kind.label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          _ValueRow(value: value, unit: kind.unit, live: live),
          const SizedBox(height: 8),
          Sparkline(values: series, color: color, height: 28),
        ],
      ),
    );
  }
}

/// Tangki dengan permukaan air bergelombang yang terus bergerak.
class WaveTank extends StatefulWidget {
  final double level;
  final double threshold;
  final Color color;
  final double width;
  final double height;

  const WaveTank({
    super.key,
    required this.level,
    required this.threshold,
    required this.color,
    this.width = 78,
    this.height = 100,
  });

  @override
  State<WaveTank> createState() => _WaveTankState();
}

class _WaveTankState extends State<WaveTank>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: widget.level),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (_, level, _) => AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(
            painter: _WavePainter(
              level: level,
              threshold: widget.threshold,
              phase: _c.value * 2 * math.pi,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double level;
  final double threshold;
  final double phase;
  final Color color;

  _WavePainter({
    required this.level,
    required this.threshold,
    required this.phase,
    required this.color,
  });

  Path _wave(Size size, double baseY, double amp, double shift) {
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= size.width; x += 2) {
      final y =
          baseY + amp * math.sin(2 * math.pi * (x / size.width) * 1.3 + shift);
      path.lineTo(x, y);
    }
    return path
      ..lineTo(size.width, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(20),
    );
    canvas.save();
    canvas.clipRRect(body);
    canvas.drawRect(Offset.zero & size, Paint()..color = AppPalette.background);

    if (level > 0.001) {
      final baseY = size.height * (1 - level);
      final amp = level > 0.97 ? 1.0 : 3.5;
      canvas.drawPath(
        _wave(size, baseY, amp, phase + 1.6),
        Paint()..color = color.withValues(alpha: 0.35),
      );
      canvas.drawPath(
        _wave(size, baseY + 2, amp, -phase),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0.55)],
          ).createShader(Offset.zero & size),
      );
    }

    // Garis ambang batas.
    final ty = size.height * (1 - threshold);
    final dash = Paint()
      ..color = AppPalette.textPrimary.withValues(alpha: 0.85)
      ..strokeWidth = 1.5;
    for (double x = 6; x < size.width - 6; x += 8) {
      canvas.drawLine(Offset(x, ty), Offset(x + 4, ty), dash);
    }
    canvas.restore();

    canvas.drawRRect(
      body.deflate(0.75),
      Paint()
        ..color = AppPalette.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
