import 'dart:async';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

enum DeviceConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class BluetoothService {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus.instance;
  final _connectionStateController = StreamController<DeviceConnectionState>.broadcast();
  final _scoreUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<DeviceConnectionState> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get scoreUpdates => _scoreUpdateController.stream;
  
  List<BluetoothDevice> _connectedDevices = [];
  Map<String, StreamSubscription> _deviceSubscriptions = {};

  Future<void> requestPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();
  }

  Future<void> startScan() async {
    try {
      await requestPermissions();
      _connectionStateController.add(DeviceConnectionState.scanning);
      
      // Start scanning for devices
      await _flutterBlue.startScan(timeout: const Duration(seconds: 4));
      
      // Listen for scan results
      _flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          // Look for devices with our specific service UUID
          if (result.device.name.contains('FencingWeapon')) {
            connectToDevice(result.device);
          }
        }
      });
    } catch (e) {
      print('Scan error: $e');
      _connectionStateController.add(DeviceConnectionState.error);
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connectionStateController.add(DeviceConnectionState.connecting);
      
      // Connect to the device
      await device.connect();
      _connectedDevices.add(device);
      
      // Discover services
      List<BluetoothService> services = await device.discoverServices();
      
      // Find our specific service and characteristic
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.properties.notify) {
            // Subscribe to notifications
            await characteristic.setNotifyValue(true);
            _deviceSubscriptions[device.id.id] = characteristic.onValueReceived.listen((value) {
              try {
                // Parse the received data
                String data = utf8.decode(value);
                Map<String, dynamic> scoreData = jsonDecode(data);
                _scoreUpdateController.add(scoreData);
              } catch (e) {
                print('Error parsing data: $e');
              }
            });
          }
        }
      }
      
      _connectionStateController.add(DeviceConnectionState.connected);
    } catch (e) {
      print('Connection error: $e');
      _connectionStateController.add(DeviceConnectionState.error);
    }
  }

  Future<void> disconnectDevice(BluetoothDevice device) async {
    try {
      // Cancel subscription
      await _deviceSubscriptions[device.id.id]?.cancel();
      _deviceSubscriptions.remove(device.id.id);
      
      // Disconnect device
      await device.disconnect();
      _connectedDevices.remove(device);
      
      if (_connectedDevices.isEmpty) {
        _connectionStateController.add(DeviceConnectionState.disconnected);
      }
    } catch (e) {
      print('Disconnect error: $e');
    }
  }

  void disconnectAll() {
    for (var device in _connectedDevices) {
      disconnectDevice(device);
    }
  }

  void dispose() {
    disconnectAll();
    _connectionStateController.close();
    _scoreUpdateController.close();
  }
} 