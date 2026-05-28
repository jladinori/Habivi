import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Text(
          'Mproductividad',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        const PlaceholderCard(
          title: 'Pomodoro',
          subtitle: 'Técnica de 25 minutos para mejorar el enfoque.',
        ),
        const SizedBox(height: 12),
        const PlaceholderCard(
          title: 'Métodos de estudio',
          subtitle: 'Técnicas y recursos para mejorar el aprendizaje.',
        ),
      ],
    );
  }
}
