import 'package:flutter/material.dart';
import 'package:fencing_referee/services/permission_service.dart';

/// A widget that guides users through the initial setup process.
class SetupGuide extends StatefulWidget {
  final VoidCallback onSetupComplete;
  final PermissionService? permissionService;

  const SetupGuide({
    super.key,
    this.permissionService,
    required this.onSetupComplete,
  });

  @override
  State<SetupGuide> createState() => _SetupGuideState();
}

class _SetupGuideState extends State<SetupGuide> {
  late final PermissionService _permissionService;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _checkAndRequestPermissions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if Bluetooth is enabled
      final isBluetoothEnabled = await _permissionService.isBluetoothEnabled();
      if (!isBluetoothEnabled) {
        setState(() {
          _errorMessage = 'Please enable Bluetooth to use this app.';
        });
        return;
      }

      // Check and request permissions
      final hasPermissions = await _permissionService.checkPermissions();
      if (!hasPermissions) {
        final granted = await _permissionService.requestPermissions();
        if (!granted) {
          final missingPermissions = await _permissionService.getMissingPermissions();
          setState(() {
            _errorMessage = 'Please grant the following permissions to use this app:\n'
                '${missingPermissions.join(", ")}';
          });
          return;
        }
      }

      // All checks passed
      widget.onSetupComplete();
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during setup. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bluetooth_searching,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Fencing Referee!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'To get started, we need to:\n'
              '1. Enable Bluetooth\n'
              '2. Grant necessary permissions\n'
              '3. Connect to your fencing weapons',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkAndRequestPermissions,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Start Setup'),
            ),
          ],
        ),
      ),
    );
  }
} 