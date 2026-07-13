import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

class MetodoEstudioInfo {
  final String id;
  final String nombre;
  final String descripcion;
  final int puntosBasePorHora;
  final String iconoKey;

  const MetodoEstudioInfo({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.puntosBasePorHora,
    required this.iconoKey,
  });
}

class PuntosEstudioService {
  static const List<MetodoEstudioInfo> metodos = [
    MetodoEstudioInfo(
      id: 'pomodoro',
      nombre: 'Pomodoro',
      descripcion: '25 min de trabajo, 5 min de descanso',
      puntosBasePorHora: 100,
      iconoKey: 'timer',
    ),
    MetodoEstudioInfo(
      id: 'feynman',
      nombre: 'Técnica Feynman',
      descripcion: 'Explicar conceptos en términos simples como si enseñaras',
      puntosBasePorHora: 150,
      iconoKey: 'book',
    ),
    MetodoEstudioInfo(
      id: 'active_recall',
      nombre: 'Active Recall',
      descripcion: 'Recordar activamente la información sin mirar apuntes',
      puntosBasePorHora: 180,
      iconoKey: 'brain',
    ),
    MetodoEstudioInfo(
      id: 'spaced_repetition',
      nombre: 'Repetición Espaciada',
      descripcion: 'Repasar en intervalos crecientes para fijar conocimiento',
      puntosBasePorHora: 130,
      iconoKey: 'loop',
    ),
    MetodoEstudioInfo(
      id: 'cornell',
      nombre: 'Método Cornell',
      descripcion: 'Sistema de apuntes estructurado en notas, claves y resumen',
      puntosBasePorHora: 110,
      iconoKey: 'article',
    ),
    MetodoEstudioInfo(
      id: 'time_blocking',
      nombre: 'Time Blocking',
      descripcion: 'Bloquear tiempo específico para cada tarea del día',
      puntosBasePorHora: 90,
      iconoKey: 'schedule',
    ),
    MetodoEstudioInfo(
      id: 'tecnica_50_10',
      nombre: 'Técnica 50/10',
      descripcion: '50 minutos de estudio intenso por 10 de descanso',
      puntosBasePorHora: 120,
      iconoKey: 'hourglass',
    ),
    MetodoEstudioInfo(
      id: 'mapas_mentales',
      nombre: 'Mapas Mentales',
      descripcion: 'Organizar ideas visualmente con conexiones y colores',
      puntosBasePorHora: 140,
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

  static int calcularPuntos(String metodoId, int duracionMinutos) {
    final metodo = buscarMetodo(metodoId);
    if (metodo == null) return 0;
    final horas = duracionMinutos / 60.0;
    return (metodo.puntosBasePorHora * horas).round();
  }

  static Future<int> puntosDeHoy() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    final hoy = _fechaHoy();
    int total = 0;
    for (final s in box.values) {
      if (s.fecha == hoy) total += s.puntosObtenidos;
    }
    return total;
  }

  static Future<int> puntosDeEstaSemana() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    final inicioSemana = _inicioSemana();
    int total = 0;
    for (final s in box.values) {
      if (s.fecha.compareTo(inicioSemana) >= 0) total += s.puntosObtenidos;
    }
    return total;
  }

  static Future<int> puntosTotales() async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    int total = 0;
    for (final s in box.values) {
      total += s.puntosObtenidos;
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
