import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import 'sensor_meta.dart';

Path buildSmoothPath(List<Offset> p) {
  final path = Path()..moveTo(p.first.dx, p.first.dy);
  for (var i = 1; i < p.length; i++) {
    final a = p[i - 1];
    final b = p[i];
    final mx = (a.dx + b.dx) / 2;
    path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
  }
  return path;
}

/// Grafik mini tanpa sumbu untuk tren singkat di dalam kartu.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const Sparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(values, color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final n = values.length;
    if (n < 2) {
      final y = size.height / 2;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
      return;
    }
    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    if (hi - lo < 1) {
      final mid = (hi + lo) / 2;
      lo = mid - 0.5;
      hi = mid + 0.5;
    }
    const pad = 4.0;
    final w = size.width - pad;
    final h = size.height - 2 * pad;
    final pts = [
      for (var i = 0; i < n; i++)
        Offset(w * i / (n - 1), pad + h * (1 - (values[i] - lo) / (hi - lo))),
    ];
    final line = buildSmoothPath(pts);
    final fill = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(0, size.height), [
          color.withValues(alpha: 0.30),
          color.withValues(alpha: 0),
        ]),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawCircle(pts.last, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => true;
}

/// Grafik riwayat interaktif: geser jari di atas grafik untuk membaca nilai.
class HistoryChart extends StatefulWidget {
  final List<double> values;
  final List<DateTime> times;
  final Color color;
  final String unit;
  final double? threshold;
  final double height;

  const HistoryChart({
    super.key,
    required this.values,
    required this.times,
    required this.color,
    required this.unit,
    this.threshold,
    this.height = 180,
  });

  @override
  State<HistoryChart> createState() => _HistoryChartState();
}

class _HistoryChartState extends State<HistoryChart> {
  int? _selected;

  void _pick(double dx, double width) {
    final n = widget.values.length;
    if (n < 2) return;
    final plotW = width - _HistoryPainter.padL - _HistoryPainter.padR;
    final i = (((dx - _HistoryPainter.padL) / plotW) * (n - 1)).round().clamp(
      0,
      n - 1,
    );
    if (i != _selected) {
      HapticFeedback.selectionClick();
      setState(() => _selected = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.values.length;
    final sel = n == 0 ? null : (_selected ?? n - 1).clamp(0, n - 1);
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        return Semantics(
          label: 'Grafik riwayat, geser untuk membaca nilai',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => _pick(d.localPosition.dx, w),
            onHorizontalDragStart: (d) => _pick(d.localPosition.dx, w),
            onHorizontalDragUpdate: (d) => _pick(d.localPosition.dx, w),
            child: CustomPaint(
              size: Size(w, widget.height),
              painter: _HistoryPainter(
                values: widget.values,
                times: widget.times,
                color: widget.color,
                unit: widget.unit,
                threshold: widget.threshold,
                selected: sel,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryPainter extends CustomPainter {
  static const padL = 34.0;
  static const padR = 12.0;
  static const padT = 34.0;
  static const padB = 8.0;

  final List<double> values;
  final List<DateTime> times;
  final Color color;
  final String unit;
  final double? threshold;
  final int? selected;

  _HistoryPainter({
    required this.values,
    required this.times,
    required this.color,
    required this.unit,
    required this.threshold,
    required this.selected,
  });

  TextPainter _tp(String text, Color c, {double size = 10, FontWeight? w}) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: c, fontSize: size, fontWeight: w),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(
      padL,
      padT,
      size.width - padR,
      size.height - padB,
    );
    final n = values.length;
    if (n < 2) {
      final tp = _tp('Menunggu data sensor…', AppPalette.textMuted, size: 12);
      tp.paint(
        canvas,
        Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
      );
      return;
    }

    var lo = values.reduce(math.min);
    var hi = values.reduce(math.max);
    final thr = threshold;
    if (thr != null) {
      lo = math.min(lo, thr);
      hi = math.max(hi, thr);
    }
    final span = math.max(hi - lo, 1.0);
    lo -= span * 0.15;
    hi += span * 0.15;

    double y(double v) => plot.bottom - plot.height * (v - lo) / (hi - lo);
    double x(int i) => plot.left + plot.width * i / (n - 1);

    final grid = Paint()
      ..color = AppPalette.border
      ..strokeWidth = 1;
    for (final f in const [0.0, 0.5, 1.0]) {
      final v = lo + (hi - lo) * f;
      final gy = y(v);
      canvas.drawLine(Offset(plot.left, gy), Offset(plot.right, gy), grid);
      final tp = _tp(v.toStringAsFixed(0), AppPalette.textMuted);
      tp.paint(canvas, Offset(plot.left - tp.width - 6, gy - tp.height / 2));
    }

    if (thr != null) {
      final ty = y(thr);
      final dash = Paint()
        ..color = AppPalette.amber
        ..strokeWidth = 1.5;
      for (var dx = plot.left; dx < plot.right; dx += 9) {
        canvas.drawLine(
          Offset(dx, ty),
          Offset(math.min(dx + 5, plot.right), ty),
          dash,
        );
      }
      final tp = _tp('Ambang', AppPalette.amber, w: FontWeight.w700);
      tp.paint(canvas, Offset(plot.right - tp.width, ty - tp.height - 2));
    }

    final pts = [for (var i = 0; i < n; i++) Offset(x(i), y(values[i]))];
    final line = buildSmoothPath(pts);
    final fill = Path.from(line)
      ..lineTo(plot.right, plot.bottom)
      ..lineTo(plot.left, plot.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = ui.Gradient.linear(plot.topLeft, plot.bottomLeft, [
          color.withValues(alpha: 0.32),
          color.withValues(alpha: 0),
        ]),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final sel = selected;
    if (sel == null) return;
    final p = pts[sel];
    canvas.drawLine(
      Offset(p.dx, padT - 4),
      Offset(p.dx, plot.bottom),
      Paint()
        ..color = AppPalette.textMuted.withValues(alpha: 0.6)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(p, 7, Paint()..color = AppPalette.surface);
    canvas.drawCircle(p, 4.5, Paint()..color = color);

    final label =
        '${values[sel].toStringAsFixed(1)}$unit  ·  ${formatClock(times[sel])}';
    final tp = _tp(
      label,
      AppPalette.textPrimary,
      size: 11.5,
      w: FontWeight.w700,
    );
    final bw = tp.width + 18;
    const bh = 24.0;
    final left = (p.dx - bw / 2).clamp(0.0, size.width - bw);
    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, 0, bw, bh),
      const Radius.circular(8),
    );
    canvas.drawRRect(bubble, Paint()..color = AppPalette.surfaceHigh);
    canvas.drawRRect(
      bubble,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(left + 9, (bh - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_HistoryPainter old) => true;
}
