import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/data/repositories/user_repository.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/domain/services/puntos_estudio_service.dart';
import 'package:habivi/core/utils/app_clock.dart';
import 'package:habivi/presentation/providers/dev_mode_provider.dart';
import 'package:habivi/presentation/shared/widgets/premium_fab.dart';

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
  Color(0xFF7C4DFF), // Purple
  Color(0xFF00BFA5), // Teal
  Color(0xFFFF6D00), // Orange
  Color(0xFFEC407A), // Pink
  Color(0xFF448AFF), // Blue
  Color(0xFFFFB300), // Amber
  Color(0xFF66BB6A), // Green
];

class _MetodoStats {
  final String id;
  final String nombre;
  final int minutosTotales;
  final Color color;
  final double porcentaje;

  _MetodoStats({
    required this.id,
    required this.nombre,
    required this.minutosTotales,
    required this.color,
    required this.porcentaje,
  });
}

class _DayData {
  final DateTime date;
  final String dayName;
  final int minutes;
  final bool isToday;

  _DayData({
    required this.date,
    required this.dayName,
    required this.minutes,
    required this.isToday,
  });
}

class ProductivityScreen extends ConsumerStatefulWidget {
  const ProductivityScreen({super.key});

  @override
  ConsumerState<ProductivityScreen> createState() => _ProductivityScreenState();
}

class _ProductivityScreenState extends ConsumerState<ProductivityScreen> {
  late EstudioRepository _repository;
  List<SesionEstudio> _sesiones = [];
  int _puntosSemana = 0;
  int _metaSemanal = 300; // default: 300 minutos semanales (5 horas)
  int _metaDiaria = 30; // default: 30 minutos/día
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
      final minutosSemana = await EstudioService.minutosDeEstaSemana();
      final minutosTotales = await EstudioService.minutosTotales();

      // Cargar metas desde Hive
      final settingsBox = await Hive.openBox('settingsBox');
      final metaGuardada = settingsBox.get('metaSemanalMinutos', defaultValue: 300) as int;
      final metaDiariaGuardada = settingsBox.get('metaDiariaMinutos', defaultValue: 30) as int;

      if (mounted) {
        setState(() {
          _sesiones = sesionesMap.values.toList();
          _puntosSemana = minutosSemana;
          _metaSemanal = metaGuardada;
          _metaDiaria = metaDiariaGuardada;
          _isLoading = false;
        });
      }
      await _syncMinutosProductividad(minutosTotales);
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarMetaSemanal(int nuevaMeta) async {
    try {
      final settingsBox = await Hive.openBox('settingsBox');
      await settingsBox.put('metaSemanalMinutos', nuevaMeta);
      if (mounted) {
        setState(() {
          _metaSemanal = nuevaMeta;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Meta semanal actualizada a $nuevaMeta min')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar meta: $e')),
        );
      }
    }
  }

  Future<void> _guardarMetaDiaria(int nuevaMeta) async {
    try {
      final settingsBox = await Hive.openBox('settingsBox');
      await settingsBox.put('metaDiariaMinutos', nuevaMeta);
      if (mounted) {
        setState(() {
          _metaDiaria = nuevaMeta;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Meta diaria actualizada a $nuevaMeta min/día')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar meta diaria: $e')),
        );
      }
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
    final now = AppClock.now();
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
        duracion,
        fechaStr,
        nota: nota,
      );
      await _repository.add(sesion);
      await _cargarDatos();
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

  void _dialogoEditarMetaSemanal() {
    final controller = TextEditingController(text: '$_metaSemanal');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta semanal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa la meta de minutos de estudio para esta semana:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutos semanales',
                suffixText: 'min',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                _guardarMetaSemanal(val);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un número mayor a 0')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _dialogoEditarMetaDiaria() {
    final controller = TextEditingController(text: '$_metaDiaria');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta diaria de estudio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Define cuántos minutos de estudio esperas cumplir cada día:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Objetivo diario',
                suffixText: 'min/día',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text.trim());
              if (val != null && val > 0) {
                Navigator.pop(ctx);
                _guardarMetaDiaria(val);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingresa un número mayor a 0')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

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

  List<_MetodoStats> _obtenerEstadisticasMetodos() {
    final Map<String, int> mapaMinutos = {};
    int sumaTotal = 0;

    for (final s in _sesiones) {
      mapaMinutos[s.metodo] = (mapaMinutos[s.metodo] ?? 0) + s.duracionMinutos;
      sumaTotal += s.duracionMinutos;
    }

    final List<_MetodoStats> lista = [];
    int index = 0;
    mapaMinutos.forEach((idMetodo, minutos) {
      final info = PuntosEstudioService.buscarMetodo(idMetodo);
      final nombre = info?.nombre ?? idMetodo;
      final color = _metodoColores[index % _metodoColores.length];
      index++;

      final porcentaje = sumaTotal > 0 ? (minutos / sumaTotal) : 0.0;
      lista.add(_MetodoStats(
        id: idMetodo,
        nombre: nombre,
        minutosTotales: minutos,
        color: color,
        porcentaje: porcentaje,
      ));
    });

    lista.sort((a, b) => b.minutosTotales.compareTo(a.minutosTotales));
    return lista;
  }

  List<_DayData> _obtenerUltimos7Dias() {
    final now = AppClock.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    return List.generate(7, (index) {
      final d = todayOnly.subtract(Duration(days: 6 - index));
      final fechaStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      int minSuma = 0;
      for (final s in _sesiones) {
        if (s.fecha == fechaStr) {
          minSuma += s.duracionMinutos;
        }
      }

      final isToday = d.year == todayOnly.year && d.month == todayOnly.month && d.day == todayOnly.day;
      final dayName = dayNames[d.weekday - 1];

      return _DayData(
        date: d,
        dayName: dayName,
        minutes: minSuma,
        isToday: isToday,
      );
    });
  }

  /// 1. Cuadro Meta Semanal
  Widget _buildMetaSemanalCard(BuildContext context, ColorScheme cs) {
    final progreso = _metaSemanal > 0 ? (_puntosSemana / _metaSemanal).clamp(0.0, 1.0) : 0.0;
    final porcentajeTexto = (progreso * 100).toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: cs.primary, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Meta semanal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Cambiar meta semanal',
                  onPressed: _dialogoEditarMetaSemanal,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                    children: [
                      TextSpan(text: '$_puntosSemana'),
                      TextSpan(
                        text: ' / $_metaSemanal min',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$porcentajeTexto%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progreso,
                minHeight: 10,
                backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Cuadro Evolución Semanal (Gráfico de línea Bezier con emoticones y estrella para HOY)
  Widget _buildEvolucionSemanalCard(BuildContext context, ColorScheme cs) {
    final ultimos7Dias = _obtenerUltimos7Dias();

    final diasConEstudio = ultimos7Dias.where((d) => d.minutes > 0).length;
    final cumpleMeta = ultimos7Dias.where((d) => d.minutes >= _metaDiaria).length;

    String mensaje;
    if (cumpleMeta >= 4) {
      mensaje = "¡Excelente constancia! Estás cumpliendo tus objetivos diarios.";
    } else if (diasConEstudio >= 3) {
      mensaje = "Tu constancia está mejorando. ¡Cada sesión cuenta!";
    } else {
      mensaje = "¡Construye el hábito! Un poco de estudio cada día marca la diferencia.";
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart_rounded, color: cs.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Evolución semanal',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _dialogoEditarMetaDiaria,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          '$_metaDiaria min/día',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.edit, size: 12, color: cs.primary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 175.0;
                const marginTop = 48.0;
                const marginBottom = 28.0;
                const marginH = 20.0;

                final availableW = width - (marginH * 2);
                final stepX = availableW / 6;

                final maxMinutos = ultimos7Dias.fold<int>(
                    0, (prev, d) => d.minutes > prev ? d.minutes : prev);
                final maxScale = math.max(maxMinutos, _metaDiaria * 1.25);
                final availableH = height - marginTop - marginBottom;

                final points = List.generate(7, (i) {
                  final px = marginH + i * stepX;
                  final ratio = maxScale > 0 ? (ultimos7Dias[i].minutes / maxScale) : 0.0;
                  final py = (height - marginBottom) - (ratio * availableH);
                  return Offset(px, py);
                });

                return SizedBox(
                  width: width,
                  height: height,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        size: Size(width, height),
                        painter: _WeeklyBezierChartPainter(
                          points: points,
                          primaryColor: cs.primary,
                          height: height,
                          marginBottom: marginBottom,
                        ),
                      ),

                      // Badges
                      ...ultimos7Dias.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final p = points[i];

                        return Positioned(
                          left: p.dx - 17,
                          top: p.dy - 36,
                          child: _buildDayBadge(d, cs),
                        );
                      }),

                      // Días de la semana
                      ...ultimos7Dias.asMap().entries.map((entry) {
                        final i = entry.key;
                        final d = entry.value;
                        final p = points[i];

                        return Positioned(
                          left: p.dx - 18,
                          bottom: 0,
                          child: SizedBox(
                            width: 36,
                            child: Text(
                              d.dayName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: d.isToday ? FontWeight.bold : FontWeight.w500,
                                color: d.isToday
                                    ? cs.primary
                                    : cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Banner Mensaje Motivacional
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.star_rounded, color: cs.primary, size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mensaje,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayBadge(_DayData day, ColorScheme cs) {
    if (day.isToday) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: cs.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.45),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.star_rounded,
          color: Colors.white,
          size: 20,
        ),
      );
    }

    final ratio = _metaDiaria > 0 ? (day.minutes / _metaDiaria) : 0.0;
    String emoji;
    Color badgeColor;

    if (day.minutes == 0) {
      emoji = '😴';
      badgeColor = Colors.orange.withValues(alpha: 0.2);
    } else if (ratio < 0.7) {
      emoji = '😐';
      badgeColor = Colors.amber.withValues(alpha: 0.25);
    } else {
      emoji = '😄';
      badgeColor = Colors.green.withValues(alpha: 0.25);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// 3. Cuadro Distribución del Tiempo (Gráfico Circular Donut)
  Widget _buildDistribucionCard(
      BuildContext context, ColorScheme cs, List<_MetodoStats> stats) {
    final totalMin = stats.fold<int>(0, (sum, item) => sum + item.minutosTotales);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart_outline, color: cs.secondary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Distribución del tiempo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Aún no hay tiempo registrado',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              )
            else
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: _DonutChartPainter(
                            percentages: stats.map((s) => s.porcentaje).toList(),
                            colors: stats.map((s) => s.color).toList(),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$totalMin',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'min',
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: stats.take(4).map((s) {
                        final pctStr = (s.porcentaje * 100).toStringAsFixed(0);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: s.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.nombre,
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '$pctStr%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// 4. Cuadro 3 Métodos Más Usados (Solo el nombre)
  Widget _buildTop3MetodosCard(
      BuildContext context, ColorScheme cs, List<_MetodoStats> stats) {
    final top3 = stats.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_outlined, color: Colors.amber[700], size: 22),
                const SizedBox(width: 8),
                Text(
                  '3 Métodos más usados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (top3.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Registra sesiones para ver tus métodos principales',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                ),
              )
            else
              Column(
                children: top3.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: item.color.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: item.color,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.nombre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Duration>(timeOffsetProvider, (previous, next) {
      _cargarDatos();
    });

    final cs = Theme.of(context).colorScheme;
    final stats = _obtenerEstadisticasMetodos();

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
            const SizedBox(height: 20),

            if (!_isLoading) ...[
              // 1. Meta Semanal
              _buildMetaSemanalCard(context, cs),
              const SizedBox(height: 16),

              // 2. Evolución Semanal (Curva Bezier + Emojis + Estrella hoy)
              _buildEvolucionSemanalCard(context, cs),
              const SizedBox(height: 16),

              // 3. Gráfico Circular Distribución del Tiempo
              _buildDistribucionCard(context, cs, stats),
              const SizedBox(height: 16),

              // 4. Top 3 Métodos Más Usados
              _buildTop3MetodosCard(context, cs, stats),
              const SizedBox(height: 24),
            ],

            // === SECCIÓN SESIONES RECIENTES ===
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

            if (!_isLoading && _sesiones.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 44,
                        color: cs.onSurface.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 10),
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
              ..._sesiones.reversed.take(4).map((s) {
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
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: PremiumFAB(
        onPressed: _mostrarMetodos,
      ),
    );
  }
}

/// Painter para gráfico de Donut circular
class _DonutChartPainter extends CustomPainter {
  final List<double> percentages;
  final List<Color> colors;

  _DonutChartPainter({required this.percentages, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (percentages.isEmpty || percentages.every((p) => p == 0)) {
      paint.color = Colors.grey.withValues(alpha: 0.2);
      canvas.drawCircle(center, radius - strokeWidth / 2, paint);
      return;
    }

    double startAngle = -math.pi / 2;
    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = 2 * math.pi * percentages[i];
      if (sweepAngle <= 0) continue;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.06,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

/// Painter para Curva de Bézier de Evolución Semanal
class _WeeklyBezierChartPainter extends CustomPainter {
  final List<Offset> points;
  final Color primaryColor;
  final double height;
  final double marginBottom;

  _WeeklyBezierChartPainter({
    required this.points,
    required this.primaryColor,
    required this.height,
    required this.marginBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, height - marginBottom),
      Offset(size.width, height - marginBottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, (height - marginBottom) / 2),
      Offset(size.width, (height - marginBottom) / 2),
      gridPaint,
    );

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, height - marginBottom);
    fillPath.lineTo(points.first.dx, height - marginBottom);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withValues(alpha: 0.4),
          primaryColor.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (final p in points) {
      canvas.drawCircle(
        p,
        6.0,
        Paint()..color = primaryColor.withValues(alpha: 0.4),
      );
      canvas.drawCircle(
        p,
        3.5,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBezierChartPainter oldDelegate) => true;
}
