import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PlaceholderCard(
          title: 'Pomodoro',
          subtitle: 'Temporizador de sesiones de estudio.',
        ),
        SizedBox(height: 12),
        PlaceholderCard(
          title: 'Métodos de estudio',
          subtitle: 'Técnicas y recursos para mejorar el aprendizaje.',
        ),
      ],
    );
  }
}
