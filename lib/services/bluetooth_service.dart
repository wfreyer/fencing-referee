import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
  reconnecting,
}

class WeaponDevice {
  final String id;
  final String name;
  final int fencerNumber;
  DeviceConnectionState state;
  int lastScore;
  DateTime lastUpdate;
  bool canScore;
  int reconnectAttempts;
  DateTime? lastConnectionAttempt;

  WeaponDevice({
    required this.id,
    required this.name,
    required this.fencerNumber,
    this.state = DeviceConnectionState.disconnected,
    this.lastScore = 0,
    DateTime? lastUpdate,
    this.canScore = true,
    this.reconnectAttempts = 0,
    this.lastConnectionAttempt,
  }) : lastUpdate = lastUpdate ?? DateTime.now();
}

class BluetoothService {
  final _connectionStateController = StreamController<DeviceConnectionState>.broadcast();
  final _scoreController = StreamController<Map<String, dynamic>>.broadcast();
  final _weaponsController = StreamController<List<WeaponDevice>>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  
  List<WeaponDevice> _connectedWeapons = [];
  bool _isHit1 = false;
  bool _isHit2 = false;
  Timer? _reconnectionTimer;
  static const _maxReconnectAttempts = 5;
  static const _reconnectDelay = Duration(seconds: 5);

  // Getters for current state
  bool get isHit1 => _isHit1;
  bool get isHit2 => _isHit2;
  List<WeaponDevice> get connectedWeapons => List.unmodifiable(_connectedWeapons);

  // Streams for reactive updates
  Stream<DeviceConnectionState> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get scoreUpdates => _scoreController.stream;
  Stream<List<WeaponDevice>> get weapons => _weaponsController.stream;
  Stream<String> get errors => _errorController.stream;

  Timer? _simulationTimer;
  DateTime? _lastHitTime;
  static const _priorityWindow = Duration(milliseconds: 200); // 0.2 seconds priority window
  static const _scoringDelay = Duration(seconds: 5); // 5 seconds delay before scoring resumes

  // Simulation scenarios
  int _currentScenario = 0;
  final List<Map<String, dynamic>> _scenarios = [
    {
      'name': 'Fencer 1 hits',
      'hits': [
        {'fencer': 1, 'delay': 0},
      ],
    },
    {
      'name': 'Fencer 2 hits',
      'hits': [
        {'fencer': 2, 'delay': 0},
      ],
    },
    {
      'name': 'Both hit within 0.2s',
      'hits': [
        {'fencer': 1, 'delay': 0},
        {'fencer': 2, 'delay': 100}, // 100ms after first hit
      ],
    },
    {
      'name': 'Second hit after 1s',
      'hits': [
        {'fencer': 1, 'delay': 0},
        {'fencer': 2, 'delay': 1000}, // 1s after first hit
      ],
    },
  ];

  void initialize() {
    // Initialize Bluetooth service
    _connectionStateController.add(DeviceConnectionState.disconnected);
    _weaponsController.add(_connectedWeapons);
    _startReconnectionTimer();
  }

  void _startReconnectionTimer() {
    _reconnectionTimer?.cancel();
    _reconnectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkConnections();
    });
  }

  void _checkConnections() {
    for (var weapon in _connectedWeapons) {
      if (weapon.state != DeviceConnectionState.connected) {
        _attemptReconnect(weapon);
      }
    }
  }

  Future<void> _attemptReconnect(WeaponDevice weapon) async {
    if (weapon.reconnectAttempts >= _maxReconnectAttempts) {
      _errorController.add('Failed to reconnect to ${weapon.name} after ${_maxReconnectAttempts} attempts');
      return;
    }

    final now = DateTime.now();
    if (weapon.lastConnectionAttempt != null &&
        now.difference(weapon.lastConnectionAttempt!) < _reconnectDelay) {
      return;
    }

    weapon.state = DeviceConnectionState.reconnecting;
    weapon.lastConnectionAttempt = now;
    weapon.reconnectAttempts++;
    _weaponsController.add(_connectedWeapons);

    try {
      // Simulate reconnection attempt
      await Future.delayed(const Duration(seconds: 2));
      
      // Randomly succeed or fail for simulation
      if (weapon.reconnectAttempts % 2 == 0) {
        weapon.state = DeviceConnectionState.connected;
        weapon.reconnectAttempts = 0;
        _errorController.add('Successfully reconnected to ${weapon.name}');
      } else {
        weapon.state = DeviceConnectionState.error;
        _errorController.add('Failed to reconnect to ${weapon.name} (Attempt ${weapon.reconnectAttempts})');
      }
    } catch (e) {
      weapon.state = DeviceConnectionState.error;
      _errorController.add('Error reconnecting to ${weapon.name}: $e');
    }

    _weaponsController.add(_connectedWeapons);
  }

  void startScan() {
    // Start scanning for weapons
    _connectionStateController.add(DeviceConnectionState.scanning);
    // Reset reconnection attempts for all weapons
    for (var weapon in _connectedWeapons) {
      weapon.reconnectAttempts = 0;
    }
  }

  void stopScan() {
    // Stop scanning for weapons
    _connectionStateController.add(DeviceConnectionState.disconnected);
  }

  void disconnectAll() {
    // Disconnect all weapons
    _connectedWeapons.clear();
    _weaponsController.add(_connectedWeapons);
    _connectionStateController.add(DeviceConnectionState.disconnected);
  }

  void dispose() {
    _connectionStateController.close();
    _scoreController.close();
    _weaponsController.close();
    _errorController.close();
    _reconnectionTimer?.cancel();
    _simulationTimer?.cancel();
  }

  Future<void> startScanSimulated() async {
    try {
      _connectionStateController.add(DeviceConnectionState.scanning);
      
      // Simulate scanning delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate finding two weapons
      final weapon1 = WeaponDevice(
        id: 'weapon1',
        name: 'FencingWeapon-1',
        fencerNumber: 1,
        state: DeviceConnectionState.connected,
      );
      
      final weapon2 = WeaponDevice(
        id: 'weapon2',
        name: 'FencingWeapon-2',
        fencerNumber: 2,
        state: DeviceConnectionState.connected,
      );

      _connectedWeapons.addAll([weapon1, weapon2]);
      _weaponsController.add(_connectedWeapons);
      _connectionStateController.add(DeviceConnectionState.connected);
      
      // Start simulation timer
      _simulationTimer?.cancel();
      _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
        if (_connectionStateController.isClosed) {
          timer.cancel();
          return;
        }

        // Reset scoring ability for all weapons
        for (var weapon in _connectedWeapons) {
          weapon.canScore = true;
        }
        _lastHitTime = null;

        // Get current scenario
        final scenario = _scenarios[_currentScenario];
        print('Running scenario: ${scenario['name']}');
        
        // Execute hits in sequence
        for (var hit in scenario['hits']) {
          Future.delayed(Duration(milliseconds: hit['delay']), () {
            if (_connectionStateController.isClosed) return;
            
            final weapon = _connectedWeapons.firstWhere(
              (w) => w.fencerNumber == hit['fencer'],
              orElse: () => _connectedWeapons[0],
            );

            if (weapon.canScore) {
              final now = DateTime.now();
              
              // Check if this is the first hit in the priority window
              if (_lastHitTime == null || now.difference(_lastHitTime!) > _priorityWindow) {
                weapon.lastScore++;
                weapon.lastUpdate = now;
                weapon.canScore = false;
                _lastHitTime = now;
                
                // Disable scoring for all weapons
                for (var w in _connectedWeapons) {
                  w.canScore = false;
                }
                
                _scoreController.add({
                  'weaponId': weapon.id,
                  'fencer': weapon.fencerNumber,
                  'score': weapon.lastScore,
                  'timestamp': weapon.lastUpdate.toIso8601String(),
                });
              }
            }
          });
        }

        // Move to next scenario
        _currentScenario = (_currentScenario + 1) % _scenarios.length;
        
        // Update weapons list
        _weaponsController.add(_connectedWeapons);
      });
    } catch (e) {
      print('Scan error: $e');
      _connectionStateController.add(DeviceConnectionState.error);
    }
  }
} 