import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class HabitDetailScreen extends StatelessWidget {
  const HabitDetailScreen({super.key, required this.habitId});

  final String habitId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hábito #$habitId')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlaceholderCard(
            title: 'Detalle del hábito',
            subtitle: 'Registros y estadísticas del hábito $habitId.',
          ),
        ],
      ),
    );
  }
}
