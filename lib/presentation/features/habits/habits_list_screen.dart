import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/habit_repository.dart';

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
        // Reiniciar hábitos si cambió el día
        _verificarResetearPorDia();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar hábitos: $e')),
      );
    }
  }

  void _verificarResetearPorDia() {
    final hoy = _obtenerFechaHoy();
    for (int i = 0; i < _habitos.length; i++) {
      final habito = _habitos[i];
      // Si el último completado fue en otro día, reiniciar el estado
      if (habito.fechaUltimoCompletado != hoy && habito.completadoHoy) {
        _resetearHabito(i);
      }
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
        _habitos.length,
        _nombreController.text.trim(),
        'general',
        'positivo',
        completadoHoy: false,
        fechaUltimoCompletado: '',
      );
      await _repository.add(nuevoHabito);
      _nombreController.clear();
      await _loadHabitos();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar hábito: $e')),
      );
    }
  }

  Future<void> _marcarCompletado(int index) async {
    try {
      final habito = _habitos[index];
      final hoy = _obtenerFechaHoy();
      habito.completadoHoy = !habito.completadoHoy;
      habito.fechaUltimoCompletado = hoy;
      // Guardar el cambio en la BD local
      await _repository.updateAt(index, habito);
      setState(() {
        _habitos[index] = habito;
      });
      if (habito.completadoHoy) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Completaste "${habito.nombreHabito}" hoy'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }

  Future<void> _resetearHabito(int index) async {
    try {
      final habito = _habitos[index];
      habito.completadoHoy = false;
      await _repository.updateAt(index, habito);
      setState(() {
        _habitos[index] = habito;
      });
    } catch (e) {
      // Silenciosamente fallar en reinicio automático
    }
  }

  Future<void> _deleteHabito(int index) async {
    try {
      // FUNCIÓN IMPORTANTE PARA BORRAR DE LA BASE DE DATOS:
      // await _repository.deleteAt(index);
      // Esta línea elimina el hábito de la base de datos Hive
      // Se debe usar cuando el usuario confirma eliminar
      
      await _repository.deleteAt(index);
      await _loadHabitos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hábito eliminado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: habito.completadoHoy,
                                onChanged: (value) {
                                  _marcarCompletado(index);
                                },
                              ),
                              title: Text(habito.nombreHabito),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
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
                                            onPressed: () =>
                                                Navigator.pop(context),
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
