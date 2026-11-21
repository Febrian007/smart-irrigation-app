import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import 'ui_kit.dart';

class ThresholdCard extends StatelessWidget {
  final double soilThreshold;
  final double tankThreshold;
  final double soilMoisture;
  final double waterLevel;
  final bool live;
  final ValueChanged<double> onSoilChanged;
  final ValueChanged<double> onTankChanged;
  final VoidCallback onSave;

  const ThresholdCard({
    super.key,
    required this.soilThreshold,
    required this.tankThreshold,
    required this.soilMoisture,
    required this.waterLevel,
    required this.live,
    required this.onSoilChanged,
    required this.onTankChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final soilDry = soilMoisture < soilThreshold;
    final tankLow = waterLevel < tankThreshold;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              IconBadge(icon: Icons.tune_rounded, color: AppPalette.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalibrasi Ambang Batas',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppPalette.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur batas otomatis pompa & peringatan tangki',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ThresholdSection(
            label: 'Ambang Kelembapan Tanah',
            color: AppPalette.mint,
            alertColor: AppPalette.amber,
            threshold: soilThreshold,
            current: soilMoisture,
            live: live,
            below: soilDry,
            min: 10,
            max: 85,
            onChanged: onSoilChanged,
            hint: !live
                ? 'Pompa AUTO menyala bila kelembapan tanah di bawah ambang ini.'
                : soilDry
                ? 'Saat ini ${soilMoisture.toStringAsFixed(1)}%, di bawah '
                      'ambang: pompa AUTO menyala.'
                : 'Saat ini ${soilMoisture.toStringAsFixed(1)}%, di atas '
                      'ambang: pompa AUTO mati.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppPalette.divider),
          ),
          _ThresholdSection(
            label: 'Ambang Level Air Tangki',
            color: AppPalette.primary,
            alertColor: AppPalette.coral,
            threshold: tankThreshold,
            current: waterLevel,
            live: live,
            below: tankLow,
            min: 5,
            max: 50,
            onChanged: onTankChanged,
            hint: !live
                ? 'Peringatan muncul bila level air tangki di bawah ambang ini.'
                : tankLow
                ? 'Saat ini ${waterLevel.toStringAsFixed(1)}%, di bawah '
                      'ambang: peringatan aktif.'
                : 'Saat ini ${waterLevel.toStringAsFixed(1)}%, tangki masih '
                      'aman.',
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text('Simpan Ambang ke ESP32'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdSection extends StatelessWidget {
  final String label;
  final Color color;
  final Color alertColor;
  final double threshold;
  final double current;
  final bool live;
  final bool below;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String hint;

  const _ThresholdSection({
    required this.label,
    required this.color,
    required this.alertColor,
    required this.threshold,
    required this.current,
    required this.live,
    required this.below,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final active = live && below ? alertColor : color;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textPrimary,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedNumber(
                  value: threshold,
                  digits: 0,
                  style: TextStyle(
                    fontSize: 26,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: -0.5,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            overlayColor: color.withValues(alpha: 0.18),
            valueIndicatorColor: color,
          ),
          child: Slider(
            value: threshold.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: '${threshold.toStringAsFixed(0)}%',
            semanticFormatterCallback: (v) => '${v.round()} persen',
            onChanged: onChanged,
          ),
        ),
        _LevelBar(
          value: live ? current : null,
          threshold: threshold,
          color: active,
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: TextStyle(
            fontSize: 12,
            height: 1.35,
            color: live && below ? alertColor : AppPalette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Batang 0–100%: isi = pembacaan saat ini, garis putih = ambang.
class _LevelBar extends StatelessWidget {
  final double? value;
  final double threshold;
  final Color color;

  const _LevelBar({
    required this.value,
    required this.threshold,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final v = value;
    return SizedBox(
      height: 18,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 6,
                height: 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppPalette.surfaceHigh,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (v != null)
                Positioned(
                  left: 0,
                  top: 6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    width: w * (v / 100).clamp(0.0, 1.0),
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              Positioned(
                left: (w * threshold / 100 - 1.5).clamp(0.0, w - 3),
                top: 0,
                child: Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppPalette.textPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
