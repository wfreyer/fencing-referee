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
  final MatchService _matchService = MatchService();
  final TextEditingController _fencer1Controller = TextEditingController(text: 'Fencer 1');
  final TextEditingController _fencer2Controller = TextEditingController(text: 'Fencer 2');

  @override
  void initState() {
    super.initState();
    _bluetoothService.init();
  }

  @override
  void dispose() {
    _bluetoothService.dispose();
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
        adjustments: _matchService.scoreHistory,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fencer1Controller,
              decoration: const InputDecoration(labelText: 'Fencer 1 Name'),
            ),
            TextField(
              controller: _fencer2Controller,
              decoration: const InputDecoration(labelText: 'Fencer 2 Name'),
            ),
            const SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _matchService.scoreStream,
              builder: (context, snapshot) {
                final score = snapshot.data ?? 0;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ScoreDisplay(
                      fencer: 1,
                      score: score,
                      name: _fencer1Controller.text,
                      isHit: _bluetoothService.isHit1,
                      onIncrement: () => _incrementScore(1),
                      onDecrement: () => _decrementScore(1),
                      onNameTap: () {},
                    ),
                    ScoreDisplay(
                      fencer: 2,
                      score: score,
                      name: _fencer2Controller.text,
                      isHit: _bluetoothService.isHit2,
                      onIncrement: () => _incrementScore(2),
                      onDecrement: () => _decrementScore(2),
                      onNameTap: () {},
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetMatch,
              child: const Text('Reset Match'),
            ),
          ],
        ),
      ),
    );
  }
} 