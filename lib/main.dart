import 'package:flutter/material.dart';
import 'services/bluetooth_service.dart';

void main() {
  runApp(const FencingRefereeApp());
}

class FencingRefereeApp extends StatelessWidget {
  const FencingRefereeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fencing Referee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScoringPage(),
    );
  }
}

class ScoringPage extends StatefulWidget {
  const ScoringPage({super.key});

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  int _scoreFencer1 = 0;
  int _scoreFencer2 = 0;
  int _period = 1;
  String _fencer1Name = 'Fencer 1';
  String _fencer2Name = 'Fencer 2';
  final TextEditingController _nameController1 = TextEditingController();
  final TextEditingController _nameController2 = TextEditingController();
  final BluetoothService _bluetoothService = BluetoothService();
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;

  @override
  void initState() {
    super.initState();
    _nameController1.text = _fencer1Name;
    _nameController2.text = _fencer2Name;
    _setupBluetoothService();
  }

  void _setupBluetoothService() {
    _bluetoothService.connectionState.listen((state) {
      setState(() {
        _connectionState = state;
      });
    });

    _bluetoothService.scoreUpdates.listen((data) {
      setState(() {
        if (data['fencer'] == 1) {
          _scoreFencer1 = data['score'];
        } else if (data['fencer'] == 2) {
          _scoreFencer2 = data['score'];
        }
      });
    });
  }

  @override
  void dispose() {
    _nameController1.dispose();
    _nameController2.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }

  void _incrementScore(int fencer) {
    setState(() {
      if (fencer == 1) {
        _scoreFencer1++;
      } else {
        _scoreFencer2++;
      }
    });
  }

  void _decrementScore(int fencer) {
    setState(() {
      if (fencer == 1 && _scoreFencer1 > 0) {
        _scoreFencer1--;
      } else if (fencer == 2 && _scoreFencer2 > 0) {
        _scoreFencer2--;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_period < 3) {
        _period++;
      }
    });
  }

  void _resetMatch() {
    setState(() {
      _scoreFencer1 = 0;
      _scoreFencer2 = 0;
      _period = 1;
    });
  }

  void _showNameDialog(int fencer) {
    final controller = fencer == 1 ? _nameController1 : _nameController2;
    final currentName = fencer == 1 ? _fencer1Name : _fencer2Name;
    controller.text = currentName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter ${fencer == 1 ? "Left" : "Right"} Fencer Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (fencer == 1) {
                  _fencer1Name = controller.text.isEmpty ? 'Fencer 1' : controller.text;
                } else {
                  _fencer2Name = controller.text.isEmpty ? 'Fencer 2' : controller.text;
                }
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: ${_connectionState.name}'),
            const SizedBox(height: 16),
            if (_connectionState == DeviceConnectionState.disconnected)
              ElevatedButton(
                onPressed: () {
                  _bluetoothService.startScan();
                  Navigator.pop(context);
                },
                child: const Text('Scan for Weapons'),
              ),
            if (_connectionState == DeviceConnectionState.connected)
              ElevatedButton(
                onPressed: () {
                  _bluetoothService.disconnectAll();
                  Navigator.pop(context);
                },
                child: const Text('Disconnect'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fencing Referee'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _connectionState == DeviceConnectionState.connected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: _connectionState == DeviceConnectionState.connected
                  ? Colors.green
                  : Colors.red,
            ),
            onPressed: _showBluetoothDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Period Display
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Period $_period',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),

          // Score Display
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Fencer 1
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showNameDialog(1),
                      child: Text(
                        _fencer1Name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '$_scoreFencer1',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _decrementScore(1),
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: () => _incrementScore(1),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),

                // Fencer 2
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showNameDialog(2),
                      child: Text(
                        _fencer2Name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      '$_scoreFencer2',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _decrementScore(2),
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: () => _incrementScore(2),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Control Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _nextPeriod,
                  child: const Text('Next Period'),
                ),
                ElevatedButton(
                  onPressed: _resetMatch,
                  child: const Text('Reset Match'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
