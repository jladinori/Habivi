import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

/// Pantalla de notas (accesible por rutas secundarias en el futuro).
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PlaceholderCard(
          title: 'Notas',
          subtitle: 'Apuntes rápidos vinculados a tus hábitos y tareas.',
        ),
      ],
    );
  }
}
