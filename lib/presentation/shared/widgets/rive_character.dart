// rive_character.dart
// Personaje virtual con animacion GIF segun el humor.
// Carga assets/animations/{mood}.gif; si no existe, muestra icono fallback.

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

  String get _assetPath {
    final filename = switch (mood) {
      CharacterMood.feliz => 'feliz.gif',
      CharacterMood.frustrado => 'frustrado.gif',
      CharacterMood.sonoliento => 'sonoliento.gif',
      CharacterMood.apagado => 'apagado.gif',
      CharacterMood.triste => 'triste.gif',
    };
    return 'assets/animations/$filename';
  }

  IconData get _fallbackIcon => switch (mood) {
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
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            _assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(_fallbackIcon, size: size * 0.6, color: color),
              );
            },
          ),
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
