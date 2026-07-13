import 'package:flutter/material.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/repositories/task_repository.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late TaskRepository _repository;
  List<MapEntry<dynamic, Tarea>> _tareas = [];
  bool _isLoading = true;

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
        setState(() {
          _isLoading = false;
        });
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
      final metadata = Tarea.crearMetadata(fecha, notas);
      final nuevaTarea = Tarea(
        DateTime.now().millisecondsSinceEpoch,
        nombre,
        0,
        metadata: metadata,
      );
      await _repository.add(nuevaTarea);
      
      // Recarga la lista sin mostrar pantalla blanca
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
      await box.delete(key);
      await box.flush();
      await _cargarTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Completado')),
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

  Future<void> _eliminarPendiente(dynamic key, String nombre) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendientes',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tareas.isEmpty
                      ? Center(
                          child: Text(
                            'Sin pendientes',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _tareas.length,
                          itemBuilder: (context, index) {
                            final entry = _tareas[index];
                            final key = entry.key;
                            final tarea = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: false,
                                    onChanged: (_) => _completarPendiente(key),
                                  ),
                                  title: Text(tarea.nombreTarea),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (tarea.fecha.isNotEmpty)
                                        Text(
                                          '📅 ${tarea.fecha}',
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                      if (tarea.notas.isNotEmpty)
                                        Text(
                                          tarea.notas,
                                          style: const TextStyle(fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Eliminar'),
                                          content: Text(
                                            '¿Eliminar "${tarea.nombreTarea}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                _eliminarPendiente(key, tarea.nombreTarea);
                                              },
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
        onPressed: _mostrarDialogoAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
