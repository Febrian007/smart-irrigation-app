import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/irrigation_state.dart';
import '../services/esp32_sse_service.dart';

class IrrigationController extends ChangeNotifier {
  final Esp32SseService _service;
  final Random _rng = Random();

  IrrigationState _state = const IrrigationState();
  IrrigationState get state => _state;

  Timer? _reconnectTimer;
  Timer? _demoTimer;
  String _currentBaseUrl = 'http://192.168.43.135';
  bool _disposed = false;

  IrrigationController({Esp32SseService? service})
      : _service = service ?? Esp32SseService();

  void _update(IrrigationState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  void setConnectionMode(ConnectionMode mode) {
    if (_state.connectionMode == mode) return;
    _reconnectTimer?.cancel();
    _service.disconnect();
    _update(_state.copyWith(
      connectionMode: mode,
      connectionHealth: ConnectionHealth.disconnected,
      connectionLabel: 'Belum Terhubung',
    ));
  }

  Future<void> connect(String baseUrl) async {
    _currentBaseUrl = baseUrl;
    if (_state.isSimulation) {
      toggleSimulation(false);
    }
    _reconnectTimer?.cancel();

    final isFirebase = _state.connectionMode == ConnectionMode.firebase;
    _update(_state.copyWith(
      connectionHealth: ConnectionHealth.connecting,
      connectionLabel: isFirebase ? 'Menghubungkan Firebase...' : 'Menghubungkan SSE...',
    ));

    await _service.connect(
      baseUrl: _currentBaseUrl,
      isFirebase: isFirebase,
      onOpen: () {
        _update(_state.copyWith(
          connectionHealth: ConnectionHealth.connected,
          connectionLabel: isFirebase ? 'Terhubung (Firebase)' : 'Terhubung (SSE Live)',
        ));
      },
      onEvent: _handleSseEvent,
      onDisconnected: _scheduleReconnect,
    );
  }

  void _scheduleReconnect() {
    if (_disposed || _state.isSimulation) return;
    _service.disconnect();
    _update(_state.copyWith(
      connectionHealth: ConnectionHealth.reconnecting,
      connectionLabel: 'Putus • Menyambung ulang...',
    ));
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 4), () {
      if (!_disposed && !_state.isSimulation) {
        connect(_currentBaseUrl);
      }
    });
  }

  void _handleSseEvent(SseEvent event) {
    switch (event.name) {
      case 'temperature':
        _update(_state.copyWith(
          temperature: double.tryParse(event.data) ?? _state.temperature,
        ));
        break;
      case 'humidity':
        _update(_state.copyWith(
          humidity: double.tryParse(event.data) ?? _state.humidity,
        ));
        break;
      case 'soil_moisture':
        _update(_state.copyWith(
          soilMoisture: double.tryParse(event.data) ?? _state.soilMoisture,
        ));
        break;
      case 'water_level':
        _update(_state.copyWith(
          waterLevel: double.tryParse(event.data) ?? _state.waterLevel,
        ));
        break;
      case 'status':
        try {
          final map = jsonDecode(event.data) as Map<String, dynamic>;
          _update(_state.mergeFromJson(map, addLog: true));
        } catch (_) {}
        break;
      case 'put':
      case 'patch':
        _handleFirebaseEvent(event.data);
        break;
    }
  }

  void _handleFirebaseEvent(String payload) {
    try {
      final msg = jsonDecode(payload);
      if (msg is! Map<String, dynamic> || msg['data'] == null) return;
      final path = msg['path'] as String? ?? '/';
      final data = msg['data'];
      if (data is! Map<String, dynamic>) return;

      if (path == '/') {
        var next = _state;
        if (data['live'] is Map<String, dynamic>) {
          next = next.mergeFromJson(data['live'] as Map<String, dynamic>, addLog: true);
        }
        if (data['control'] is Map<String, dynamic>) {
          next = next.mergeFromJson(data['control'] as Map<String, dynamic>);
        }
        _update(next);
      } else if (path == '/live') {
        _update(_state.mergeFromJson(data, addLog: true));
      } else if (path == '/control') {
        _update(_state.mergeFromJson(data));
      }
    } catch (_) {}
  }

  void toggleSimulation(bool enable) {
    _demoTimer?.cancel();
    if (!enable) {
      _update(_state.copyWith(
        isSimulation: false,
        connectionHealth: ConnectionHealth.disconnected,
        connectionLabel: 'Belum Terhubung',
      ));
      return;
    }

    _reconnectTimer?.cancel();
    _service.disconnect();
    _update(_state.copyWith(
      isSimulation: true,
      connectionHealth: ConnectionHealth.simulation,
      connectionLabel: 'Mode Simulasi Aktif',
      temperature: 26.4,
      humidity: 44.5,
      soilMoisture: 42.0,
      waterLevel: 61.0,
      pumpMode: 'AUTO',
      irrigationPumpOn: false,
    ));

    _demoTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      var soil = _state.soilMoisture;
      var water = _state.waterLevel;
      var activeSec = _state.pumpActiveSec;
      var pumpOn = _state.irrigationPumpOn;

      if (pumpOn) {
        soil = min(70.0, soil + 2.4);
        water = max(5.0, water - 0.8);
        activeSec += 2;
      } else {
        soil = max(20.0, soil - 1.5);
      }

      if (_state.pumpMode == 'AUTO') {
        pumpOn = soil < _state.soilThreshold;
      }

      final temp = 24.0 + _rng.nextDouble() * 4.5;
      final hum = 40.0 + _rng.nextDouble() * 11.0;

      final nextLogs = [
        SensorLogEntry(
          time: DateTime.now(),
          temperature: temp,
          humidity: hum,
          soilMoisture: soil,
          waterLevel: water,
          pumpOn: pumpOn,
        ),
        ..._state.logs,
      ].take(12).toList();

      _update(_state.copyWith(
        temperature: temp,
        humidity: hum,
        soilMoisture: soil,
        waterLevel: water,
        irrigationPumpOn: pumpOn,
        pumpActiveSec: activeSec,
        logs: nextLogs,
      ));
    });
  }

  void updateLocalThresholds({double? soil, double? tank}) {
    _update(_state.copyWith(
      soilThreshold: soil,
      tankThreshold: tank,
    ));
  }

  Future<void> setPumpMode(String baseUrl, String command) async {
    if (_state.isSimulation) {
      final mode = command == 'on'
          ? 'MANUAL_ON'
          : command == 'off'
              ? 'MANUAL_OFF'
              : 'AUTO';
      final pumpOn = command == 'on'
          ? true
          : command == 'off'
              ? false
              : _state.soilMoisture < _state.soilThreshold;
      _update(_state.copyWith(pumpMode: mode, irrigationPumpOn: pumpOn));
      return;
    }

    if (_state.connectionMode == ConnectionMode.firebase) {
      final mode = command == 'on'
          ? 'MANUAL_ON'
          : command == 'off'
              ? 'MANUAL_OFF'
              : 'AUTO';
      await _service.patchFirebaseControl(baseUrl, {'pump_mode': mode});
      _update(_state.copyWith(pumpMode: mode));
      return;
    }

    final map = await _service.sendPumpCommand(baseUrl, command);
    _update(_state.mergeFromJson(map));
  }

  Future<void> saveThresholds(String baseUrl) async {
    if (_state.isSimulation) {
      if (_state.pumpMode == 'AUTO') {
        _update(_state.copyWith(
          irrigationPumpOn: _state.soilMoisture < _state.soilThreshold,
        ));
      }
      return;
    }

    if (_state.connectionMode == ConnectionMode.firebase) {
      await _service.patchFirebaseControl(baseUrl, {
        'soil_threshold': _state.soilThreshold.roundToDouble(),
        'tank_threshold': _state.tankThreshold.roundToDouble(),
      });
      return;
    }

    final map = await _service.saveThresholds(
      baseUrl,
      soil: _state.soilThreshold,
      tank: _state.tankThreshold,
    );
    _update(_state.mergeFromJson(map));
  }

  @override
  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _demoTimer?.cancel();
    _service.disconnect();
    super.dispose();
  }
}
