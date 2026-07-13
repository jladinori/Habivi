import 'package:flutter/material.dart';

/// Pantalla de configuración de Pomodoro
/// Permite ajustar tiempos de trabajo y descanso antes de iniciar
class PomodoroConfigScreen extends StatefulWidget {
  const PomodoroConfigScreen({super.key});

  @override
  State<PomodoroConfigScreen> createState() => _PomodoroConfigScreenState();
}

class _PomodoroConfigScreenState extends State<PomodoroConfigScreen> {
  late int _tiempoTrabajo;
  late int _tiempoDescanso;

  @override
  void initState() {
    super.initState();
    _tiempoTrabajo = 25;
    _tiempoDescanso = 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍅 Configurar Pomodoro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // === ENCABEZADO ===
              Center(
                child: Text(
                  'Personaliza tu sesión',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Elige cuánto tiempo dedicarás a trabajar y descansar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // === TIEMPO DE TRABAJO ===
              Text(
                '⏱ Tiempo de trabajo',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_tiempoTrabajo minutos',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickButton(context, '15 min', () {
                          setState(() => _tiempoTrabajo = 15);
                        }),
                        _buildQuickButton(context, '20 min', () {
                          setState(() => _tiempoTrabajo = 20);
                        }),
                        _buildQuickButton(context, '25 min', () {
                          setState(() => _tiempoTrabajo = 25);
                        }),
                        _buildQuickButton(context, '30 min', () {
                          setState(() => _tiempoTrabajo = 30);
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _tiempoTrabajo.toDouble(),
                            min: 5,
                            max: 60,
                            divisions: 55,
                            label: '$_tiempoTrabajo',
                            onChanged: (value) {
                              setState(() => _tiempoTrabajo = value.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // === TIEMPO DE DESCANSO ===
              Text(
                '☕ Tiempo de descanso',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$_tiempoDescanso minutos',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickButton(context, '3 min', () {
                          setState(() => _tiempoDescanso = 3);
                        }),
                        _buildQuickButton(context, '5 min', () {
                          setState(() => _tiempoDescanso = 5);
                        }),
                        _buildQuickButton(context, '10 min', () {
                          setState(() => _tiempoDescanso = 10);
                        }),
                        _buildQuickButton(context, '15 min', () {
                          setState(() => _tiempoDescanso = 15);
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _tiempoDescanso.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            label: '$_tiempoDescanso',
                            onChanged: (value) {
                              setState(() => _tiempoDescanso = value.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // === RESUMEN ===
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '⏱',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trabajo',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '$_tiempoTrabajo min',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '☕',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Descanso',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          '$_tiempoDescanso min',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // === BOTONES ===
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/productivity/pomodoro',
                      arguments: {
                        'tiempoTrabajo': _tiempoTrabajo,
                        'tiempoDescanso': _tiempoDescanso,
                      },
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Comenzar sesión'),
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

  Widget _buildQuickButton(BuildContext context, String label, VoidCallback onPressed) {
    return SizedBox(
      width: 70,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
