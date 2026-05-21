import 'package:flutter/material.dart';
import 'package:habivi/domain/enums/character_mood.dart';

/// Placeholder del personaje. Sustituir por animación Rive en fase posterior.
class RiveCharacter extends StatelessWidget {
  const RiveCharacter({super.key, required this.mood});

  final CharacterMood mood;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mood) {
      CharacterMood.feliz => Icons.sentiment_very_satisfied,
      CharacterMood.neutral => Icons.sentiment_neutral,
      CharacterMood.triste => Icons.sentiment_dissatisfied,
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 120, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          mood.label,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
}
