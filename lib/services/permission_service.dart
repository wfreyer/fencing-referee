import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'config_service.dart';

/// Service to handle runtime permissions for Bluetooth and location services.
class PermissionService {
  final _configService = ConfigService();

  /// Request all necessary permissions for the app to function.
  /// Returns true if all permissions are granted, false otherwise.
  Future<bool> requestPermissions() async {
    if (!_configService.useBluetooth) {
      return true; // No permissions needed for web/mock mode
    }

    // Request location permission (required for BLE scanning)
    final locationStatus = await Permission.location.request();
    if (!locationStatus.isGranted) {
      return false;
    }

    // Request Bluetooth permissions
    if (await Permission.bluetooth.isDenied) {
      final bluetoothStatus = await Permission.bluetooth.request();
      if (!bluetoothStatus.isGranted) {
        return false;
      }
    }

    if (await Permission.bluetoothScan.isDenied) {
      final bluetoothScanStatus = await Permission.bluetoothScan.request();
      if (!bluetoothScanStatus.isGranted) {
        return false;
      }
    }

    if (await Permission.bluetoothConnect.isDenied) {
      final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
      if (!bluetoothConnectStatus.isGranted) {
        return false;
      }
    }

    return true;
  }

  /// Check if all required permissions are granted.
  Future<bool> checkPermissions() async {
    if (!_configService.useBluetooth) {
      return true; // No permissions needed for web/mock mode
    }

    final locationGranted = await Permission.location.isGranted;
    final bluetoothGranted = await Permission.bluetooth.isGranted;
    final bluetoothScanGranted = await Permission.bluetoothScan.isGranted;
    final bluetoothConnectGranted = await Permission.bluetoothConnect.isGranted;

    return locationGranted && 
           bluetoothGranted && 
           bluetoothScanGranted && 
           bluetoothConnectGranted;
  }

  /// Check if Bluetooth is enabled on the device.
  Future<bool> isBluetoothEnabled() async {
    if (!_configService.useBluetooth) {
      return true; // Always enabled in web/mock mode
    }

    try {
      return await FlutterBluePlus.isAvailable;
    } catch (e) {
      return false;
    }
  }

  /// Get a list of missing permissions.
  Future<List<String>> getMissingPermissions() async {
    if (!_configService.useBluetooth) {
      return []; // No permissions needed for web/mock mode
    }

    final List<String> missingPermissions = [];

    if (!await Permission.location.isGranted) {
      missingPermissions.add('Location');
    }
    if (!await Permission.bluetooth.isGranted) {
      missingPermissions.add('Bluetooth');
    }
    if (!await Permission.bluetoothScan.isGranted) {
      missingPermissions.add('Bluetooth Scan');
    }
    if (!await Permission.bluetoothConnect.isGranted) {
      missingPermissions.add('Bluetooth Connect');
    }

    return missingPermissions;
  }
} 