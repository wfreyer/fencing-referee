import 'package:flutter/material.dart';
import 'package:fencing_referee/services/bluetooth_service.dart';
import 'package:fencing_referee/services/match_service.dart';
import 'package:fencing_referee/services/permission_service.dart';
import 'package:fencing_referee/widgets/scoring_page.dart';
import 'widgets/score_display.dart';
import 'widgets/score_history_dialog.dart';
import 'widgets/connection_status_bar.dart';
import 'widgets/error_banner.dart';
import 'widgets/setup_guide.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

/// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fencing Referee',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppInitializer(),
    );
  }
}

/// Widget that handles the initial app setup and permission checks.
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  final PermissionService _permissionService = PermissionService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final hasPermissions = await _permissionService.checkPermissions();
    final isBluetoothEnabled = await _permissionService.isBluetoothEnabled();

    if (hasPermissions && isBluetoothEnabled) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized) {
      return const ScoringPage();
    }

    return SetupGuide(
      onSetupComplete: () {
        setState(() {
          _isInitialized = true;
        });
      },
    );
  }
}

class ScoringPage extends StatefulWidget {
  const ScoringPage({super.key});

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  late final MatchService _matchService;
  String _fencer1Name = 'Fencer 1';
  String _fencer2Name = 'Fencer 2';
  String? _errorMessage;
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();
    _bluetoothService.initialize();
    _matchService = MatchService(_bluetoothService);
    
    // Listen for errors
    _bluetoothService.errors.listen((error) {
      setState(() {
        _errorMessage = error;
      });
      // Clear error after 5 seconds
      _errorTimer?.cancel();
      _errorTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _matchService.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }

  void _showScoreHistory() {
    showDialog(
      context: context,
      builder: (context) => ScoreHistoryDialog(
        history: _matchService.scoreHistory,
        fencer1Name: _fencer1Name,
        fencer2Name: _fencer2Name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fencing Referee'),
        actions: [
          StreamBuilder<DeviceConnectionState>(
            stream: _bluetoothService.connectionState,
            initialData: DeviceConnectionState.disconnected,
            builder: (context, snapshot) {
              final state = snapshot.data!;
              return IconButton(
                icon: Icon(
                  state == DeviceConnectionState.connected
                      ? Icons.bluetooth_connected
                      : state == DeviceConnectionState.connecting
                          ? Icons.bluetooth_searching
                          : state == DeviceConnectionState.reconnecting
                              ? Icons.bluetooth_searching
                              : Icons.bluetooth_disabled,
                  color: state == DeviceConnectionState.connected
                      ? Colors.green
                      : state == DeviceConnectionState.error
                          ? Colors.red
                          : Colors.grey,
                ),
                onPressed: () {
                  if (state == DeviceConnectionState.disconnected) {
                    _bluetoothService.startScanSimulated();
                  } else {
                    _bluetoothService.disconnectAll();
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              StreamBuilder<List<WeaponDevice>>(
                stream: _bluetoothService.weapons,
                builder: (context, snapshot) {
                  final weapons = snapshot.data ?? [];
                  return ConnectionStatusBar(
                    weapons: weapons,
                    fencer1Name: _fencer1Name,
                    fencer2Name: _fencer2Name,
                  );
                },
              ),
              StreamBuilder(
                stream: _matchService.periodStream,
                initialData: 1,
                builder: (context, snapshot) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Period ${snapshot.data}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  );
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<int>>(
                        stream: _matchService.scoreStream,
                        initialData: const [0, 0],
                        builder: (context, snapshot) {
                          final scores = snapshot.data ?? [0, 0];
                          return ScoreDisplay(
                            fencer: 1,
                            score: scores[0],
                            name: _fencer1Name,
                            isHit: _bluetoothService.isHit1,
                            onIncrement: () => _matchService.incrementScore(1),
                            onDecrement: () => _matchService.decrementScore(1),
                            onNameTap: () {},
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<int>>(
                        stream: _matchService.scoreStream,
                        initialData: const [0, 0],
                        builder: (context, snapshot) {
                          final scores = snapshot.data ?? [0, 0];
                          return ScoreDisplay(
                            fencer: 2,
                            score: scores[1],
                            name: _fencer2Name,
                            isHit: _bluetoothService.isHit2,
                            onIncrement: () => _matchService.incrementScore(2),
                            onDecrement: () => _matchService.decrementScore(2),
                            onNameTap: () {},
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _matchService.nextPeriod(),
                      child: const Text('Next Period'),
                    ),
                    ElevatedButton(
                      onPressed: () => _matchService.resetMatch(),
                      child: const Text('Reset Match'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history),
                      onPressed: _showScoreHistory,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ErrorBanner(
                message: _errorMessage!,
                onDismiss: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
