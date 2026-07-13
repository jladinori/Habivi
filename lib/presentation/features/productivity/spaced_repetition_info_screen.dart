import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SpacedRepetitionInfoScreen extends StatelessWidget {
  const SpacedRepetitionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Repetición Espaciada'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          
          // ¿Qué es?
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Qué es?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Es una técnica que consiste en repasar la información en intervalos de tiempo cada vez mayores.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ¿Para qué sirve?
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Para qué sirve?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reduce el olvido y mejora la retención del conocimiento durante semanas o meses.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ideal para
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ideal para',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildActivityItem(context, '🌍 Idiomas'),
                  _buildActivityItem(context, '📚 Definiciones'),
                  _buildActivityItem(context, '🔢 Fórmulas'),
                  _buildActivityItem(context, '🧬 Biología'),
                  _buildActivityItem(context, '⚖️ Derecho'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón Programar repasos
          ElevatedButton.icon(
            onPressed: () => context.push('/productivity/spaced-repetition-action'),
            icon: const Icon(Icons.schedule),
            label: const Text('Programar repasos'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            activity,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
