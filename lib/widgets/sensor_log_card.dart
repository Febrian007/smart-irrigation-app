import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';

class SensorLogCard extends StatelessWidget {
  final List<SensorLogEntry> logs;

  const SensorLogCard({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final visibleLogs = logs.take(8).toList();

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
                  Icons.history_rounded,
                  color: AppPalette.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Riwayat Pembacaan Terbaru',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppPalette.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppPalette.border),
                ),
                child: Text(
                  '${logs.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textSecondary,
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Belum ada data. Hubungkan ESP32 atau aktifkan Mode Simulasi.',
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 12,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleLogs.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 14, color: AppPalette.divider),
              itemBuilder: (context, index) {
                final e = visibleLogs[index];
                final t =
                    '${e.time.hour.toString().padLeft(2, '0')}:'
                    '${e.time.minute.toString().padLeft(2, '0')}:'
                    '${e.time.second.toString().padLeft(2, '0')}';

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.primarySoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        t,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Suhu ${e.temperature.toStringAsFixed(1)}°C · '
                        'RH ${e.humidity.toStringAsFixed(1)}% · '
                        'Tanah ${e.soilMoisture.toStringAsFixed(1)}% · '
                        'Air ${e.waterLevel.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppPalette.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: e.pumpOn
                            ? AppPalette.mintSoft
                            : AppPalette.background,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        e.pumpOn ? 'ON' : 'OFF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: e.pumpOn
                              ? AppPalette.mint
                              : AppPalette.textMuted,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
