import 'package:flutter/material.dart';
import 'package:habivi/domain/models/habit_suggestion.dart';
import 'package:habivi/domain/services/habit_suggestions_service.dart';

/// Modal que muestra sugerencias contextualizadas para un hábito específico
class SuggestionsBottomSheet extends StatelessWidget {
  final String habitName;
  final String aspect; // "físico", "mental", "espiritual"

  const SuggestionsBottomSheet({
    super.key,
    required this.habitName,
    required this.aspect,
  });

  @override
  Widget build(BuildContext context) {
    final suggestion = HabitSuggestionsService.getSuggestionByAspect(aspect);

    if (suggestion == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Sugerencias no disponibles para este tipo de hábito.'),
      );
    }

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ENCABEZADO ===
              Row(
                children: [
                  Text(
                    suggestion.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sugerencias para $habitName',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          suggestion.categoria,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // === DESCRIPCIÓN ===
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  suggestion.descripcion,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // === ACCIONES RÁPIDAS ===
              Text(
                '🚀 Acciones rápidas para empezar',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  ...suggestion.quickActions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final action = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < suggestion.quickActions.length - 1 ? 10 : 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                action,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // === CONSEJOS ===
              Text(
                '💡 Consejos prácticos',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  ...suggestion.tips.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tip = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(bottom: index < suggestion.tips.length - 1 ? 10 : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4, right: 8),
                            child: Text(
                              '•',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              tip,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),

              // === BOTÓN DE ACCIÓN ===
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Entendido'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
