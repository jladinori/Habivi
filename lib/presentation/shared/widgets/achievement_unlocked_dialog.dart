import 'package:flutter/material.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';

Future<void> showAchievementUnlockedDialog(BuildContext context, AchievementDef def) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('¡Logro desbloqueado!', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(def.icono, size: 56, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 16),
          Text(def.titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(def.descripcion, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('¡Genial!')),
      ],
    ),
  );
}
