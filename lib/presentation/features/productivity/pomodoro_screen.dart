import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroScreen extends StatefulWidget {
  final int tiempoTrabajo;
  final int tiempoDescanso;

  const PomodoroScreen({
    super.key,
    this.tiempoTrabajo = 25,
    this.tiempoDescanso = 5,
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late int _totalSeconds;
  late int _remainingSeconds;
  late int _tiempoTrabajo;
  late int _tiempoDescanso;
  Timer? _timer;
  bool _isRunning = false;
  bool _enDescanso = false;
  final _minutesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tiempoTrabajo = widget.tiempoTrabajo;
    _tiempoDescanso = widget.tiempoDescanso;
    _totalSeconds = _tiempoTrabajo * 60;
    _remainingSeconds = _totalSeconds;
    _minutesController.text = '$_tiempoTrabajo';
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  void _start() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _handleSessionEnd();
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
  }

  void _handleSessionEnd() {
    _stopTimer();
    if (!_enDescanso) {
      // Cambiar a descanso
      setState(() {
        _enDescanso = true;
        _totalSeconds = _tiempoDescanso * 60;
        _remainingSeconds = _totalSeconds;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Tiempo de trabajo finalizado! Ahora descansa.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Volver a trabajo
      setState(() {
        _enDescanso = false;
        _totalSeconds = _tiempoTrabajo * 60;
        _remainingSeconds = _totalSeconds;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Descanso finalizado! Vuelve a trabajar.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _pause() {
    _stopTimer();
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => _isRunning = false);
  }

  void _reset() {
    _stopTimer();
    setState(() {
      _enDescanso = false;
      _totalSeconds = _tiempoTrabajo * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _applyMinutes() {
    final text = _minutesController.text.trim();
    final minutes = int.tryParse(text);
    if (minutes == null || minutes <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingresa minutos válidos')));
      }
      return;
    }
    _stopTimer();
    setState(() {
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sessionColor = _enDescanso
        ? Colors.green
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🍅 Pomodoro'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === INDICADOR DE FASE ===
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sessionColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sessionColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _enDescanso ? '☕ Tiempo de descanso' : '⏱ Tiempo de trabajo',
                    style: TextStyle(
                      color: sessionColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // === CRONÓMETRO PRINCIPAL ===
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: sessionColor.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: sessionColor,
                          fontSize: 72,
                        ),
                  ),
                ),
                const SizedBox(height: 32),

                // === INFORMACIÓN DE CONFIGURACIÓN ===
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('Trabajo', style: Theme.of(context).textTheme.labelSmall),
                          Text(
                            '$_tiempoTrabajo min',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      Column(
                        children: [
                          Text('Descanso', style: Theme.of(context).textTheme.labelSmall),
                          Text(
                            '$_tiempoDescanso min',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // === BOTONES DE CONTROL ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.icon(
                      onPressed: _isRunning ? null : _start,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Iniciar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isRunning ? _pause : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pausa'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reiniciar'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // === AJUSTE MANUAL (OPCIONAL) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: _minutesController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Minutos'),
                        onSubmitted: (_) => _applyMinutes(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _applyMinutes,
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
