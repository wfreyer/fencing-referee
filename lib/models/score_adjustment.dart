class ScoreAdjustment {
  final int fencer;
  final int oldScore;
  final int newScore;
  final DateTime timestamp;
  final String reason;

  ScoreAdjustment({
    required this.fencer,
    required this.oldScore,
    required this.newScore,
    required this.timestamp,
    this.reason = 'Manual adjustment',
  });
} 