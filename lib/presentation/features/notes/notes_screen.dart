import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PlaceholderCard(
            title: 'Notas',
            subtitle: 'Apuntes rápidos vinculados a tus hábitos y tareas.',
          ),
        ],
      ),
    );
  }
}
