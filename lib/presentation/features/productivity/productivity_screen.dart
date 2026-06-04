import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class ProductivityScreen extends StatelessWidget {
  const ProductivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
        Text(
          'Productividad',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        const PlaceholderCard(
          title: 'Métodos de estudio',
          subtitle: 'Técnicas y recursos para mejorar hábitos.',
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.push('/pomodoro'),
          icon: const Icon(Icons.timer),
          label: const Text('Pomodoro'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
