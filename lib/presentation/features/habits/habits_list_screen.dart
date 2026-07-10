import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/presentation/shared/widgets/habit_contribution_board.dart';

const List<Color> _habitColors = [
  Color(0xFFEC407A), // Pink
  Color(0xFFFFB300), // Yellow/Orange
  Color(0xFF42A5F5), // Blue
  Color(0xFF66BB6A), // Green
];

const Map<String, IconData> _disponiblesIconos = {
  // Físico
  'run': Icons.directions_run,
  'gym': Icons.fitness_center,
  'bike': Icons.pedal_bike,
  'water': Icons.water_drop,
  'heart': Icons.monitor_heart,
  // Mental
  'book': Icons.menu_book,
  'code': Icons.code,
  'brain': Icons.psychology,
  'brush': Icons.brush,
  'lightbulb': Icons.lightbulb,
  // Espiritual
  'spa': Icons.spa,
  'meditation': Icons.self_improvement,
  'sleep': Icons.bedtime,
  'nature': Icons.nature_people,
  'star': Icons.star,
};

const Map<String, List<String>> _iconosPorAspecto = {
  'físico': ['run', 'gym', 'bike', 'water', 'heart'],
  'mental': ['book', 'code', 'brain', 'brush', 'lightbulb'],
  'espiritual': ['spa', 'meditation', 'sleep', 'nature', 'star'],
};

class HabitsListScreen extends ConsumerStatefulWidget {
  const HabitsListScreen({super.key});

  @override
  ConsumerState<HabitsListScreen> createState() => _HabitsListScreenState();
}

class _HabitsListScreenState extends ConsumerState<HabitsListScreen> {
  late HabitRepository _repository;
  List<MapEntry<dynamic, Habito>> _habitos = [];

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
        _habitos = habitosMap.entries.toList();
      });
      await _verificarResetearPorDia();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar hábitos: $e')),
        );
      }
    }
  }

  Future<void> _verificarResetearPorDia() async {
    final hoy = _obtenerFechaHoy();
    bool cambio = false;
    for (int i = 0; i < _habitos.length; i++) {
      final entry = _habitos[i];
      final habito = entry.value;
      final completadoEnBD = habito.safeFechasCompletadas.contains(hoy);
      if (habito.completadoHoy != completadoEnBD) {
        habito.completadoHoy = completadoEnBD;
        await _repository.update(entry.key, habito);
        _habitos[i] = MapEntry(entry.key, habito);
        cambio = true;
      }
    }
    if (cambio && mounted) {
      setState(() {});
    }
  }

  String _obtenerFechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  IconData _getIconForHabit(Habito habito) {
    final key = habito.iconoKey;
    if (_disponiblesIconos.containsKey(key)) {
      return _disponiblesIconos[key]!;
    }
    return Icons.spa;
  }

  Future<void> _agregarHabitoDialogo(
    String nombre,
    String descripcion,
    String aspecto,
    int vecesPorSemana,
  ) async {
    try {
      final nextId = _habitos.isEmpty
          ? 0
          : _habitos.map((h) => h.value.idHabito).reduce((a, b) => a > b ? a : b) + 1;

      final defaultIconForAspect = {
        'físico': 'run',
        'mental': 'book',
        'espiritual': 'spa',
      };
      final defaultIcon = defaultIconForAspect[aspecto] ?? 'spa';
      final tipoSerializado = "$aspecto|$defaultIcon";

      final nuevoHabito = Habito(
        nextId,
        nombre,
        descripcion.isNotEmpty ? descripcion : 'Cada día cuenta para mejorar.',
        tipoSerializado,
        completadoHoy: false,
        fechaUltimoCompletado: '',
        fechasCompletadas: [],
        vecesPorSemana: vecesPorSemana,
        fechaCreacion: _obtenerFechaHoy(),
      );

      await _repository.add(nuevoHabito);
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
      final entry = _habitos[index];
      final habito = entry.value;
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
      await _repository.update(entry.key, habito);
      setState(() {
        _habitos[index] = MapEntry(entry.key, habito);
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
      final key = _habitos[index].key;
      await _repository.delete(key);
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

  void _mostrarDialogoEditarFrecuencia(int index, dynamic key, Habito habito) {
    int frecuencia = habito.safeVecesPorSemana;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar frecuencia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cuántas veces por semana debería repetirse?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (frecuencia > 1) {
                            setStateDialog(() {
                              frecuencia--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$frecuencia',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          if (frecuencia < 7) {
                            setStateDialog(() {
                              frecuencia++;
                            });
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final dialogContext = context;
                    habito.vecesPorSemana = frecuencia;
                    await _repository.update(key, habito);
                    if (!dialogContext.mounted) return;
                    setState(() {
                      _habitos[index] = MapEntry(key, habito);
                    });
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _mostrarSelectorIconos(int index, dynamic habitKey, Habito habito) {
    final color = _habitColors[habito.idHabito % _habitColors.length];
    final listIconos =
        _iconosPorAspecto[habito.aspecto] ?? _iconosPorAspecto['físico']!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Selector de íconos (${habito.aspecto})'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: listIconos.length,
              itemBuilder: (context, i) {
                final key = listIconos[i];
                final icon = _disponiblesIconos[key]!;
                final esSeleccionado = habito.iconoKey == key;

                return InkWell(
                  onTap: () async {
                    final dialogContext = context;
                    habito.iconoKey = key;
                    await _repository.update(habitKey, habito);
                    if (!dialogContext.mounted) return;
                    setState(() {
                      _habitos[index] = MapEntry(habitKey, habito);
                    });
                    Navigator.of(dialogContext).pop();
                  },                  child: Container(                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: esSeleccionado ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(icon, color: Colors.white),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoAgregarHabito() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    String seleccionadoAspecto = 'físico';
    int vecesPorSemanaSeleccionadas = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nuevo Hábito'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del hábito',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Cada día cuenta para mejorar.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Aspecto:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Físico'),
                          selected: seleccionadoAspecto == 'físico',
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                seleccionadoAspecto = 'físico';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Mental'),
                          selected: seleccionadoAspecto == 'mental',
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                seleccionadoAspecto = 'mental';
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text('Espiritual'),
                          selected: seleccionadoAspecto == 'espiritual',
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                seleccionadoAspecto = 'espiritual';
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Frecuencia semanal:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$vecesPorSemanaSeleccionadas veces por semana',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (vecesPorSemanaSeleccionadas > 1) {
                                  setStateDialog(() {
                                    vecesPorSemanaSeleccionadas--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$vecesPorSemanaSeleccionadas',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                if (vecesPorSemanaSeleccionadas < 7) {
                                  setStateDialog(() {
                                    vecesPorSemanaSeleccionadas++;
                                  });
                                }
                              },
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final nombre = nameController.text.trim();
                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Escribe un nombre')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _agregarHabitoDialogo(
                      nombre,
                      descController.text.trim(),
                      seleccionadoAspecto,
                      vecesPorSemanaSeleccionadas,
                    );
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      nameController.dispose();
      descController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Hábitos',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 80),
                      itemCount: _habitos.length,
                      itemBuilder: (context, index) {
                        final entry = _habitos[index];
                        final habito = entry.value;
                        final color =
                            _habitColors[habito.idHabito % _habitColors.length];
                        final icon = _getIconForHabit(habito);

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
                                        // Icono decorado con fondo opaco y selector interactivo al pulsar
                                        GestureDetector(
                                          onTap: () => _mostrarSelectorIconos(
                                              index, entry.key, habito),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color:
                                                  color.withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              icon,
                                              color: color,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Título y descripción (atributo)
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                  color: Colors.white
                                                      .withValues(alpha: 0.5),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Repite ${habito.safeVecesPorSemana} veces/semana',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.55),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Checkbox premium redondeada
                                        GestureDetector(
                                          onTap: () => _marcarCompletado(index),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: habito.completadoHoy
                                                  ? color
                                                  : Colors.white
                                                      .withValues(alpha: 0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: habito.completadoHoy
                                                    ? Colors.transparent
                                                    : Colors.white.withValues(
                                                        alpha: 0.15),
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              color: habito.completadoHoy
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withValues(alpha: 0.15),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Frecuencia: ${habito.safeVecesPorSemana}/sem',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white
                                                .withValues(alpha: 0.55),
                                          ),
                                        ),
                                        TextButton.icon(
                                          onPressed: () =>
                                              _mostrarDialogoEditarFrecuencia(
                                                  index, entry.key, habito),
                                          icon:
                                              const Icon(Icons.edit, size: 16),
                                          label: const Text('Editar'),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white
                                                .withValues(alpha: 0.75),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Tablero de contribuciones del año alineado por semanas
                                    HabitContributionBoard(
                                      fechasCompletadas:
                                          habito.safeFechasCompletadas,
                                      baseColor: color,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregarHabito,
        child: const Icon(Icons.add),
      ),
    );
  }
}
