import 'package:flutter/material.dart';
import 'package:habivi/domain/enums/character_mood.dart';

class RiveCharacter extends StatelessWidget {
  const RiveCharacter({
    super.key,
    required this.mood,
    this.size = 200,
  });

  final CharacterMood mood;
  final double size;

  IconData get _icon => switch (mood) {
        CharacterMood.feliz => Icons.sentiment_very_satisfied,
        CharacterMood.frustrado => Icons.sentiment_very_dissatisfied,
        CharacterMood.sonoliento => Icons.nightlight_round,
        CharacterMood.apagado => Icons.mood_bad,
        CharacterMood.triste => Icons.sentiment_dissatisfied,
      };

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(_icon, size: size * 0.5, color: color),
        ),
        const SizedBox(height: 12),
        Text(
          mood.label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
