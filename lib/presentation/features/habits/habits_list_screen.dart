import 'package:flutter/material.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class HabitsListScreen extends StatelessWidget {
  const HabitsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        PlaceholderCard(
          title: 'Mis hábitos',
          subtitle: 'Lista de hábitos de estudio y bienestar.',
        ),
      ],
    );
  }
}
