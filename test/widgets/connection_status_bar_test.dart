import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fencing_referee/widgets/connection_status_bar.dart';
import 'package:fencing_referee/services/bluetooth_service.dart';

void main() {
  group('ConnectionStatusBar', () {
    testWidgets('displays both fencers with correct names', (WidgetTester tester) async {
      final weapons = [
        WeaponDevice(
          id: 'weapon1',
          name: 'FencingWeapon-1',
          fencerNumber: 1,
          state: DeviceConnectionState.connected,
        ),
        WeaponDevice(
          id: 'weapon2',
          name: 'FencingWeapon-2',
          fencerNumber: 2,
          state: DeviceConnectionState.connected,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBar(
              weapons: weapons,
              fencer1Name: 'John Doe',
              fencer2Name: 'Jane Smith',
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('displays correct status for connected weapons', (WidgetTester tester) async {
      final weapons = [
        WeaponDevice(
          id: 'weapon1',
          name: 'FencingWeapon-1',
          fencerNumber: 1,
          state: DeviceConnectionState.connected,
        ),
        WeaponDevice(
          id: 'weapon2',
          name: 'FencingWeapon-2',
          fencerNumber: 2,
          state: DeviceConnectionState.connected,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBar(
              weapons: weapons,
              fencer1Name: 'Fencer 1',
              fencer2Name: 'Fencer 2',
            ),
          ),
        ),
      );

      expect(find.text('Connected'), findsNWidgets(2));
      expect(find.byIcon(Icons.bluetooth_connected), findsNWidgets(2));
    });

    testWidgets('displays correct status for disconnected weapons', (WidgetTester tester) async {
      final weapons = [
        WeaponDevice(
          id: 'weapon1',
          name: 'FencingWeapon-1',
          fencerNumber: 1,
          state: DeviceConnectionState.disconnected,
        ),
        WeaponDevice(
          id: 'weapon2',
          name: 'FencingWeapon-2',
          fencerNumber: 2,
          state: DeviceConnectionState.disconnected,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBar(
              weapons: weapons,
              fencer1Name: 'Fencer 1',
              fencer2Name: 'Fencer 2',
            ),
          ),
        ),
      );

      expect(find.text('Disconnected'), findsNWidgets(2));
      expect(find.byIcon(Icons.bluetooth_disabled), findsNWidgets(2));
    });

    testWidgets('displays correct status for reconnecting weapons', (WidgetTester tester) async {
      final weapons = [
        WeaponDevice(
          id: 'weapon1',
          name: 'FencingWeapon-1',
          fencerNumber: 1,
          state: DeviceConnectionState.reconnecting,
        ),
        WeaponDevice(
          id: 'weapon2',
          name: 'FencingWeapon-2',
          fencerNumber: 2,
          state: DeviceConnectionState.connected,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBar(
              weapons: weapons,
              fencer1Name: 'Fencer 1',
              fencer2Name: 'Fencer 2',
            ),
          ),
        ),
      );

      expect(find.text('Reconnecting...'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_searching), findsOneWidget);
      expect(find.byIcon(Icons.bluetooth_connected), findsOneWidget);
    });

    testWidgets('handles missing weapons gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatusBar(
              weapons: [],
              fencer1Name: 'Fencer 1',
              fencer2Name: 'Fencer 2',
            ),
          ),
        ),
      );

      expect(find.text('Disconnected'), findsNWidgets(2));
      expect(find.byIcon(Icons.bluetooth_disabled), findsNWidgets(2));
    });
  });
} 