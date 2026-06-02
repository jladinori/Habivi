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
  final _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = TaskRepository();
    _loadTareas();
  }

  Future<void> _loadTareas() async {
    try {
      final box = await _repository.box;
      final entries = box.keys
          .map((k) => MapEntry(k, box.get(k) as Tarea))
          .toList(growable: false);
      setState(() {
        _tareas = entries;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _addTarea() async {
    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un pendiente')),
      );
      return;
    }

    try {
      final nuevaTarea = Tarea(
        DateTime.now().millisecondsSinceEpoch,
        _inputController.text.trim(),
        0,
      );
      await _repository.add(nuevaTarea);
      _inputController.clear();
      await _loadTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al añadir: $e')));
      }
    }
  }

  Future<void> _completeTarea(dynamic key) async {
    try {
      final box = await _repository.box;
      await box.delete(key);
      await _loadTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Pendiente completado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _deleteTarea(dynamic key) async {
    try {
      final box = await _repository.box;
      await box.delete(key);
      await _loadTareas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendiente eliminado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
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
                    'Pendientes',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: 'Agregar pendiente...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _addTarea(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _addTarea,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _tareas.isEmpty
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
                                onChanged: (_) {
                                  _completeTarea(key);
                                },
                              ),
                              title: Text(tarea.nombreTarea),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Eliminar'),
                                        content: Text(
                                          '¿Eliminar "${tarea.nombreTarea}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancelar'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteTarea(key);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Eliminar'),
                                          ),
                                        ],
                                      );
                                    },
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
    );
  }
}
