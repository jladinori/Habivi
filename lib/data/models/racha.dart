import 'package:hive/hive.dart';

part 'racha.g.dart';

@HiveType(typeId: 10)
class Racha {
  @HiveField(0)
  int idRacha;

  @HiveField(1)
  String tipo; // 'diaria' o 'semanal'

  @HiveField(2)
  int cantidad; // Número de días/semanas consecutivos

  @HiveField(3)
  String fechaUltimoCompletado; // Último día que se cumplió

  @HiveField(4)
  bool enRiesgo; // Solo para semanal: si no se completó esta semana

  @HiveField(5)
  String fechaInicioPeriodoRecuperacion; // Fecha cuando empezó el período de recuperación (solo semanal)

  @HiveField(6)
  String? fechaCreacion;

  Racha({
    required this.idRacha,
    required this.tipo,
    required this.cantidad,
    required this.fechaUltimoCompletado,
    this.enRiesgo = false,
    this.fechaInicioPeriodoRecuperacion = '',
    this.fechaCreacion,
  });

  /// Copia profunda del objeto
  Racha copyWith({
    int? idRacha,
    String? tipo,
    int? cantidad,
    String? fechaUltimoCompletado,
    bool? enRiesgo,
    String? fechaInicioPeriodoRecuperacion,
    String? fechaCreacion,
  }) {
    return Racha(
      idRacha: idRacha ?? this.idRacha,
      tipo: tipo ?? this.tipo,
      cantidad: cantidad ?? this.cantidad,
      fechaUltimoCompletado: fechaUltimoCompletado ?? this.fechaUltimoCompletado,
      enRiesgo: enRiesgo ?? this.enRiesgo,
      fechaInicioPeriodoRecuperacion:
          fechaInicioPeriodoRecuperacion ?? this.fechaInicioPeriodoRecuperacion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtiene la fecha formateada actual
  static String getTodayFormatted() => _formatDate(DateTime.now());

  /// Compara dos fechas (solo año-mes-día)
  static bool isSameDay(String fecha1, String fecha2) => fecha1 == fecha2;

  /// Compara si es el día siguiente
  static bool isNextDay(String previousDay, String nextDay) {
    try {
      final prev = DateTime.parse(previousDay);
      final next = DateTime.parse(nextDay);
      return next.difference(prev).inDays == 1;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el número de la semana ISO para una fecha
  static int getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final difference = date.difference(firstDayOfYear).inDays;
    return ((difference + firstDayOfYear.weekday) / 7).ceil();
  }

  /// Verifica si dos fechas están en la misma semana
  static bool isSameWeek(String fecha1, String fecha2) {
    try {
      final date1 = DateTime.parse(fecha1);
      final date2 = DateTime.parse(fecha2);
      return getWeekNumber(date1) == getWeekNumber(date2) && date1.year == date2.year;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene el lunes de la semana actual
  static String getMondayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday; // 1 = lunes, 7 = domingo
    final monday = date.subtract(Duration(days: dayOfWeek - 1));
    return _formatDate(monday);
  }

  /// Obtiene el domingo de la semana actual
  static String getSundayOfWeek(DateTime date) {
    final dayOfWeek = date.weekday; // 1 = lunes, 7 = domingo
    final sunday = date.add(Duration(days: 7 - dayOfWeek));
    return _formatDate(sunday);
  }

  /// Calcula los días entre dos fechas
  static int daysBetween(String fecha1, String fecha2) {
    try {
      final date1 = DateTime.parse(fecha1);
      final date2 = DateTime.parse(fecha2);
      return date2.difference(date1).inDays;
    } catch (e) {
      return 0;
    }
  }
}
