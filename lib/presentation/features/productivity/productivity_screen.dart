import 'dart:async';
import 'package:flutter/material.dart';
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
          subtitle: 'Técnicas y recursos para mejorar hábitos holaaaaaaa.',
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 8),
        const Text('Pomodoro', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        PomodoroCard(),
      ],
    );
  }
}

class PomodoroCard extends StatefulWidget {
  const PomodoroCard({super.key});

  @override
  State<PomodoroCard> createState() => _PomodoroCardState();
}

class _PomodoroCardState extends State<PomodoroCard> {
  int _totalSeconds = 25 * 60;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;
  final _minutesController = TextEditingController(text: '25');

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
        _stopTimer();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('¡Sesión finalizada!')));
        return;
      }
      setState(() => _remainingSeconds -= 1);
    });
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
    setState(() => _remainingSeconds = _totalSeconds);
  }

  void _applyMinutes() {
    final text = _minutesController.text.trim();
    final minutes = int.tryParse(text);
    if (minutes == null || minutes <= 0) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingresa minutos válidos')));
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_formatTime(_remainingSeconds),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min'),
                    onSubmitted: (_) => _applyMinutes(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                    onPressed: _applyMinutes, child: const Text('Set')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed: _isRunning ? null : _start,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: _isRunning ? _pause : null,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                    onPressed: _reset,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
