import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/widgets/score_history_dialog.dart';
import 'package:fencing_referee/models/score_adjustment.dart';

void main() {
  final testHistory = [
    ScoreAdjustment(
      fencer: 1,
      oldScore: 0,
      newScore: 1,
      timestamp: DateTime(2024, 1, 1, 12, 0),
      reason: 'First hit',
    ),
    ScoreAdjustment(
      fencer: 2,
      oldScore: 0,
      newScore: 1,
      timestamp: DateTime(2024, 1, 1, 12, 1),
      reason: 'Second hit',
    ),
    ScoreAdjustment(
      fencer: 0,
      oldScore: 2,
      newScore: 0,
      timestamp: DateTime(2024, 1, 1, 12, 2),
      reason: 'Match reset',
    ),
  ];

  testWidgets('ScoreHistoryDialog shows correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreHistoryDialog(
            history: testHistory,
            fencer1Name: 'Fencer 1',
            fencer2Name: 'Fencer 2',
          ),
        ),
      ),
    );

    expect(find.text('Score Adjustment History'), findsOneWidget);
  });

  testWidgets('ScoreHistoryDialog shows history items in reverse order', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreHistoryDialog(
            history: testHistory,
            fencer1Name: 'Fencer 1',
            fencer2Name: 'Fencer 2',
          ),
        ),
      ),
    );

    // Check that items are shown in reverse order (newest first)
    final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    
    expect((listTiles[0].title as Text).data, 'Both Fencers'); // Reset
    expect((listTiles[0].subtitle as Text).data, 'Match reset');
    
    expect((listTiles[1].title as Text).data, 'Fencer 2'); // Second hit
    expect((listTiles[1].subtitle as Text).data, 'Second hit');
    
    expect((listTiles[2].title as Text).data, 'Fencer 1'); // First hit
    expect((listTiles[2].subtitle as Text).data, 'First hit');
  });

  testWidgets('ScoreHistoryDialog shows correct score changes', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreHistoryDialog(
            history: testHistory,
            fencer1Name: 'Fencer 1',
            fencer2Name: 'Fencer 2',
          ),
        ),
      ),
    );

    final scoreChanges = find.textContaining('→');
    expect(scoreChanges, findsNWidgets(3));
    
    expect(find.text('0 → 1'), findsNWidgets(2)); // First and second hits
    expect(find.text('2 → 0'), findsOneWidget); // Reset
  });

  testWidgets('ScoreHistoryDialog has close button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreHistoryDialog(
            history: testHistory,
            fencer1Name: 'Fencer 1',
            fencer2Name: 'Fencer 2',
          ),
        ),
      ),
    );

    expect(find.text('Close'), findsOneWidget);
  });

  testWidgets('ScoreHistoryDialog handles empty history', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreHistoryDialog(
            history: [],
            fencer1Name: 'Fencer 1',
            fencer2Name: 'Fencer 2',
          ),
        ),
      ),
    );

    expect(find.byType(ListTile), findsNothing);
  });
} 