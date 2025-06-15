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
    final isFencer1 = fencer == 1;
    final color = isFencer1 ? Colors.blue : Colors.red;
    final backgroundColor = isFencer1 
        ? Colors.blue.withOpacity(0.1) 
        : Colors.red.withOpacity(0.1);

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onNameTap,
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isHit ? color.withOpacity(0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: isHit ? color : color.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: Icon(Icons.remove_circle_outline, color: color),
                iconSize: 32,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: onIncrement,
                icon: Icon(Icons.add_circle_outline, color: color),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 