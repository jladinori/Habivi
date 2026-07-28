import 'package:flutter/material.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/repositories/task_repository.dart';

// Colores para las tarjetas de pendientes (rotación cíclica)
const List<Color> _taskColors = [
  Color(0xFF7C4DFF), // Purple accent
  Color(0xFF00BFA5), // Teal accent
  Color(0xFFFF6D00), // Orange accent
  Color(0xFF448AFF), // Blue accent
  Color(0xFFEC407A), // Pink
  Color(0xFF66BB6A), // Green
];

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late TaskRepository _repository;
  List<MapEntry<dynamic, Tarea>> _tareas = [];
  bool _isLoading = true;
  bool _completadosExpanded = true;
  bool _archivadosExpanded = false;

  @override
  void initState() {
    super.initState();
    _repository = TaskRepository();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    try {
      final box = await _repository.box;
      final entries = box.keys
          .map((k) => MapEntry(k, box.get(k) as Tarea))
          .toList();
      if (mounted) {
        setState(() {
          _tareas = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _agregarPendiente(String nombre, String fecha, String notas) async {
    try {
      final nuevaTarea = Tarea(
        DateTime.now().millisecondsSinceEpoch,
        nombre,
        0,
        fecha: fecha,
        notas: notas,
        completada: false,
      );
      await _repository.add(nuevaTarea);
      await _cargarTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Pendiente agregado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _completarPendiente(dynamic key) async {
    try {
      final box = await _repository.box;
      final tarea = box.get(key);
      if (tarea != null) {
        tarea.completada = !tarea.completada;
        await box.put(key, tarea);
        await box.flush();
      }
      await _cargarTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _eliminarPendiente(dynamic key) async {
    try {
      final box = await _repository.box;
      await box.delete(key);
      await box.flush();
      await _cargarTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _archivarPendiente(dynamic key) async {
    try {
      final box = await _repository.box;
      final tarea = box.get(key);
      if (tarea != null) {
        tarea.archivada = !(tarea.archivada);
        await box.put(key, tarea);
        await box.flush();
      }
      await _cargarTareas();
      if (mounted && tarea != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tarea.archivada ? '✓ Archivado' : '✓ Restaurado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarDialogoAgregar() {
    final controladorNombre = TextEditingController();
    final controladorNotas = TextEditingController();
    DateTime? fechaSeleccionada;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nuevo pendiente'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controladorNombre,
                      decoration: const InputDecoration(
                        labelText: 'Pendiente',
                        hintText: 'Escribe el pendiente...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controladorNotas,
                      decoration: const InputDecoration(
                        labelText: 'Notas (opcional)',
                        hintText: 'Escribe notas...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fechaSeleccionada == null
                                ? 'Sin fecha'
                                : '📅 ${fechaSeleccionada!.day}/${fechaSeleccionada!.month}/${fechaSeleccionada!.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final fecha = await showDatePicker(
                              context: dialogContext,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (fecha != null) {
                              setStateDialog(() {
                                fechaSeleccionada = fecha;
                              });
                            }
                          },
                          child: const Text('📅'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controladorNombre.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Escribe un pendiente')),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext);
                    final fechaStr =
                        fechaSeleccionada != null ? _formatDate(fechaSeleccionada!) : '';
                    _agregarPendiente(
                      controladorNombre.text.trim(),
                      fechaStr,
                      controladorNotas.text.trim(),
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
      controladorNombre.dispose();
      controladorNotas.dispose();
    });
  }

  /// Tarjeta de pendiente ACTIVO — estilo premium igual a hábitos
  Widget _buildActivaCard(BuildContext context, dynamic key, Tarea tarea, int index) {
    final cs = Theme.of(context).colorScheme;
    final color = _taskColors[tarea.idTarea % _taskColors.length];

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar pendiente'),
              content: Text('¿Eliminar "${tarea.nombreTarea}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _eliminarPendiente(key);
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
          child: Row(
            children: [
              // Icono decorativo con fondo de color
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.nombreTarea,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tarea.notas.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tarea.notas,
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (tarea.fecha.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            tarea.fecha,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón de check — colorido, a la derecha
              GestureDetector(
                onTap: () => _completarPendiente(key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: color.withValues(alpha: 0.4),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón archivar
              GestureDetector(
                onTap: () => _archivarPendiente(key),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.archive_outlined,
                    color: cs.onSurface.withValues(alpha: 0.45),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarjeta de pendiente COMPLETADO — tachado, estilo atenuado
  Widget _buildCompletadaCard(BuildContext context, dynamic key, Tarea tarea) {
    final cs = Theme.of(context).colorScheme;
    final color = _taskColors[tarea.idTarea % _taskColors.length];

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar pendiente'),
              content: Text('¿Eliminar "${tarea.nombreTarea}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _eliminarPendiente(key);
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icono completado (check)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: color.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Nombre tachado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.nombreTarea,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.4),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: cs.onSurface.withValues(alpha: 0.3),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tarea.fecha.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tarea.fecha,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.25),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Botón para descompletar (restaurar)
              GestureDetector(
                onTap: () => _completarPendiente(key),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.undo,
                    color: cs.onSurface.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón desarchivar (restaurar de archivados)
              GestureDetector(
                onTap: () => _archivarPendiente(key),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.unarchive_outlined,
                    color: cs.onSurface.withValues(alpha: 0.45),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tarjeta de pendiente ARCHIVADO — estilo atenuado y con opción de restaurar
  Widget _buildArchivadaCard(BuildContext context, dynamic key, Tarea tarea) {
    final cs = Theme.of(context).colorScheme;
    final color = _taskColors[tarea.idTarea % _taskColors.length];

    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text('Eliminar pendiente'),
              content: Text('¿Eliminar "${tarea.nombreTarea}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _eliminarPendiente(key);
                  },
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        color: cs.surfaceVariant,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.archive,
                  color: color.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tarea.nombreTarea,
                      style: TextStyle(
                        fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tarea.fecha.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        tarea.fecha,
                        style: TextStyle(
                          fontSize: 11,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _archivarPendiente(key),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.unarchive_outlined,
                    color: cs.onSurface.withValues(alpha: 0.45),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tareasActivas = _tareas.where((t) => !t.value.completada && !t.value.archivada).toList();
    final tareasCompletadas = _tareas.where((t) => t.value.completada && !t.value.archivada).toList();
    final tareasArchivadas = _tareas.where((t) => t.value.archivada).toList();

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Pendientes',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Expanded(
                    child: tareasActivas.isEmpty && tareasCompletadas.isEmpty && tareasArchivadas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 48,
                                  color: cs.onSurface.withValues(alpha: 0.15),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sin pendientes',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: cs.onSurface.withValues(alpha: 0.4),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Toca + para agregar uno',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onSurface.withValues(alpha: 0.25),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 80,
                            ),
                            children: [
                              // === SECCIÓN: Pendientes activos ===
                              ...tareasActivas.asMap().entries.map((mapEntry) {
                                final index = mapEntry.key;
                                final entry = mapEntry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildActivaCard(
                                    context,
                                    entry.key,
                                    entry.value,
                                    index,
                                  ),
                                );
                              }),

                              // === SEPARADOR ===
                              if (tareasCompletadas.isNotEmpty) ...[
                                if (tareasActivas.isNotEmpty)
                                  const SizedBox(height: 8),

                                // Encabezado de sección completados (colapsable)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _completadosExpanded = !_completadosExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        // Línea decorativa izquierda
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: cs.onSurface.withValues(alpha: 0.08),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _completadosExpanded
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_right,
                                                size: 18,
                                                color: cs.onSurface.withValues(alpha: 0.4),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Completados (${tareasCompletadas.length})',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: cs.onSurface.withValues(alpha: 0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Línea decorativa derecha
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: cs.onSurface.withValues(alpha: 0.08),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Lista de completados (colapsable con animación)
                                AnimatedCrossFade(
                                  firstChild: Column(
                                    children: tareasCompletadas.map((entry) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: _buildCompletadaCard(
                                          context,
                                          entry.key,
                                          entry.value,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  secondChild: const SizedBox.shrink(),
                                  crossFadeState: _completadosExpanded
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: const Duration(milliseconds: 250),
                                ),
                              ],

                              // === ARCHIVADOS ===
                              if (tareasArchivadas.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _archivadosExpanded = !_archivadosExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: cs.onSurface.withValues(alpha: 0.08),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _archivadosExpanded
                                                    ? Icons.keyboard_arrow_down
                                                    : Icons.keyboard_arrow_right,
                                                size: 18,
                                                color: cs.onSurface.withValues(alpha: 0.4),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Archivados (${tareasArchivadas.length})',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: cs.onSurface.withValues(alpha: 0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 1,
                                            color: cs.onSurface.withValues(alpha: 0.08),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                AnimatedCrossFade(
                                  firstChild: Container(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      children: tareasArchivadas.map((entry) {
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: _buildArchivadaCard(context, entry.key, entry.value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  secondChild: const SizedBox.shrink(),
                                  crossFadeState: _archivadosExpanded
                                      ? CrossFadeState.showFirst
                                      : CrossFadeState.showSecond,
                                  duration: const Duration(milliseconds: 250),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
