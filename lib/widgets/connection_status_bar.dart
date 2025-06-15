import 'package:flutter/material.dart';
import '../services/bluetooth_service.dart';

class ConnectionStatusBar extends StatelessWidget {
  final List<WeaponDevice> weapons;
  final String fencer1Name;
  final String fencer2Name;

  const ConnectionStatusBar({
    super.key,
    required this.weapons,
    required this.fencer1Name,
    required this.fencer2Name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.grey.shade200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildWeaponStatus(
            weapons.firstWhere(
              (w) => w.fencerNumber == 1,
              orElse: () => WeaponDevice(
                id: 'weapon1',
                name: 'FencingWeapon-1',
                fencerNumber: 1,
                state: DeviceConnectionState.disconnected,
              ),
            ),
            fencer1Name,
          ),
          const VerticalDivider(),
          _buildWeaponStatus(
            weapons.firstWhere(
              (w) => w.fencerNumber == 2,
              orElse: () => WeaponDevice(
                id: 'weapon2',
                name: 'FencingWeapon-2',
                fencerNumber: 2,
                state: DeviceConnectionState.disconnected,
              ),
            ),
            fencer2Name,
          ),
        ],
      ),
    );
  }

  Widget _buildWeaponStatus(WeaponDevice weapon, String fencerName) {
    final statusColor = _getStatusColor(weapon.state);
    final statusIcon = _getStatusIcon(weapon.state);
    final statusText = _getStatusText(weapon.state);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          border: Border.all(color: statusColor),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, color: statusColor, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fencerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connected:
        return Colors.green;
      case DeviceConnectionState.connecting:
      case DeviceConnectionState.reconnecting:
        return Colors.orange;
      case DeviceConnectionState.error:
        return Colors.red;
      case DeviceConnectionState.disconnected:
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connected:
        return Icons.bluetooth_connected;
      case DeviceConnectionState.connecting:
      case DeviceConnectionState.reconnecting:
        return Icons.bluetooth_searching;
      case DeviceConnectionState.error:
        return Icons.error_outline;
      case DeviceConnectionState.disconnected:
      default:
        return Icons.bluetooth_disabled;
    }
  }

  String _getStatusText(DeviceConnectionState state) {
    switch (state) {
      case DeviceConnectionState.connected:
        return 'Connected';
      case DeviceConnectionState.connecting:
        return 'Connecting...';
      case DeviceConnectionState.reconnecting:
        return 'Reconnecting...';
      case DeviceConnectionState.error:
        return 'Connection Error';
      case DeviceConnectionState.disconnected:
      default:
        return 'Disconnected';
    }
  }
} 