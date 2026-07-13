import 'package:flutter/material.dart';

/// Pantalla informativa sobre la técnica Pomodoro
/// Explica qué es, para qué sirve e ideal para qué actividades
class PomodoroInfoScreen extends StatelessWidget {
  const PomodoroInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍅 Técnica Pomodoro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === ENCABEZADO CON EMOJI ===
              Center(
                child: Column(
                  children: [
                    Text(
                      '🍅',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Técnica Pomodoro',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // === ¿QUÉ ES? ===
              Text(
                '¿Qué es?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'La técnica Pomodoro consiste en trabajar durante un periodo corto de tiempo completamente concentrado y luego tomar un descanso breve antes de continuar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // === ¿PARA QUÉ SIRVE? ===
              Text(
                '¿Para qué sirve?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'Ayuda a mantener la concentración, disminuir las distracciones y evitar el cansancio mental durante tareas largas.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // === IDEAL PARA ===
              Text(
                'Ideal para',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildIdealForItem(context, '📚', 'Estudiar'),
                  _buildIdealForItem(context, '📖', 'Leer'),
                  _buildIdealForItem(context, '💻', 'Programar'),
                  _buildIdealForItem(context, '✍️', 'Escribir'),
                  _buildIdealForItem(context, '📝', 'Resolver talleres o tareas'),
                ],
              ),
              const SizedBox(height: 32),

              // === BOTÓN CONTINUAR ===
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/productivity/pomodoro-config'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Configurar sesión'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Volver'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdealForItem(BuildContext context, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
