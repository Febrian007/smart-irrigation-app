import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';

/// Kartu dasar: permukaan gelap, sudut besar, dan cahaya (glow) opsional.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glow;
  final VoidCallback? onTap;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glow,
    this.onTap,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final glowColor = glow;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: glowColor != null
              ? glowColor.withValues(alpha: 0.45)
              : AppPalette.border,
        ),
        boxShadow: [
          if (glowColor != null)
            BoxShadow(
              color: glowColor.withValues(alpha: 0.22),
              blurRadius: 28,
              spreadRadius: -6,
            ),
        ],
      ),
      child: child,
    );
    final tap = onTap;
    if (tap == null) return card;
    return Pressable(onTap: tap, child: card);
  }
}

/// Efek tekan: mengecil sedikit + getaran halus saat diketuk.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const Pressable({super.key, required this.child, required this.onTap});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Angka yang bergulir halus menuju nilai baru.
class AnimatedNumber extends StatelessWidget {
  final double value;
  final int digits;
  final TextStyle style;
  final bool placeholder;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.style,
    this.digits = 1,
    this.placeholder = false,
  });

  @override
  Widget build(BuildContext context) {
    if (placeholder) return Text('--', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Text(v.toStringAsFixed(digits), style: style),
    );
  }
}

/// Titik status dengan cincin berdenyut.
class PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool active;

  const PulseDot({
    super.key,
    required this.color,
    this.size = 7,
    this.active = true,
  });

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(PulseDot old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.active && _c.isAnimating) {
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
    final box = widget.size * 2.4;
    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = _c.value;
          final ring = widget.size * (1 + 1.4 * t);
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.active)
                Container(
                  width: ring,
                  height: ring,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: (1 - t) * 0.45),
                  ),
                ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulse;
  final bool showDot;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
    this.pulse = false,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.fromLTRB(showDot ? 5 : 10, 4, 10, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            PulseDot(color: color, size: 6, active: pulse),
            const SizedBox(width: 3),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// Pegangan kecil di atas bottom sheet.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppPalette.border,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
