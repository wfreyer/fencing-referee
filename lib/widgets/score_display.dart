import 'package:flutter/material.dart';

class ScoreDisplay extends StatelessWidget {
  final int fencer;
  final int score;
  final String name;
  final bool isHit;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onNameTap;

  const ScoreDisplay({
    super.key,
    required this.fencer,
    required this.score,
    required this.name,
    required this.isHit,
    required this.onIncrement,
    required this.onDecrement,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onNameTap,
          child: Text(
            name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHit ? Colors.red.withOpacity(0.3) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$score',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: isHit ? Colors.red : null,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: onDecrement,
              icon: const Icon(Icons.remove),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
} 