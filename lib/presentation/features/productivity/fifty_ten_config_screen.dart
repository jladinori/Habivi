import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FiftyTenConfigScreen extends StatefulWidget {
  const FiftyTenConfigScreen({super.key});

  @override
  State<FiftyTenConfigScreen> createState() => _FiftyTenConfigScreenState();
}

class _FiftyTenConfigScreenState extends State<FiftyTenConfigScreen> {
  late int tiempoTrabajo;
  late int tiempoDescanso;

  @override
  void initState() {
    super.initState();
    tiempoTrabajo = 50;
    tiempoDescanso = 10;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ Configurar sesión'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),
          
          // Tiempo de trabajo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiempo de trabajo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$tiempoTrabajo min',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: tiempoTrabajo.toDouble(),
                    min: 20,
                    max: 90,
                    divisions: 14,
                    onChanged: (value) {
                      setState(() => tiempoTrabajo = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tiempo de descanso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiempo de descanso',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '$tiempoDescanso min',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: tiempoDescanso.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 5,
                    onChanged: (value) {
                      setState(() => tiempoDescanso = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Resumen
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '⏱️  $tiempoTrabajo minutos de trabajo',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '☕ $tiempoDescanso minutos de descanso',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botón Comenzar sesión
          ElevatedButton.icon(
            onPressed: () => context.push(
              '/productivity/fifty-ten-timer',
              extra: {
                'tiempoTrabajo': tiempoTrabajo,
                'tiempoDescanso': tiempoDescanso,
              },
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Comenzar sesión'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
