import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/widgets/score_display.dart';

void main() {
  testWidgets('ScoreDisplay shows correct score and name', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(
            fencer: 1,
            score: 5,
            name: 'Test Fencer',
            isHit: false,
            onIncrement: () {},
            onDecrement: () {},
            onNameTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test Fencer'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('ScoreDisplay shows hit effect when isHit is true', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(
            fencer: 1,
            score: 5,
            name: 'Test Fencer',
            isHit: true,
            onIncrement: () {},
            onDecrement: () {},
            onNameTap: () {},
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.ancestor(
        of: find.text('5'),
        matching: find.byType(Container),
      ).first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.blue.withOpacity(0.3));
  });

  testWidgets('ScoreDisplay calls onIncrement when + button is pressed', (WidgetTester tester) async {
    bool incrementCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(
            fencer: 1,
            score: 5,
            name: 'Test Fencer',
            isHit: false,
            onIncrement: () => incrementCalled = true,
            onDecrement: () {},
            onNameTap: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pump();

    expect(incrementCalled, true);
  });

  testWidgets('ScoreDisplay calls onDecrement when - button is pressed', (WidgetTester tester) async {
    bool decrementCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(
            fencer: 1,
            score: 5,
            name: 'Test Fencer',
            isHit: false,
            onIncrement: () {},
            onDecrement: () => decrementCalled = true,
            onNameTap: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.remove_circle_outline));
    await tester.pump();

    expect(decrementCalled, true);
  });

  testWidgets('ScoreDisplay calls onNameTap when name is tapped', (WidgetTester tester) async {
    bool nameTapCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScoreDisplay(
            fencer: 1,
            score: 5,
            name: 'Test Fencer',
            isHit: false,
            onIncrement: () {},
            onDecrement: () {},
            onNameTap: () => nameTapCalled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Test Fencer'));
    await tester.pump();

    expect(nameTapCalled, true);
  });
} 