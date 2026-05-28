import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PlaceholderCard(
          title: 'Tareas',
          subtitle: 'Lista de tareas pendientes.',
        ),
      ],
    );
  }
}
