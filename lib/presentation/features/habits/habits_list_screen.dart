import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/presentation/shared/widgets/habit_contribution_board.dart';
import 'package:habivi/core/utils/app_clock.dart';
import 'package:habivi/presentation/providers/dev_mode_provider.dart';
import 'package:habivi/presentation/shared/widgets/suggestions_bottom_sheet.dart';
import 'package:habivi/presentation/shared/widgets/premium_fab.dart';

const List<Color> _habitColors = [
  Color(0xFFEC407A), // Pink
  Color(0xFFFFB300), // Yellow/Orange
  Color(0xFF42A5F5), // Blue
  Color(0xFF66BB6A), // Green
  Color(0xFF7C4DFF), // Purple
  Color(0xFF00BFA5), // Teal
  Color(0xFFFF6D00), // Deep Orange
  Color(0xFFAB47BC), // Purple Accent
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
  // Espiritual / Alma
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

  // Colores personalizados de secciones (almacenados en Hive)
  final Map<String, Color> _sectionColors = {
    'físico': const Color(0xFFEC407A),
    'mental': const Color(0xFFFFB300),
    'espiritual': const Color(0xFF66BB6A),
  };

  // Colores personalizados de cada hábito
  Map<int, Color> _habitCustomColors = {};

  @override
  void initState() {
    super.initState();
    _repository = HabitRepository();
    _loadHabitos();
    _cargarColoresGuardados();
  }

  Future<void> _cargarColoresGuardados() async {
    try {
      final box = await Hive.openBox('settingsBox');

      final fisVal = box.get('sectionColor_físico');
      final menVal = box.get('sectionColor_mental');
      final espVal = box.get('sectionColor_espiritual');

      final Map<int, Color> habitMap = {};
      for (final entry in _habitos) {
        final val = box.get('habitColor_${entry.value.idHabito}');
        if (val != null) {
          habitMap[entry.value.idHabito] = Color(val as int);
        }
      }

      if (mounted) {
        setState(() {
          if (fisVal != null) _sectionColors['físico'] = Color(fisVal as int);
          if (menVal != null) _sectionColors['mental'] = Color(menVal as int);
          if (espVal != null) _sectionColors['espiritual'] = Color(espVal as int);
          _habitCustomColors = habitMap;
        });
      }
    } catch (_) {}
  }

  Future<void> _guardarColorSeccion(String aspectKey, Color color) async {
    try {
      final box = await Hive.openBox('settingsBox');
      await box.put('sectionColor_$aspectKey', color.toARGB32());
      if (mounted) {
        setState(() {
          _sectionColors[aspectKey] = color;
        });
      }
    } catch (_) {}
  }

  Future<void> _guardarColorHabito(int idHabito, Color color) async {
    try {
      final box = await Hive.openBox('settingsBox');
      await box.put('habitColor_$idHabito', color.toARGB32());
      if (mounted) {
        setState(() {
          _habitCustomColors[idHabito] = color;
        });
      }
    } catch (_) {}
  }

  Color _obtenerColorHabito(Habito habito) {
    if (_habitCustomColors.containsKey(habito.idHabito)) {
      return _habitCustomColors[habito.idHabito]!;
    }
    return _habitColors[habito.idHabito % _habitColors.length];
  }

  Future<void> _loadHabitos() async {
    try {
      final habitosMap = await _repository.readAll();
      setState(() {
        _habitos = habitosMap.entries.toList();
      });
      await _verificarResetearPorDia();
      await _cargarColoresGuardados();
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
    final now = AppClock.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  IconData _getIconForHabit(Habito habito) {
    final key = habito.iconoKey;
    if (_disponiblesIconos.containsKey(key)) {
      return _disponiblesIconos[key]!;
    }
    return Icons.spa;
  }

  String _normalizarAspecto(String aspecto) {
    final a = aspecto.toLowerCase();
    if (a.contains('fis') || a.contains('fís')) return 'físico';
    if (a.contains('ment')) return 'mental';
    if (a.contains('espir') || a.contains('alm')) return 'espiritual';
    return 'físico';
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

  Future<void> _marcarCompletado(dynamic key, Habito habito) async {
    try {
      final hoy = _obtenerFechaHoy();

      habito.completadoHoy = !habito.completadoHoy;
      final list = List<String>.from(habito.safeFechasCompletadas);
      if (habito.completadoHoy) {
        if (!list.contains(hoy)) list.add(hoy);
      } else {
        list.remove(hoy);
      }
      habito.fechasCompletadas = list;

      habito.fechaUltimoCompletado =
          list.isEmpty ? '' : list.reduce((a, b) => a.compareTo(b) > 0 ? a : b);

      await _repository.update(key, habito);
      await _loadHabitos();

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

  Future<void> _deleteHabito(dynamic key) async {
    try {
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

  void _mostrarDialogoEditarFrecuencia(dynamic key, Habito habito) {
    int frecuencia = habito.safeVecesPorSemana;
    Color selectedColor = _obtenerColorHabito(habito);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Editar hábito'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frecuencia semanal', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    const SizedBox(height: 20),
                    const Text('Color del hábito', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _habitColors.map((color) {
                        final isSelected = selectedColor.toARGB32() == color.toARGB32();
                        return InkWell(
                          onTap: () {
                            setStateDialog(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
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
                  onPressed: () async {
                    final dialogContext = context;
                    habito.vecesPorSemana = frecuencia;
                    await _repository.update(key, habito);
                    await _guardarColorHabito(habito.idHabito, selectedColor);
                    await _loadHabitos();
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
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

  /// Selector de ícono y color al presionar el ícono del hábito
  void _mostrarSelectorIconoYColor(dynamic habitKey, Habito habito) {
    Color selectedColor = _obtenerColorHabito(habito);
    final aspectoNorm = _normalizarAspecto(habito.aspecto);
    final listIconos =
        _iconosPorAspecto[aspectoNorm] ?? _iconosPorAspecto['físico']!;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Personalizar "${habito.nombreHabito}"'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Color del hábito:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _habitColors.map((color) {
                        final isSelected = selectedColor.toARGB32() == color.toARGB32();
                        return InkWell(
                          onTap: () async {
                            await _guardarColorHabito(habito.idHabito, color);
                            setStateDialog(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Ícono:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.maxFinite,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                              await _loadHabitos();
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: esSeleccionado ? selectedColor : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Listo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Selector de color de sección (al presionar la sección)
  void _mostrarSelectorColorSeccion(String aspectKey, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cambiar color de sección $title'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _habitColors.map((color) {
              final esSeleccionado =
                  (_sectionColors[aspectKey] ?? const Color(0xFFEC407A)).toARGB32() == color.toARGB32();
              return InkWell(
                onTap: () {
                  _guardarColorSeccion(aspectKey, color);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: esSeleccionado ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: esSeleccionado
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: esSeleccionado
                      ? const Icon(Icons.check, color: Colors.white, size: 22)
                      : null,
                ),
              );
            }).toList(),
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
                        'Sección:',
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
                          label: const Text('Alma'),
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

  void _mostrarDialogoDiaDescanso() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Día de descanso'),
          content: const Text(
            'Este día de descanso te permite tomar una pausa sin que tu racha diaria se rompa. '
            'Usa esta ayuda cuando necesites descansar y quieras mantener tu progreso.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  /// Encabezado de sección con soporte de cambio de color al presionar (onTap)
  Widget _buildSectionHeader(
    BuildContext context, {
    required String aspectKey,
    required String title,
    required String subtitle,
    required IconData iconData,
    required Color sectionColor,
    required String tipText,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono circular + Título grande y Subtítulo (Presionar para cambiar color)
          Expanded(
            child: GestureDetector(
              onTap: () => _mostrarSelectorColorSeccion(aspectKey, title),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sectionColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconData,
                      color: sectionColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: sectionColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.6),
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Botón / Card de Sugerencias a la derecha (Presionar abre sugerencias)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => SuggestionsBottomSheet(
                  habitName: title,
                  aspect: aspectKey,
                ),
              );
            },
            child: Container(
              width: 165,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: sectionColor,
                    width: 3.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: sectionColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sugerencias',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: sectionColor,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tipText,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurface.withValues(alpha: 0.65),
                      height: 1.2,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de estado vacío para cuando una sección no tiene hábitos creados
  Widget _buildEmptySection(
    BuildContext context, {
    required Color sectionColor,
    required IconData iconData,
    required String message,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: sectionColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            size: 26,
            color: sectionColor.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                color: cs.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta individual de hábito con el botón de EDITAR en la parte superior derecha junto a la checkbox
  Widget _buildHabitCard(
    BuildContext context,
    MapEntry<dynamic, Habito> entry,
  ) {
    final cs = Theme.of(context).colorScheme;
    final habito = entry.value;
    final color = _obtenerColorHabito(habito);
    final icon = _getIconForHabit(habito);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
                      _deleteHabito(entry.key);
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
                    // Icono del hábito (Tocar para personalizar icono y color)
                    GestureDetector(
                      onTap: () => _mostrarSelectorIconoYColor(entry.key, habito),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Título y detalles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habito.nombreHabito,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Repite ${habito.safeVecesPorSemana} veces/semana',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                          Text(
                            habito.atributo.isNotEmpty
                                ? habito.atributo
                                : 'Cada día cuenta para mejorar.',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // === BOTÓN EDITAR EN LA PARTE SUPERIOR (Al lado del botón de check) ===
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: cs.onSurface.withValues(alpha: 0.55),
                      ),
                      tooltip: 'Editar hábito',
                      onPressed: () => _mostrarDialogoEditarFrecuencia(
                          entry.key, habito),
                    ),
                    const SizedBox(width: 2),
                    // Checkbox redondeada
                    GestureDetector(
                      onTap: () => _marcarCompletado(entry.key, habito),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: habito.completadoHoy
                              ? color
                              : cs.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: habito.completadoHoy
                                ? Colors.transparent
                                : cs.onSurface.withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.check,
                          color: habito.completadoHoy
                              ? Colors.white
                              : cs.onSurface.withValues(alpha: 0.05),
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Tablero de contribuciones del año alineado por semanas
                HabitContributionBoard(
                  fechasCompletadas: habito.safeFechasCompletadas,
                  baseColor: color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timeOffsetProvider, (prev, next) {
      _loadHabitos();
    });

    final habitosFisico = _habitos
        .where((e) => _normalizarAspecto(e.value.aspecto) == 'físico')
        .toList();
    final habitosMental = _habitos
        .where((e) => _normalizarAspecto(e.value.aspecto) == 'mental')
        .toList();
    final habitosAlma = _habitos
        .where((e) => _normalizarAspecto(e.value.aspecto) == 'espiritual')
        .toList();

    final colorFisico = _sectionColors['físico'] ?? const Color(0xFFEC407A);
    final colorMental = _sectionColors['mental'] ?? const Color(0xFFFFB300);
    final colorAlma = _sectionColors['espiritual'] ?? const Color(0xFF66BB6A);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hábitos',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bedtime_outlined),
                    tooltip: 'Día de descanso',
                    onPressed: _mostrarDialogoDiaDescanso,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 80),
                children: [
                  // === 1. SECCIÓN FÍSICO ===
                  _buildSectionHeader(
                    context,
                    aspectKey: 'físico',
                    title: 'Físico',
                    subtitle: 'Cuida tu cuerpo, mejora tu energía y salud.',
                    iconData: Icons.directions_run,
                    sectionColor: colorFisico,
                    tipText: 'Intenta mantenerte activo todos los días, aunque sea 10 minutos.',
                  ),
                  if (habitosFisico.isEmpty)
                    _buildEmptySection(
                      context,
                      sectionColor: colorFisico,
                      iconData: Icons.directions_run,
                      message: '¡Cuida tu cuerpo! Agrega tu primer hábito en la sección Físico presionando +.',
                    )
                  else
                    ...habitosFisico.map((entry) => _buildHabitCard(context, entry)),

                  const SizedBox(height: 20),

                  // === 2. SECCIÓN MENTAL ===
                  _buildSectionHeader(
                    context,
                    aspectKey: 'mental',
                    title: 'Mental',
                    subtitle: 'Entrena tu mente, aprende y enfócate.',
                    iconData: Icons.psychology,
                    sectionColor: colorMental,
                    tipText: 'Dedica 15 minutos a la lectura o aprender algo nuevo hoy.',
                  ),
                  if (habitosMental.isEmpty)
                    _buildEmptySection(
                      context,
                      sectionColor: colorMental,
                      iconData: Icons.psychology,
                      message: '¡Entrena tu mente! Agrega tu primer hábito en la sección Mental presionando +.',
                    )
                  else
                    ...habitosMental.map((entry) => _buildHabitCard(context, entry)),

                  const SizedBox(height: 20),

                  // === 3. SECCIÓN ALMA ===
                  _buildSectionHeader(
                    context,
                    aspectKey: 'espiritual',
                    title: 'Alma',
                    subtitle: 'Nutre tu paz interior, propósito y gratitud.',
                    iconData: Icons.spa,
                    sectionColor: colorAlma,
                    tipText: 'Realiza 5 minutos de meditación o gratitud al despertar.',
                  ),
                  if (habitosAlma.isEmpty)
                    _buildEmptySection(
                      context,
                      sectionColor: colorAlma,
                      iconData: Icons.spa,
                      message: '¡Nutre tu paz interior! Agrega tu primer hábito en la sección Alma presionando +.',
                    )
                  else
                    ...habitosAlma.map((entry) => _buildHabitCard(context, entry)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: PremiumFAB(
        onPressed: _mostrarDialogoAgregarHabito,
      ),
    );
  }
}
