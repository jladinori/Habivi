import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/data/repositories/user_repository.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/domain/services/puntos_estudio_service.dart';

const Map<String, IconData> _iconosMetodo = {
  'timer': Icons.timer_outlined,
  'book': Icons.menu_book_outlined,
  'brain': Icons.psychology_outlined,
  'loop': Icons.loop_outlined,
  'article': Icons.article_outlined,
  'schedule': Icons.schedule_outlined,
  'hourglass': Icons.hourglass_top_outlined,
  'tree': Icons.account_tree_outlined,
};

class ProductivityScreen extends ConsumerStatefulWidget {
  const ProductivityScreen({super.key});

  @override
  ConsumerState<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends ConsumerState<ProductivityScreen> {
  late EstudioRepository _repository;
  List<SesionEstudio> _sesiones = [];
  int _puntosHoy = 0;
  int _puntosSemana = 0;
  int _puntosTotales = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = EstudioRepository();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final sesionesMap = await _repository.readAll();
      final minutosHoy = await EstudioService.minutosDeHoy();
      final minutosSemana = await EstudioService.minutosDeEstaSemana();
      final minutosTotales = await EstudioService.minutosTotales();
      if (mounted) {
        setState(() {
          _sesiones = sesionesMap.values.toList();
          _puntosHoy = minutosHoy;
          _puntosSemana = minutosSemana;
          _puntosTotales = minutosTotales;
          _isLoading = false;
        });
      }
      await _syncMinutosProductividad(minutosTotales);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _syncMinutosProductividad(int minutosTotales) async {
    final userRepo = UserRepository();
    final usuarios = await userRepo.readAll();
    if (usuarios.isEmpty) return;
    final firstKey = usuarios.keys.first;
    final usuario = usuarios.values.first;
    usuario.puntosProductividad = minutosTotales;
    await userRepo.updateAt(firstKey, usuario);
  }

  Future<void> _registrarSesion(MetodoEstudioInfo metodo) async {
    final duracionController = TextEditingController();
    final notaController = TextEditingController();
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text('Registrar: ${metodo.nombre}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: duracionController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duración (minutos)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notaController,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final duracion = int.tryParse(duracionController.text.trim());
                if (duracion == null || duracion <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa una duración válida')),
                  );
                  return;
                }
                Navigator.pop(ctx, {
                  'duracion': duracion,
                  'nota': notaController.text.trim(),
                });
              },
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );

    duracionController.dispose();
    notaController.dispose();

    if (resultado == null) return;

    final duracion = resultado['duracion'] as int;
    final nota = resultado['nota'] as String;
    final now = DateTime.now();
    final fechaStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      final totalSesiones = _sesiones.length;
      final nextId = totalSesiones == 0
          ? 1
          : _sesiones.map((s) => s.idSesion).reduce((a, b) => a > b ? a : b) + 1;

      final sesion = SesionEstudio(
        nextId,
        metodo.id,
        duracion,
        duracion, // Los "puntos" ahora son los minutos
        fechaStr,
        nota: nota,
      );
      await _repository.add(sesion);
      await _cargarDatos();
      await _syncMinutosProductividad(_puntosTotales);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ +$duracion minutos en "${metodo.nombre}"'),
            duration: const Duration(seconds: 2),
          ),
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

  void _abrirPantallaInfo(MetodoEstudioInfo metodo) {
    switch (metodo.id) {
      case 'pomodoro':
        context.push('/productivity/pomodoro-info');
        break;
      case 'feynman':
        context.push('/productivity/feynman-info');
        break;
      case 'active_recall':
        context.push('/productivity/active-recall-info');
        break;
      case 'spaced_repetition':
        context.push('/productivity/spaced-repetition-info');
        break;
      case 'cornell':
        context.push('/productivity/cornell-info');
        break;
      case 'time_blocking':
        context.push('/productivity/time-blocking-info');
        break;
      case '50_10':
        context.push('/productivity/fifty-ten-info');
        break;
      case 'mind_maps':
        context.push('/productivity/mind-maps-info');
        break;
      default:
        _registrarSesion(metodo);
    }
  }

  void _mostrarHistorial() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Historial de sesiones',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _sesiones.isEmpty
                    ? Center(
                        child: Text(
                          'Aún no hay sesiones registradas',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _sesiones.length,
                        itemBuilder: (context, index) {
                          final s = _sesiones[index];
                          final metodo = PuntosEstudioService.buscarMetodo(s.metodo);
                          final nombreMetodo = metodo?.nombre ?? s.metodo;
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                                child: Text(
                                  '${s.puntosObtenidos}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Text(nombreMetodo),
                              subtitle: Text(
                                '${s.duracionMinutos} min • ${s.fecha}${s.nota.isNotEmpty ? ' • ${s.nota}' : ''}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20),
                                onPressed: () async {
                                  try {
                                    await _repository.deleteAt(index);
                                    await _cargarDatos();
                                  } catch (_) {}
                                },
                              ),
                            ),
                          );
                        },
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
        if (!_isLoading)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _minutosColumna('Hoy', _puntosHoy),
                  _minutosColumna('Semana', _puntosSemana),
                  _minutosColumna('Total', _puntosTotales),
                ],
              ),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Métodos de estudio',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: _mostrarHistorial,
              icon: const Icon(Icons.history, size: 18),
              label: const Text('Historial'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...PuntosEstudioService.metodos.map(
          (metodo) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    _iconosMetodo[metodo.iconoKey] ?? Icons.school,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  metodo.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(metodo.descripcion),
                trailing: FilledButton.tonal(
                  onPressed: () => _abrirPantallaInfo(metodo),
                  child: const Text('+'),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _minutosColumna(String label, int minutos) {
    return Column(
      children: [
        Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          '$minutos',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          '$label min',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
