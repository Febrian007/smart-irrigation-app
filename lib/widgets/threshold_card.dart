import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';

class ThresholdCard extends StatelessWidget {
  final double soilThreshold;
  final double tankThreshold;
  final ValueChanged<double> onSoilChanged;
  final ValueChanged<double> onTankChanged;
  final VoidCallback onSave;

  const ThresholdCard({
    super.key,
    required this.soilThreshold,
    required this.tankThreshold,
    required this.onSoilChanged,
    required this.onTankChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppPalette.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppPalette.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kalibrasi Ambang Batas',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppPalette.textPrimary,
                    ),
                  ),
                  Text(
                    'Atur batas otomatis pompa & peringatan tangki',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ThresholdSliderHeader(
            label: 'Ambang Kelembapan Tanah',
            valueText: '${soilThreshold.toStringAsFixed(0)}%',
          ),
          Slider(
            value: soilThreshold,
            min: 10,
            max: 85,
            divisions: 75,
            label: '${soilThreshold.toStringAsFixed(0)}%',
            onChanged: onSoilChanged,
          ),
          const SizedBox(height: 6),
          _ThresholdSliderHeader(
            label: 'Ambang Level Air Tangki',
            valueText: '${tankThreshold.toStringAsFixed(0)}%',
          ),
          Slider(
            value: tankThreshold,
            min: 5,
            max: 50,
            divisions: 45,
            label: '${tankThreshold.toStringAsFixed(0)}%',
            onChanged: onTankChanged,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSave,
              child: const Text('Simpan Ambang ke ESP32'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThresholdSliderHeader extends StatelessWidget {
  final String label;
  final String valueText;

  const _ThresholdSliderHeader({
    required this.label,
    required this.valueText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppPalette.primarySoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            valueText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}
