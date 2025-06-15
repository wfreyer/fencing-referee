import 'package:flutter/material.dart';
import 'services/bluetooth_service.dart';
import 'services/match_service.dart';
import 'widgets/score_display.dart';
import 'widgets/score_history_dialog.dart';

void main() {
  runApp(const FencingRefereeApp());
}

class FencingRefereeApp extends StatelessWidget {
  const FencingRefereeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fencing Referee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScoringPage(),
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
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _bluetoothService.initialize();
    _matchService = MatchService(_bluetoothService);
  }

  @override
  void dispose() {
    _matchService.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }

  void _showNameDialog(bool isFencer1) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter ${isFencer1 ? "Fencer 1" : "Fencer 2"}\'s Name'),
        content: TextField(
          autofocus: true,
          onSubmitted: (value) {
            setState(() {
              if (isFencer1) {
                _fencer1Name = value;
              } else {
                _fencer2Name = value;
              }
            });
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showScoreHistory() {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder(
        stream: _matchService.scoreHistoryStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          return ScoreHistoryDialog(
            history: snapshot.data!,
            fencer1Name: _fencer1Name,
            fencer2Name: _fencer2Name,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fencing Referee'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showScoreHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: _matchService.periodStream,
            builder: (context, snapshot) {
              final period = snapshot.data ?? 1;
              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Period $period',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _matchService.nextPeriod(),
                      child: const Text('Next Period'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: _matchService.scoreStream,
                    builder: (context, snapshot) {
                      final scores = snapshot.data ?? [0, 0];
                      return ScoreDisplay(
                        fencer: 1,
                        score: scores[0],
                        name: _fencer1Name,
                        isHit: _bluetoothService.isHit1,
                        onIncrement: () => _matchService.incrementScore(1),
                        onDecrement: () => _matchService.decrementScore(1),
                        onNameTap: () => _showNameDialog(true),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: _matchService.scoreStream,
                    builder: (context, snapshot) {
                      final scores = snapshot.data ?? [0, 0];
                      return ScoreDisplay(
                        fencer: 2,
                        score: scores[1],
                        name: _fencer2Name,
                        isHit: _bluetoothService.isHit2,
                        onIncrement: () => _matchService.incrementScore(2),
                        onDecrement: () => _matchService.decrementScore(2),
                        onNameTap: () => _showNameDialog(false),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isScanning = !_isScanning;
                if (_isScanning) {
                  _bluetoothService.startScan();
                } else {
                  _bluetoothService.stopScan();
                }
              });
            },
            child: Icon(_isScanning ? Icons.stop : Icons.search),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () => _matchService.resetMatch(),
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
