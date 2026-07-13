import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveRecallInfoScreen extends StatelessWidget {
  const ActiveRecallInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Active Recall'),
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
                    'Consiste en intentar recordar la información sin consultar los apuntes y verificar posteriormente si la respuesta fue correcta.',
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
                    'Fortalece la memoria y mejora el aprendizaje a largo plazo.',
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
                  _buildActivityItem(context, '🧠 Memorizar conceptos'),
                  _buildActivityItem(context, '🌍 Idiomas'),
                  _buildActivityItem(context, '⚕️ Medicina'),
                  _buildActivityItem(context, '📖 Historia'),
                  _buildActivityItem(context, '📚 Preparación de exámenes'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón Comenzar práctica
          ElevatedButton.icon(
            onPressed: () => context.push('/productivity/active-recall-action'),
            icon: const Icon(Icons.quiz),
            label: const Text('Comenzar práctica'),
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
