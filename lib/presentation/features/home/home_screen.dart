import 'package:flutter/material.dart';
import 'package:habivi/domain/services/mood_service.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';
import 'package:habivi/presentation/shared/widgets/rive_character.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mood = MoodService().calculate();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: RiveCharacter(mood: mood)),
        const SizedBox(height: 24),
        const PlaceholderCard(
          title: 'Resumen del día',
          subtitle: 'Aquí verás tu progreso de hábitos universitarios.',
        ),
      ],
    );
  }
}
