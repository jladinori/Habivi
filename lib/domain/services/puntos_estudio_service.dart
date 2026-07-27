import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

class MetodoEstudioInfo {
  final String id;
  final String nombre;
  final String descripcion;
  final String iconoKey;

  const MetodoEstudioInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.iconoKey,
  });
}

class EstudioService {
  static const List<MetodoEstudioInfo> metodos = [
    MetodoEstudioInfo(
      id: 'pomodoro',
      nombre: 'Pomodoro',
      descripcion: '25 min de trabajo, 5 min de descanso',
      iconoKey: 'timer',
    ),
    MetodoEstudioInfo(
      id: 'feynman',
      nombre: 'Técnica Feynman',
      descripcion: 'Explicar conceptos en términos simples como si enseñaras',
      iconoKey: 'book',
    ),
    MetodoEstudioInfo(
      id: 'active_recall',
      nombre: 'Active Recall',
      descripcion: 'Recordar activamente la información sin mirar apuntes',
      iconoKey: 'brain',
    ),
    MetodoEstudioInfo(
      id: 'spaced_repetition',
      nombre: 'Repetición Espaciada',
      descripcion: 'Repasar en intervalos crecientes para fijar conocimiento',
      iconoKey: 'loop',
    ),
    MetodoEstudioInfo(
      id: 'cornell',
      nombre: 'Método Cornell',
      descripcion: 'Sistema de apuntes estructurado en notas, claves y resumen',
      iconoKey: 'article',
    ),
    MetodoEstudioInfo(
      id: 'time_blocking',
      nombre: 'Time Blocking',
      descripcion: 'Bloquear tiempo específico para cada tarea del día',
      iconoKey: 'schedule',
    ),
    MetodoEstudioInfo(
      id: 'mapas_mentales',
      nombre: 'Mapas Mentales',
      descripcion: 'Organizar ideas visualmente con conexiones y colores',
      iconoKey: 'tree',
    ),
  ];

  static MetodoEstudioInfo? buscarMetodo(String id) {
    try {
      return metodos.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Retorna los minutos tal cual (sin conversión de puntos)
  static int calcularMinutos(String metodoId, int duracionMinutos) {
    return duracionMinutos;
  }

  static Future<int> minutosDeHoy() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    final hoy = _fechaHoy();
    int total = 0;
    for (final s in box.values) {
      if (s.fecha == hoy) total += s.duracionMinutos;
    }
    return total;
  }

  static Future<int> minutosDeEstaSemana() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    final inicioSemana = _inicioSemana();
    int total = 0;
    for (final s in box.values) {
      if (s.fecha.compareTo(inicioSemana) >= 0) total += s.duracionMinutos;
    }
    return total;
  }

  static Future<int> minutosTotales() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    int total = 0;
    for (final s in box.values) {
      total += s.duracionMinutos;
    }
    return total;
  }

  static String _fechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static String _inicioSemana() {
    final now = DateTime.now();
    final inicio = now.subtract(Duration(days: now.weekday - 1));
    return '${inicio.year}-${inicio.month.toString().padLeft(2, '0')}-${inicio.day.toString().padLeft(2, '0')}';
  }
}

// Alias para compatibilidad hacia atrás
typedef PuntosEstudioService = EstudioService;
