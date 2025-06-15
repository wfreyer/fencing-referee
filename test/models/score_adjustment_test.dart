import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/models/score_adjustment.dart';

void main() {
  group('ScoreAdjustment', () {
    test('creates with default reason', () {
      final adjustment = ScoreAdjustment(
        fencer: 1,
        oldScore: 0,
        newScore: 1,
        timestamp: DateTime(2024, 1, 1),
      );

      expect(adjustment.fencer, 1);
      expect(adjustment.oldScore, 0);
      expect(adjustment.newScore, 1);
      expect(adjustment.timestamp, DateTime(2024, 1, 1));
      expect(adjustment.reason, 'Manual adjustment');
    });

    test('creates with custom reason', () {
      final adjustment = ScoreAdjustment(
        fencer: 2,
        oldScore: 1,
        newScore: 0,
        timestamp: DateTime(2024, 1, 1),
        reason: 'Correction',
      );

      expect(adjustment.fencer, 2);
      expect(adjustment.oldScore, 1);
      expect(adjustment.newScore, 0);
      expect(adjustment.timestamp, DateTime(2024, 1, 1));
      expect(adjustment.reason, 'Correction');
    });
  });
} 