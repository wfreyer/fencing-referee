import 'package:flutter/material.dart';
import 'package:fencing_referee/services/bluetooth_service.dart';
import 'package:fencing_referee/services/match_service.dart';
import 'package:fencing_referee/widgets/score_display.dart';
import 'package:fencing_referee/widgets/score_history_dialog.dart';

/// A widget that displays the scoring interface for a fencing match.
class ScoringPage extends StatefulWidget {
  const ScoringPage({super.key});

  @override
  _ScoringPageState createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  final BluetoothService _bluetoothService = BluetoothService();
  late final MatchService _matchService;
  final TextEditingController _fencer1Controller = TextEditingController(text: 'Fencer 1');
  final TextEditingController _fencer2Controller = TextEditingController(text: 'Fencer 2');

  @override
  void initState() {
    super.initState();
    _matchService = MatchService(_bluetoothService);
  }

  @override
  void dispose() {
    _fencer1Controller.dispose();
    _fencer2Controller.dispose();
    super.dispose();
  }

  void _incrementScore(int fencer) {
    _matchService.incrementScore(fencer);
  }

  void _decrementScore(int fencer) {
    _matchService.decrementScore(fencer);
  }

  void _resetMatch() {
    _matchService.resetMatch();
  }

  void _showScoreHistory() {
    showDialog(
      context: context,
      builder: (context) => ScoreHistoryDialog(
        history: _matchService.scoreHistory,
        fencer1Name: _fencer1Controller.text,
        fencer2Name: _fencer2Controller.text,
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
          // Period indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.grey[200],
            child: StreamBuilder<int>(
              stream: _matchService.periodStream,
              builder: (context, snapshot) {
                final period = snapshot.data ?? 1;
                return Text(
                  'Period $period',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
          ),
          // Split screen for fencers
          Expanded(
            child: Row(
              children: [
                // Fencer 1 (Blue)
                Expanded(
                  child: Container(
                    color: Colors.blue.withOpacity(0.1),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _fencer1Controller,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Fencer 1 Name',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<int>>(
                            stream: _matchService.scoreStream,
                            builder: (context, snapshot) {
                              final scores = snapshot.data ?? [0, 0];
                              return ScoreDisplay(
                                fencer: 1,
                                score: scores[0],
                                name: _fencer1Controller.text,
                                isHit: _bluetoothService.isHit1,
                                onIncrement: () => _incrementScore(1),
                                onDecrement: () => _decrementScore(1),
                                onNameTap: () {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Fencer 2 (Red)
                Expanded(
                  child: Container(
                    color: Colors.red.withOpacity(0.1),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: TextField(
                            controller: _fencer2Controller,
                            enabled: true,
                            decoration: const InputDecoration(
                              labelText: 'Fencer 2 Name',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: StreamBuilder<List<int>>(
                            stream: _matchService.scoreStream,
                            builder: (context, snapshot) {
                              final scores = snapshot.data ?? [0, 0];
                              return ScoreDisplay(
                                fencer: 2,
                                score: scores[1],
                                name: _fencer2Controller.text,
                                isHit: _bluetoothService.isHit2,
                                onIncrement: () => _incrementScore(2),
                                onDecrement: () => _decrementScore(2),
                                onNameTap: () {},
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom controls
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _resetMatch,
              child: const Text('Reset Match'),
            ),
          ),
        ],
      ),
    );
  }
} 