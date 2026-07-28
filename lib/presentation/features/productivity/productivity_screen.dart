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

const List<Color> _metodoColores = [
  Color(0xFFEC407A), // Pink
  Color(0xFF7C4DFF), // Purple
  Color(0xFF448AFF), // Blue
  Color(0xFF00BFA5), // Teal
  Color(0xFFFFB300), // Amber
  Color(0xFF66BB6A), // Green
  Color(0xFFFF6D00), // Orange
];

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
    // Cerrar el bottom sheet primero
    Navigator.of(context).pop();

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

  /// Bottom sheet con todos los métodos de estudio
  void _mostrarMetodos() {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Asa
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.school_outlined, color: cs.primary, size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'Métodos de estudio',
                      style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Lista de métodos
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: EstudioService.metodos.length,
                  itemBuilder: (context, index) {
                    final metodo = EstudioService.metodos[index];
                    final color = _metodoColores[index % _metodoColores.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _abrirPantallaInfo(metodo),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                // Icono decorativo
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _iconosMetodo[metodo.iconoKey] ?? Icons.school,
                                    color: color,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Texto
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        metodo.nombre,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        metodo.descripcion,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botón "+" para añadir tiempo de concentración
                                IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: color.withValues(alpha: 0.15),
                                    foregroundColor: color,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add, size: 20),
                                  tooltip: 'Añadir tiempo',
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    _registrarSesion(metodo);
                                  },
                                ),
                                const SizedBox(width: 4),
                                // Flecha para ver explicación
                                Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                  color: cs.onSurface.withValues(alpha: 0.3),
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
        );
      },
    );
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
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
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '${s.duracionMinutos}m',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
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
            // === TARJETA DE RESUMEN DE MINUTOS ===
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
            // === HISTORIAL BOTÓN ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sesiones recientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _mostrarHistorial,
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // === ÚLTIMAS 5 SESIONES ===
            if (!_isLoading && _sesiones.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 48,
                        color: cs.onSurface.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sin sesiones registradas',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.4),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Toca + para elegir un método de estudio',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.25),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isLoading && _sesiones.isNotEmpty)
              ..._sesiones.reversed.take(5).map((s) {
                final metodo = PuntosEstudioService.buscarMetodo(s.metodo);
                final nombreMetodo = metodo?.nombre ?? s.metodo;
                final metodoIndex = EstudioService.metodos.indexWhere((m) => m.id == s.metodo);
                final color = metodoIndex >= 0
                    ? _metodoColores[metodoIndex % _metodoColores.length]
                    : cs.primary;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconosMetodo[metodo?.iconoKey] ?? Icons.school,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombreMetodo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${s.duracionMinutos} min • ${s.fecha}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${s.duracionMinutos}m',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 80), // Espacio para el FAB
          ],
        ),
      ),
      // === FAB: Botón flotante para abrir métodos ===
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarMetodos,
        child: const Icon(Icons.add),
      ),
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
