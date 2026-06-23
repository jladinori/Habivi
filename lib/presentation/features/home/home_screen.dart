import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/domain/services/energy_service.dart';
import 'package:habivi/presentation/shared/widgets/rive_character.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late EstudioRepository _estudioRepo;
  int _energy = 100;
  int _habitsToday = 0;
  int _streak = 0;
  int _totalPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _estudioRepo = EstudioRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final energy = await EnergyService.calculate();
      final habitsToday = await EnergyService.habitosCompletadosHoy();
      final streak = await EnergyService.rachaActual();
      final totalPoints = await _estudioRepo.totalPuntos();
      if (mounted) {
        setState(() {
          _energy = energy;
          _habitsToday = habitsToday;
          _streak = streak;
          _totalPoints = totalPoints;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final energyColor = _energy > 60
        ? Colors.green
        : _energy > 30
            ? Colors.orange
            : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habivi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isLoading) ...[
              Center(child: RiveCharacter(energy: _energy)),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Energía', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text('$_energy%', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: energyColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _energy / 100.0,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(energyColor),
                          minHeight: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      icon: Icons.check_circle,
                      value: '$_habitsToday',
                      label: 'Hábitos hoy',
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      icon: Icons.local_fire_department,
                      value: '$_streak',
                      label: 'Racha (días)',
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      icon: Icons.stars,
                      value: '$_totalPoints',
                      label: 'Puntos',
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Resumen del día',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _resumenItem(Icons.check_circle_outline, 'Completa hábitos para recargar energía', _habitsToday > 0),
                      const Divider(height: 24),
                      _resumenItem(Icons.timer_outlined, 'Usa Pomodoro para sesiones de enfoque', false),
                      const Divider(height: 24),
                      _resumenItem(Icons.psychology_outlined, 'Balancea cuerpo, mente y alma', false),
                    ],
                  ),
                ),
              ),
            ] else
              const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statCard({required IconData icon, required String value, required String label, required Color color}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _resumenItem(IconData icon, String text, bool done) {
    return Row(
      children: [
        Icon(icon, size: 20, color: done ? Colors.green : Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: done ? 0.8 : 0.5),
            ),
          ),
        ),
        if (done) const Icon(Icons.check, size: 16, color: Colors.green),
      ],
    );
  }
}
