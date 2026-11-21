import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import 'ui_kit.dart';

String formatPumpDuration(int sec) {
  if (sec < 60) return '$sec dtk';
  final m = sec ~/ 60;
  final s = sec % 60;
  return '$m mnt $s dtk';
}

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
    final mode = pumpMode.toUpperCase();
    final isAuto = mode == 'AUTO';
    final selected = isAuto
        ? 0
        : mode.endsWith('_ON')
        ? 1
        : mode.endsWith('_OFF')
        ? 2
        : (pumpOn ? 1 : 2);

    return AppCard(
      glow: pumpOn ? AppPalette.mint : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PumpOrb(on: pumpOn),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pompa Siram',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppPalette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mode ${isAuto ? 'AUTO' : 'MANUAL'} · aktif '
                      '${formatPumpDuration(pumpActiveSec)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(
                label: pumpOn ? 'POMPA ON' : 'POMPA OFF',
                color: pumpOn ? AppPalette.mint : AppPalette.textSecondary,
                pulse: pumpOn,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ModeSegment(
            selected: selected,
            onSelect: (i) => onCommand(const ['auto', 'on', 'off'][i]),
          ),
        ],
      ),
    );
  }
}

/// Bulatan pompa: riak air menyebar selama pompa menyala.
class _PumpOrb extends StatefulWidget {
  final bool on;

  const _PumpOrb({required this.on});

  @override
  State<_PumpOrb> createState() => _PumpOrbState();
}

class _PumpOrbState extends State<_PumpOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  @override
  void initState() {
    super.initState();
    if (widget.on) _c.repeat();
  }

  @override
  void didUpdateWidget(_PumpOrb old) {
    super.didUpdateWidget(old);
    if (widget.on && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.on && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.on ? AppPalette.mint : AppPalette.textMuted;
    return SizedBox(
      width: 52,
      height: 52,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => CustomPaint(
          painter: _RipplePainter(t: _c.value, color: color, active: widget.on),
          child: child,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Icon(
              widget.on
                  ? Icons.water_drop_rounded
                  : Icons.power_settings_new_rounded,
              key: ValueKey(widget.on),
              color: widget.on ? AppPalette.onAccent : AppPalette.textSecondary,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double t;
  final Color color;
  final bool active;

  _RipplePainter({required this.t, required this.color, required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.shortestSide / 2;
    const core = 17.0;
    if (active) {
      for (var i = 0; i < 2; i++) {
        final p = (t + i * 0.5) % 1.0;
        canvas.drawCircle(
          c,
          core + (maxR - core) * p,
          Paint()..color = color.withValues(alpha: (1 - p) * 0.4),
        );
      }
    }
    canvas.drawCircle(
      c,
      core,
      Paint()..color = active ? color : AppPalette.surfaceHigh,
    );
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.t != t || old.color != color || old.active != active;
}

/// Tiga pilihan mode dengan penanda yang meluncur ke pilihan aktif.
class _ModeSegment extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _ModeSegment({required this.selected, required this.onSelect});

  static const _labels = ['AUTO', 'ON', 'OFF'];
  static const _icons = [
    Icons.autorenew_rounded,
    Icons.power_settings_new_rounded,
    Icons.stop_circle_outlined,
  ];
  static const _colors = [
    AppPalette.primary,
    AppPalette.mint,
    AppPalette.coral,
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[selected];
    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(selected - 1.0, 0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            child: FractionallySizedBox(
              widthFactor: 1 / 3,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < 3; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selected,
                    label: 'Mode pompa ${_labels[i]}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        onSelect(i);
                      },
                      child: Center(
                        child: _SegmentLabel(
                          icon: _icons[i],
                          label: _labels[i],
                          color: i == selected
                              ? AppPalette.onAccent
                              : AppPalette.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SegmentLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: color,
          ),
        ),
      ],
    );
  }
}
