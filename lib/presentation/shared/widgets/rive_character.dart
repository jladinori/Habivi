import 'package:flutter/material.dart';

class RiveCharacter extends StatelessWidget {
  final int energy;

  const RiveCharacter({super.key, required this.energy});

  @override
  Widget build(BuildContext context) {
    const feliz = _MoodData(Icons.sentiment_very_satisfied, 'Feliz', Colors.green);
    const neutral = _MoodData(Icons.sentiment_neutral, 'Neutral', Colors.orange);
    const triste = _MoodData(Icons.sentiment_dissatisfied, 'Triste', Colors.red);
    final mood = energy > 60 ? feliz : energy > 30 ? neutral : triste;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        color: mood.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mood.icon, size: 100, color: mood.color),
          const SizedBox(height: 8),
          Text(
            mood.label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: mood.color,
                ),
          ),
        ],
      ),
    );
  }
}

class _MoodData {
  final IconData icon;
  final String label;
  final Color color;
  const _MoodData(this.icon, this.label, this.color);
}
