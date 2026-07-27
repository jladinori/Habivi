import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeynmanInfoScreen extends StatelessWidget {
  const FeynmanInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Técnica Feynman'),
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
                    'La técnica Feynman consiste en explicar un tema utilizando palabras sencillas, como si se lo enseñaras a una persona que nunca lo ha visto.',
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
                    'Permite identificar qué conceptos realmente entiendes y cuáles necesitan ser repasados nuevamente.',
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
                  _buildActivityItem(context, '📚 Preparar exámenes'),
                  _buildActivityItem(context, '🧩 Aprender conceptos difíciles'),
                  _buildActivityItem(context, '🔢 Matemáticas'),
                  _buildActivityItem(context, '💻 Programación'),
                  _buildActivityItem(context, '🔬 Ciencias'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón Empezar explicación
          ElevatedButton.icon(
            onPressed: () => context.push('/productivity/feynman-action'),
            icon: const Icon(Icons.edit),
            label: const Text('Empezar explicación'),
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
