import 'package:flutter/material.dart';
import '../models/score_adjustment.dart';

class ScoreHistoryDialog extends StatelessWidget {
  final List<ScoreAdjustment> history;
  final String fencer1Name;
  final String fencer2Name;

  const ScoreHistoryDialog({
    super.key,
    required this.history,
    required this.fencer1Name,
    required this.fencer2Name,
  });

  String _getFencerName(int fencer) {
    switch (fencer) {
      case 0:
        return 'Both Fencers';
      case 1:
        return fencer1Name;
      case 2:
        return fencer2Name;
      default:
        return 'Unknown Fencer';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final timeAgo = DateTime.now().difference(timestamp);
    if (timeAgo.inSeconds < 60) {
      return '${timeAgo.inSeconds}s ago';
    }
    return '${timeAgo.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Score Adjustment History'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: history.length,
          itemBuilder: (context, index) {
            final adjustment = history[history.length - 1 - index]; // Show newest first
            return ListTile(
              title: Text(_getFencerName(adjustment.fencer)),
              subtitle: Text(adjustment.reason),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_getTimeAgo(adjustment.timestamp)),
                  Text(
                    '${adjustment.oldScore} → ${adjustment.newScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
} 