import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/presentation/shared/widgets/habit_contribution_board.dart';

class _HabitTheme {
  final Color color;
  final IconData icon;

  const _HabitTheme(this.color, this.icon);
}

const List<_HabitTheme> _habitThemes = [
  _HabitTheme(Color(0xFFEC407A), Icons.spa),          // Pink
  _HabitTheme(Color(0xFFFFB300), Icons.monitor_heart), // Yellow/Orange
  _HabitTheme(Color(0xFF42A5F5), Icons.menu_book),     // Blue
  _HabitTheme(Color(0xFF66BB6A), Icons.smoking_rooms),  // Green
];

class HabitsListScreen extends ConsumerStatefulWidget {
  const HabitsListScreen({super.key});

  @override
  ConsumerState<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends ConsumerState<HabitsListScreen> {
  late HabitRepository _repository;
  List<Habito> _habitos = [];
  final _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = HabitRepository();
    _loadHabitos();
  }

  Future<void> _loadHabitos() async {
    try {
      final habitosMap = await _repository.readAll();
      setState(() {
        _habitos = habitosMap.values.toList();
        // Sincronizar y resetear por día si es necesario
        _verificarResetearPorDia();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar hábitos: $e')),
        );
      }
    }
  }

  void _verificarResetearPorDia() {
    final hoy = _obtenerFechaHoy();
    bool cambio = false;
    for (int i = 0; i < _habitos.length; i++) {
      final habito = _habitos[i];
      final completadoEnBD = habito.safeFechasCompletadas.contains(hoy);
      if (habito.completadoHoy != completadoEnBD) {
        habito.completadoHoy = completadoEnBD;
        _repository.updateAt(i, habito);
        cambio = true;
      }
    }
    if (cambio) {
      setState(() {});
    }
  }

  String _obtenerFechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _addHabito() async {
    if (_nombreController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un nombre')),
      );
      return;
    }

    try {
      final nuevoHabito = Habito(
        _habitos.isEmpty ? 0 : _habitos.map((h) => h.idHabito).reduce((a, b) => a > b ? a : b) + 1,
        _nombreController.text.trim(),
        'Cada día cuenta para mejorar.',
        'positivo',
        completadoHoy: false,
        fechaUltimoCompletado: '',
        fechasCompletadas: [],
      );
      await _repository.add(nuevoHabito);
      _nombreController.clear();
      await _loadHabitos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar hábito: $e')),
        );
      }
    }
  }

  Future<void> _marcarCompletado(int index) async {
    try {
      final habito = _habitos[index];
      final hoy = _obtenerFechaHoy();
      habito.completadoHoy = !habito.completadoHoy;
      habito.fechaUltimoCompletado = hoy;

      final list = List<String>.from(habito.safeFechasCompletadas);
      if (habito.completadoHoy) {
        if (!list.contains(hoy)) {
          list.add(hoy);
        }
      } else {
        list.remove(hoy);
      }
      habito.fechasCompletadas = list;

      // Guardar el cambio en la BD local
      await _repository.updateAt(index, habito);
      setState(() {
        _habitos[index] = habito;
      });

      if (mounted && habito.completadoHoy) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Completaste "${habito.nombreHabito}" hoy'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    }
  }

  Future<void> _deleteHabito(int index) async {
    try {
      await _repository.deleteAt(index);
      await _loadHabitos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hábito eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hábitos',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            hintText: 'Nuevo hábito...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addHabito(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _addHabito,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _habitos.isEmpty
                  ? Center(
                      child: Text(
                        'No hay hábitos aún',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _habitos.length,
                      itemBuilder: (context, index) {
                        final habito = _habitos[index];
                        final theme = _habitThemes[index % _habitThemes.length];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Eliminar hábito'),
                                    content: Text(
                                      '¿Eliminar "${habito.nombreHabito}"?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteHabito(index);
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Eliminar'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Icono decorado con fondo opaco
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: theme.color.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            theme.icon,
                                            color: theme.color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Título y descripción (atributo)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                habito.nombreHabito,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                habito.atributo.isNotEmpty
                                                    ? habito.atributo
                                                    : 'Cada día cuenta para mejorar.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Checkbox premium redondeada
                                        GestureDetector(
                                          onTap: () => _marcarCompletado(index),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: habito.completadoHoy
                                                  ? theme.color
                                                  : Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                color: habito.completadoHoy
                                                    ? Colors.transparent
                                                    : Colors.white.withOpacity(0.15),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: habito.completadoHoy
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.15),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Tablero de contribuciones del año
                                    HabitContributionBoard(
                                      fechasCompletadas: habito.safeFechasCompletadas,
                                      baseColor: theme.color,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
