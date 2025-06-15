import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/services/match_service.dart';
import 'package:fencing_referee/services/bluetooth_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([BluetoothService])
import 'match_service_test.mocks.dart';

void main() {
  late MatchService matchService;
  late MockBluetoothService mockBluetoothService;

  setUp(() {
    mockBluetoothService = MockBluetoothService();
    matchService = MatchService(mockBluetoothService);
  });

  group('MatchService', () {
    test('initializes with correct default values', () {
      expect(matchService.currentScores, [0, 0]);
      expect(matchService.currentPeriod, 1);
      expect(matchService.scoreHistory, []);
    });

    test('incrementScore increases score for fencer 1', () {
      matchService.incrementScore(1);
      expect(matchService.currentScores, [1, 0]);
    });

    test('incrementScore increases score for fencer 2', () {
      matchService.incrementScore(2);
      expect(matchService.currentScores, [0, 1]);
    });

    test('decrementScore decreases score for fencer 1', () {
      matchService.incrementScore(1);
      matchService.incrementScore(1);
      matchService.decrementScore(1);
      expect(matchService.currentScores, [1, 0]);
    });

    test('decrementScore does not go below 0', () {
      matchService.decrementScore(1);
      expect(matchService.currentScores, [0, 0]);
    });

    test('nextPeriod increases period up to 3', () {
      expect(matchService.currentPeriod, 1);
      
      matchService.nextPeriod();
      expect(matchService.currentPeriod, 2);
      
      matchService.nextPeriod();
      expect(matchService.currentPeriod, 3);
      
      matchService.nextPeriod();
      expect(matchService.currentPeriod, 3); // Should not increase beyond 3
    });

    test('resetMatch resets scores and period', () {
      // Set up some scores and period
      matchService.incrementScore(1);
      matchService.incrementScore(1);
      matchService.incrementScore(2);
      matchService.nextPeriod();
      
      matchService.resetMatch();
      
      expect(matchService.currentScores, [0, 0]);
      expect(matchService.currentPeriod, 1);
    });

    test('score history tracks adjustments', () {
      matchService.incrementScore(1);
      matchService.incrementScore(2);
      matchService.decrementScore(1);
      
      final history = matchService.scoreHistory;
      expect(history.length, 3);
      
      expect(history[0].fencer, 1);
      expect(history[0].oldScore, 0);
      expect(history[0].newScore, 1);
      
      expect(history[1].fencer, 2);
      expect(history[1].oldScore, 0);
      expect(history[1].newScore, 1);
      
      expect(history[2].fencer, 1);
      expect(history[2].oldScore, 1);
      expect(history[2].newScore, 0);
    });

    test('resetMatch adds reset to history', () {
      matchService.incrementScore(1);
      matchService.incrementScore(2);
      matchService.resetMatch();
      
      final history = matchService.scoreHistory;
      expect(history.length, 3);
      
      final resetEntry = history.last;
      expect(resetEntry.fencer, 0); // 0 indicates both fencers
      expect(resetEntry.oldScore, 2); // Sum of previous scores
      expect(resetEntry.newScore, 0);
      expect(resetEntry.reason, 'Match reset');
    });
  });
} 