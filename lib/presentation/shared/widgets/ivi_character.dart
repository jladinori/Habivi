import 'package:flutter/material.dart';
import 'package:habivi/domain/enums/character_mood.dart';

class IviCharacter extends StatelessWidget {
  const IviCharacter({
    super.key,
    required this.mood,
    this.size = 130,
    this.showMessage = true,
  });

  final CharacterMood mood;
  final double size;
  final bool showMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          decoration: BoxDecoration(
            color: mood.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(mood.icon, key: ValueKey(mood), size: size, color: mood.color),
              ),
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
        ),
        if (showMessage) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              mood.mensaje,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }
}
