import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';

class SensorGrid extends StatelessWidget {
  final IrrigationState state;

  const SensorGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final soilDry = state.soilMoisture < state.soilThreshold;
    final tankLow = state.waterLevel < state.tankThreshold;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.42,
      children: [
        _SensorCard(
          title: 'Temperature',
          value: '${state.temperature.toStringAsFixed(1)} °C',
          icon: Icons.thermostat_rounded,
          accentColor: AppPalette.amber,
          accentSoftColor: AppPalette.amberSoft,
          badgeText: state.temperature > 35 ? 'Panas' : 'Normal',
          badgeColor: state.temperature > 35 ? AppPalette.coral : AppPalette.mint,
          badgeSoftColor:
              state.temperature > 35 ? AppPalette.coralSoft : AppPalette.mintSoft,
          subtitle: 'Suhu lingkungan',
        ),
        _SensorCard(
          title: 'Humidity',
          value: '${state.humidity.toStringAsFixed(1)} %',
          icon: Icons.water_drop_rounded,
          accentColor: AppPalette.sky,
          accentSoftColor: AppPalette.skySoft,
          badgeText: 'Udara',
          badgeColor: AppPalette.primary,
          badgeSoftColor: AppPalette.primarySoft,
          progress: (state.humidity / 100).clamp(0.0, 1.0),
        ),
        _SensorCard(
          title: 'Soil Moisture',
          value: '${state.soilMoisture.toStringAsFixed(1)} %',
          icon: Icons.grass_rounded,
          accentColor: soilDry ? AppPalette.amber : AppPalette.mint,
          accentSoftColor: soilDry ? AppPalette.amberSoft : AppPalette.mintSoft,
          badgeText: soilDry ? 'Kering' : 'Lembap',
          badgeColor: soilDry ? AppPalette.amber : AppPalette.mint,
          badgeSoftColor: soilDry ? AppPalette.amberSoft : AppPalette.mintSoft,
          subtitle: 'Ambang < ${state.soilThreshold.toStringAsFixed(0)}%',
          progress: (state.soilMoisture / 100).clamp(0.0, 1.0),
        ),
        _SensorCard(
          title: 'Water Level',
          value: '${state.waterLevel.toStringAsFixed(1)} %',
          icon: Icons.waves_rounded,
          accentColor: tankLow ? AppPalette.coral : AppPalette.primary,
          accentSoftColor: tankLow ? AppPalette.coralSoft : AppPalette.primarySoft,
          badgeText: tankLow ? 'Rendah' : 'Aman',
          badgeColor: tankLow ? AppPalette.coral : AppPalette.mint,
          badgeSoftColor: tankLow ? AppPalette.coralSoft : AppPalette.mintSoft,
          subtitle: 'Ambang < ${state.tankThreshold.toStringAsFixed(0)}%',
          progress: (state.waterLevel / 100).clamp(0.0, 1.0),
        ),
      ],
    );
  }
}

class _SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color accentSoftColor;
  final String badgeText;
  final Color badgeColor;
  final Color badgeSoftColor;
  final String? subtitle;
  final double? progress;

  const _SensorCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentSoftColor,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeSoftColor,
    this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentSoftColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeSoftColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppPalette.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (progress != null) ...[
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppPalette.background,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
