import 'dart:async';
import '../models/score_adjustment.dart';
import 'bluetooth_service.dart';

class MatchService {
  final BluetoothService _bluetoothService;
  final _scoreController = StreamController<List<int>>.broadcast();
  final _periodController = StreamController<int>.broadcast();
  final _historyController = StreamController<List<ScoreAdjustment>>.broadcast();
  StreamSubscription? _btScoreSub;
  
  List<int> _scores = [0, 0];
  int _period = 1;
  List<ScoreAdjustment> _history = [];

  MatchService(this._bluetoothService) {
    _scoreController.add(_scores);
    _periodController.add(_period);
    _historyController.add(_history);
    _btScoreSub = _bluetoothService.scoreUpdates.listen(_onBluetoothScore);
  }

  void _onBluetoothScore(Map<String, dynamic> data) {
    final fencer = data['fencer'];
    final score = data['score'];
    if (fencer is int && (fencer == 1 || fencer == 2) && score is int) {
      final oldScore = _scores[fencer - 1];
      _scores[fencer - 1] = score;
      _scoreController.add(_scores);
      _addToHistory(
        fencer: fencer,
        oldScore: oldScore,
        newScore: score,
        reason: 'Weapon hit',
      );
    }
  }

  // Getters for current state
  List<int> get currentScores => _scores;
  int get currentPeriod => _period;
  List<ScoreAdjustment> get scoreHistory => _history;

  // Streams for reactive updates
  Stream<List<int>> get scoreStream => _scoreController.stream;
  Stream<int> get periodStream => _periodController.stream;
  Stream<List<ScoreAdjustment>> get scoreHistoryStream => _historyController.stream;

  void incrementScore(int fencer) {
    if (fencer < 1 || fencer > 2) return;
    
    final oldScore = _scores[fencer - 1];
    _scores[fencer - 1] = oldScore + 1;
    _scoreController.add(_scores);
    
    _addToHistory(
      fencer: fencer,
      oldScore: oldScore,
      newScore: _scores[fencer - 1],
    );
  }

  void decrementScore(int fencer) {
    if (fencer < 1 || fencer > 2) return;
    
    final oldScore = _scores[fencer - 1];
    if (oldScore > 0) {
      _scores[fencer - 1] = oldScore - 1;
      _scoreController.add(_scores);
      
      _addToHistory(
        fencer: fencer,
        oldScore: oldScore,
        newScore: _scores[fencer - 1],
      );
    }
  }

  void nextPeriod() {
    if (_period < 3) {
      _period++;
      _periodController.add(_period);
    }
  }

  void resetMatch() {
    final oldScore1 = _scores[0];
    final oldScore2 = _scores[1];
    
    _scores = [0, 0];
    _period = 1;
    
    _scoreController.add(_scores);
    _periodController.add(_period);
    
    if (oldScore1 > 0 || oldScore2 > 0) {
      _addToHistory(
        fencer: 0, // 0 indicates both fencers
        oldScore: oldScore1 + oldScore2,
        newScore: 0,
        reason: 'Match reset',
      );
    }
  }

  void _addToHistory({
    required int fencer,
    required int oldScore,
    required int newScore,
    String reason = 'Manual adjustment',
  }) {
    _history.add(ScoreAdjustment(
      fencer: fencer,
      oldScore: oldScore,
      newScore: newScore,
      timestamp: DateTime.now(),
      reason: reason,
    ));
    _historyController.add(_history);
  }

  void dispose() {
    _scoreController.close();
    _periodController.close();
    _historyController.close();
    _btScoreSub?.cancel();
  }
} 