class SensorLogEntry {
  final DateTime time;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double waterLevel;
  final bool pumpOn;

  const SensorLogEntry({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.waterLevel,
    required this.pumpOn,
  });
}

enum ConnectionHealth {
  disconnected,
  connecting,
  connected,
  reconnecting,
  simulation,
}

enum ConnectionMode { local, firebase }

class IrrigationState {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double waterLevel;
  final String pumpMode;
  final bool irrigationPumpOn;
  final int pumpActiveSec;
  final double soilThreshold;
  final double tankThreshold;
  final ConnectionMode connectionMode;
  final ConnectionHealth connectionHealth;
  final String connectionLabel;
  final bool isSimulation;
  final List<SensorLogEntry> logs;

  const IrrigationState({
    this.temperature = 0.0,
    this.humidity = 0.0,
    this.soilMoisture = 0.0,
    this.waterLevel = 0.0,
    this.pumpMode = 'AUTO',
    this.irrigationPumpOn = false,
    this.pumpActiveSec = 0,
    this.soilThreshold = 38.0,
    this.tankThreshold = 10.0,
    this.connectionMode = ConnectionMode.local,
    this.connectionHealth = ConnectionHealth.disconnected,
    this.connectionLabel = 'Belum Terhubung',
    this.isSimulation = false,
    this.logs = const [],
  });

  /// Ada data sensor yang sedang mengalir (terhubung atau simulasi).
  bool get isLive =>
      isSimulation || connectionHealth == ConnectionHealth.connected;

  bool get isTankLow => waterLevel < tankThreshold && isLive;

  IrrigationState copyWith({
    double? temperature,
    double? humidity,
    double? soilMoisture,
    double? waterLevel,
    String? pumpMode,
    bool? irrigationPumpOn,
    int? pumpActiveSec,
    double? soilThreshold,
    double? tankThreshold,
    ConnectionMode? connectionMode,
    ConnectionHealth? connectionHealth,
    String? connectionLabel,
    bool? isSimulation,
    List<SensorLogEntry>? logs,
  }) {
    return IrrigationState(
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      waterLevel: waterLevel ?? this.waterLevel,
      pumpMode: pumpMode ?? this.pumpMode,
      irrigationPumpOn: irrigationPumpOn ?? this.irrigationPumpOn,
      pumpActiveSec: pumpActiveSec ?? this.pumpActiveSec,
      soilThreshold: soilThreshold ?? this.soilThreshold,
      tankThreshold: tankThreshold ?? this.tankThreshold,
      connectionMode: connectionMode ?? this.connectionMode,
      connectionHealth: connectionHealth ?? this.connectionHealth,
      connectionLabel: connectionLabel ?? this.connectionLabel,
      isSimulation: isSimulation ?? this.isSimulation,
      logs: logs ?? this.logs,
    );
  }

  IrrigationState mergeFromJson(
    Map<String, dynamic> map, {
    bool addLog = false,
  }) {
    final nextTemp = (map['temperature'] as num?)?.toDouble() ?? temperature;
    final nextHum = (map['humidity'] as num?)?.toDouble() ?? humidity;
    final nextSoil = (map['soil_moisture'] as num?)?.toDouble() ?? soilMoisture;
    final nextWater = (map['water_level'] as num?)?.toDouble() ?? waterLevel;
    final nextPumpOn = (map['irrigation_pump'] as bool?) ?? irrigationPumpOn;

    List<SensorLogEntry> nextLogs = logs;
    if (addLog) {
      nextLogs = [
        SensorLogEntry(
          time: DateTime.now(),
          temperature: nextTemp,
          humidity: nextHum,
          soilMoisture: nextSoil,
          waterLevel: nextWater,
          pumpOn: nextPumpOn,
        ),
        ...logs,
      ].take(30).toList();
    }

    return copyWith(
      temperature: nextTemp,
      humidity: nextHum,
      soilMoisture: nextSoil,
      waterLevel: nextWater,
      pumpMode: (map['pump_mode'] as String?) ?? pumpMode,
      irrigationPumpOn: nextPumpOn,
      pumpActiveSec: (map['pump_active_sec'] as num?)?.toInt() ?? pumpActiveSec,
      soilThreshold:
          (map['soil_threshold'] as num?)?.toDouble() ?? soilThreshold,
      tankThreshold:
          (map['tank_threshold'] as num?)?.toDouble() ?? tankThreshold,
      logs: nextLogs,
    );
  }
}
