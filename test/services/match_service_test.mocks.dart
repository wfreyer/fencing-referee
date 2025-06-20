// Mocks generated by Mockito 5.4.6 from annotations
// in fencing_referee/test/services/match_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:fencing_referee/services/bluetooth_service.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [BluetoothService].
///
/// See the documentation for Mockito's code generation for more information.
class MockBluetoothService extends _i1.Mock implements _i2.BluetoothService {
  MockBluetoothService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get isHit1 => (super.noSuchMethod(
        Invocation.getter(#isHit1),
        returnValue: false,
      ) as bool);

  @override
  bool get isHit2 => (super.noSuchMethod(
        Invocation.getter(#isHit2),
        returnValue: false,
      ) as bool);

  @override
  List<_i2.WeaponDevice> get connectedWeapons => (super.noSuchMethod(
        Invocation.getter(#connectedWeapons),
        returnValue: <_i2.WeaponDevice>[],
      ) as List<_i2.WeaponDevice>);

  @override
  _i3.Stream<_i2.DeviceConnectionState> get connectionState =>
      (super.noSuchMethod(
        Invocation.getter(#connectionState),
        returnValue: _i3.Stream<_i2.DeviceConnectionState>.empty(),
      ) as _i3.Stream<_i2.DeviceConnectionState>);

  @override
  _i3.Stream<Map<String, dynamic>> get scoreUpdates => (super.noSuchMethod(
        Invocation.getter(#scoreUpdates),
        returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
      ) as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Stream<List<_i2.WeaponDevice>> get weapons => (super.noSuchMethod(
        Invocation.getter(#weapons),
        returnValue: _i3.Stream<List<_i2.WeaponDevice>>.empty(),
      ) as _i3.Stream<List<_i2.WeaponDevice>>);

  @override
  _i3.Stream<String> get errors => (super.noSuchMethod(
        Invocation.getter(#errors),
        returnValue: _i3.Stream<String>.empty(),
      ) as _i3.Stream<String>);

  @override
  void initialize() => super.noSuchMethod(
        Invocation.method(
          #initialize,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void startScan() => super.noSuchMethod(
        Invocation.method(
          #startScan,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void stopScan() => super.noSuchMethod(
        Invocation.method(
          #stopScan,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void disconnectAll() => super.noSuchMethod(
        Invocation.method(
          #disconnectAll,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Future<void> startScanSimulated() => (super.noSuchMethod(
        Invocation.method(
          #startScanSimulated,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}
