import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';

enum DeviceConnectionState {
  disconnected,
  connecting,
  connected,
  error,
}

class DeviceService {
  WebSocketChannel? _channel;
  final _connectionStateController = StreamController<DeviceConnectionState>.broadcast();
  final _scoreUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<DeviceConnectionState> get connectionState => _connectionStateController.stream;
  Stream<Map<String, dynamic>> get scoreUpdates => _scoreUpdateController.stream;

  Future<void> connect(String address) async {
    try {
      _connectionStateController.add(DeviceConnectionState.connecting);
      
      // Create WebSocket connection
      final wsUrl = Uri.parse(address);
      _channel = WebSocketChannel.connect(wsUrl);
      
      // Listen for messages
      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            _scoreUpdateController.add(data);
          } catch (e) {
            print('Error parsing message: $e');
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _connectionStateController.add(DeviceConnectionState.error);
        },
        onDone: () {
          _connectionStateController.add(DeviceConnectionState.disconnected);
        },
      );

      _connectionStateController.add(DeviceConnectionState.connected);
    } catch (e) {
      print('Connection error: $e');
      _connectionStateController.add(DeviceConnectionState.error);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _connectionStateController.add(DeviceConnectionState.disconnected);
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _scoreUpdateController.close();
  }
} 