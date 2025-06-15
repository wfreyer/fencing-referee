import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/widgets/error_banner.dart';

void main() {
  group('ErrorBanner', () {
    testWidgets('displays error message correctly', (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: errorMessage,
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onDismiss when close button is pressed', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error',
              onDismiss: () {
                dismissed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissed, true);
    });

    testWidgets('has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: 'Test error',
              onDismiss: () {},
            ),
          ),
        ),
      );

      final material = tester.widget<Material>(find.byType(Material).first);
      expect(material.color, isNotNull);
      expect(material.color!.value & 0xFF0000, greaterThan(0)); // Check if it's a shade of red

      final errorIcon = tester.widget<Icon>(find.byIcon(Icons.error_outline).first);
      expect(errorIcon.color, Colors.red);

      final closeIcon = tester.widget<Icon>(find.byIcon(Icons.close).first);
      expect(closeIcon.color, Colors.red);

      final errorText = tester.widget<Text>(find.text('Test error').first);
      expect(errorText.style?.color, Colors.red);
    });

    testWidgets('handles long error messages', (WidgetTester tester) async {
      const longMessage = 'This is a very long error message that should wrap to multiple lines '
          'and still be readable and properly formatted within the error banner';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBanner(
              message: longMessage,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text(longMessage), findsOneWidget);
      // Verify the text is visible and properly formatted
      final textWidget = tester.widget<Text>(find.text(longMessage).first);
      expect(textWidget.style?.color, Colors.red);
    });
  });
} 