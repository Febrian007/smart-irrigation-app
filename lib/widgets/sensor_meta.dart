import 'package:material_ui/material_ui.dart';

import '../models/irrigation_state.dart';
import '../theme/app_palette.dart';

enum SensorKind { soil, temperature, humidity, water }

extension SensorKindInfo on SensorKind {
  String get label => switch (this) {
    SensorKind.soil => 'Soil Moisture',
    SensorKind.temperature => 'Temperature',
    SensorKind.humidity => 'Humidity',
    SensorKind.water => 'Water Level',
  };

  String get shortLabel => switch (this) {
    SensorKind.soil => 'Tanah',
    SensorKind.temperature => 'Suhu',
    SensorKind.humidity => 'Udara',
    SensorKind.water => 'Air',
  };

  String get unit => this == SensorKind.temperature ? '°C' : '%';

  IconData get icon => switch (this) {
    SensorKind.soil => Icons.grass_rounded,
    SensorKind.temperature => Icons.thermostat_rounded,
    SensorKind.humidity => Icons.water_drop_rounded,
    SensorKind.water => Icons.waves_rounded,
  };

  Color get color => switch (this) {
    SensorKind.soil => AppPalette.mint,
    SensorKind.temperature => AppPalette.amber,
    SensorKind.humidity => AppPalette.sky,
    SensorKind.water => AppPalette.primary,
  };

  double read(SensorLogEntry e) => switch (this) {
    SensorKind.soil => e.soilMoisture,
    SensorKind.temperature => e.temperature,
    SensorKind.humidity => e.humidity,
    SensorKind.water => e.waterLevel,
  };

  double current(IrrigationState s) => switch (this) {
    SensorKind.soil => s.soilMoisture,
    SensorKind.temperature => s.temperature,
    SensorKind.humidity => s.humidity,
    SensorKind.water => s.waterLevel,
  };

  double? threshold(IrrigationState s) => switch (this) {
    SensorKind.soil => s.soilThreshold,
    SensorKind.water => s.tankThreshold,
    _ => null,
  };
}

/// Deret nilai dari log, urut lama → baru (log disimpan baru → lama).
List<double> seriesOf(List<SensorLogEntry> logs, SensorKind kind) =>
    logs.reversed.map(kind.read).toList();

List<DateTime> timesOf(List<SensorLogEntry> logs) =>
    logs.reversed.map((e) => e.time).toList();

String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:'
    '${t.minute.toString().padLeft(2, '0')}:'
    '${t.second.toString().padLeft(2, '0')}';
