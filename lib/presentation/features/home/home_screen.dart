import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/domain/services/energy_service.dart';

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Habivi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: Stack(
        children: [
          // === FONDO: Personaje GIF que ocupa TODA la pantalla ===
          Positioned.fill(
            child: Container(
              color: colorScheme.surface,
              child: Center(
                child: _buildCharacterPlaceholder(),
              ),
            ),
          ),

          // === OVERLAY: Botones/info sobre el personaje ===
          if (!_isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.surface.withValues(alpha: 0.6),
                      colorScheme.surface.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra de energía compacta
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: energyColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.bolt, color: energyColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Energía',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _energy / 100.0,
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                valueColor: AlwaysStoppedAnimation(energyColor),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$_energy%',
                            style: TextStyle(
                              color: energyColor,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Stats en una fila compacta
                    Row(
                      children: [
                        Expanded(
                          child: _compactStatChip(
                            icon: Icons.check_circle,
                            value: '$_habitsToday',
                            label: 'Hoy',
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactStatChip(
                            icon: Icons.local_fire_department,
                            value: '$_streak',
                            label: 'Racha',
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactStatChip(
                            icon: Icons.stars,
                            value: '$_totalPoints',
                            label: 'Puntos',
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Loading
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  /// Placeholder para el personaje — Aquí irá el GIF/animación que ocupa toda la pantalla.
  /// Para usar un GIF, reemplaza este widget por:
  /// ```dart
  /// Image.asset(
  ///   'assets/images/personaje.gif',
  ///   fit: BoxFit.contain,
  ///   width: double.infinity,
  ///   height: double.infinity,
  /// )
  /// ```
  Widget _buildCharacterPlaceholder() {
    final mood = _energy > 60
        ? '😊'
        : _energy > 30
            ? '😐'
            : '😟';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          mood,
          style: const TextStyle(fontSize: 120),
        ),
        const SizedBox(height: 12),
        Text(
          'Aquí irá tu personaje',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.3),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _compactStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
