import 'package:flutter/foundation.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  
  factory ConfigService() {
    return _instance;
  }
  
  ConfigService._internal();

  bool get useBluetooth {
    // On web platform, always use mocks
    if (kIsWeb) {
      return false;
    }
    // On mobile platforms, use real Bluetooth
    return true;
  }
} 