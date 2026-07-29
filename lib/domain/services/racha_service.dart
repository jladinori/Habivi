import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/core/utils/app_clock.dart';

/// Servicio de negocio para gestionar la lógica de rachas
class RachaService {
  /// Actualiza la racha diaria basada en si se completó un hábito diario hoy
  /// (funciones anteriores comentadas se mantienen para referencia)

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Racha DIARIA: días consecutivos (terminando hoy) con al menos un hábito
  /// completado. SOLO cuentan hábitos definidos como diarios
  /// (vecesPorSemana == 7). Si hoy aún no hay nada, no se rompe: se cuenta desde ayer.
  static DateTime _parseDate(String s) => DateTime.parse(s);

  static String _weekKey(DateTime date) => '${date.year}-${Racha.getWeekNumber(date)}';

  static String _normalizeAspect(String aspect) {
    final normalized = aspect.toLowerCase().trim();
    return normalized
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  static String aspectoDe(Habito habit) => _normalizeAspect(habit.aspecto);

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static int calcularRachaDiaria(List<Habito> habits) {
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana == 7)
        .toList();
    if (dailyHabits.isEmpty) return 0;

    bool allCompletedOn(DateTime day) {
      final formatted = _fmt(day);
      return dailyHabits.every((h) => h.safeFechasCompletadas.contains(formatted));
    }

    final allPotentialDates = dailyHabits
        .expand((h) => h.safeFechasCompletadas)
        .toSet()
        .map(_parseDate)
        .toList();
    if (allPotentialDates.isEmpty) return 0;

    final successDates = allPotentialDates
        .where((d) => allCompletedOn(d))
        .toSet()
        .toList();
    if (successDates.isEmpty) return 0;
    successDates.sort((a, b) => b.compareTo(a));

    final hoy = _dateOnly(AppClock.now());
    final lastSuccess = _dateOnly(successDates.first);
    final daysSinceLastSuccess = hoy.difference(lastSuccess).inDays;

    if (daysSinceLastSuccess > 1) {
      return 0; // se perdió la racha ayer o antes
    }

    int streak = 0;
    DateTime cursor = lastSuccess;
    for (int i = 0; i < successDates.length; i++) {
      if (!_isSameDay(successDates[i], cursor)) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Racha SEMANAL: semanas consecutivas (terminando esta semana) en las que
  /// durante la semana el usuario completó al menos un hábito de cada
  /// sección: físico, mental y espiritual.
  static int calcularRachaSemanal(List<Habito> habits) {
    if (habits.isEmpty) return 0;

    final successfulWeekKeys = _successfulWeekKeys(habits);
    if (successfulWeekKeys.isEmpty) return 0;

    final hoy = AppClock.now();
    final currentWeekKey = _weekKey(hoy);
    final currentWeekMonday = DateTime.parse(Racha.getMondayOfWeek(hoy));
    final previousWeekDate = currentWeekMonday.subtract(const Duration(days: 7));
    final previousWeekKey = _weekKey(previousWeekDate);

    if (!successfulWeekKeys.contains(currentWeekKey) &&
        !successfulWeekKeys.contains(previousWeekKey)) {
      return 0;
    }

    DateTime referenceWeek = successfulWeekKeys.contains(currentWeekKey)
        ? currentWeekMonday
        : previousWeekDate;

    int streak = 0;
    while (true) {
      final key = _weekKey(referenceWeek);
      if (successfulWeekKeys.contains(key)) {
        streak++;
        referenceWeek = referenceWeek.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }
    return streak;
  }

  static Set<String> _successfulWeekKeys(List<Habito> habits) {
    final completedByWeek = <String, Set<String>>{};
    for (final habit in habits) {
      final aspecto = aspectoDe(habit);
      for (final fecha in habit.safeFechasCompletadas) {
        final date = _parseDate(fecha);
        final weekKey = _weekKey(date);
        completedByWeek.putIfAbsent(weekKey, () => {}).add(aspecto);
      }
    }

    final keys = <String>{};
    for (final entry in completedByWeek.entries) {
      final aspects = entry.value;
      final hasFisico = aspects.any((a) => a.contains('fis'));
      final hasMental = aspects.any((a) => a.contains('ment'));
      final hasAlma = aspects.any((a) => a.contains('espir') || a.contains('alm'));
      if (hasFisico && hasMental && hasAlma) {
        keys.add(entry.key);
      }
    }
    return keys;
  }

  /// Obtiene el color de la racha según su estado
  static String getRachaColor(String tipo, bool enRiesgo) {
    if (tipo == 'diaria') {
      return '#FF4444'; // Rojo para racha diaria
    } else {
      return enRiesgo ? '#808080' : '#6B5FFF'; // Gris en riesgo, morado cuando activa
    }
  }

  /// Obtiene el emoji de la racha
  static String getRachaEmoji() => '🔥';

  /// Obtiene el mensaje para la racha
  static String getRachaMessage({
    required int cantidad,
    required String tipo,
    required bool enRiesgo,
  }) {
    if (enRiesgo) {
      return '${getRachaEmoji()} Llevabas $cantidad ${tipo == 'diaria' ? 'días' : 'semanas'} cumpliendo.';
    }
    return '${getRachaEmoji()} Llevas $cantidad ${tipo == 'diaria' ? 'días' : 'semanas'} cumpliendo.';
  }
    /// ¿Se completó algún hábito HOY? (para encender la racha diaria)
    /// SOLO cuentan hábitos EXCLUSIVAMENTE diarios (vecesPorSemana == 7)
  static bool completadoHoy(List<Habito> habits) {
    final dailyHabits = habits
    .where((h) => h.safeVecesPorSemana == 7)
        .toList();
    if (dailyHabits.isEmpty) return false;
 
    final hoy = _fmt(AppClock.now());
    return dailyHabits.every((h) => h.safeFechasCompletadas.contains(hoy));
  }
 
  static bool rachaDiariaSigueActiva(List<Habito> habits) {
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana == 7)
        .toList();
    if (dailyHabits.isEmpty) return false;
 
    bool allCompletedOn(DateTime day) {
      final formatted = _fmt(day);
      return dailyHabits.every((h) => h.safeFechasCompletadas.contains(formatted));
    }
 
    final successDates = dailyHabits
        .expand((h) => h.safeFechasCompletadas)
        .toSet()
        .map(_parseDate)
        .where(allCompletedOn)
        .toList();
    if (successDates.isEmpty) return false;
    successDates.sort((a, b) => b.compareTo(a));
 
    final hoy = _dateOnly(AppClock.now());
    final lastSuccess = _dateOnly(successDates.first);
    final daysSinceLast = hoy.difference(lastSuccess).inDays;
 
    return daysSinceLast <= 1;
  }

  /// ¿Se cumplió la condición semanal para considerar la semana como exitosa?
  /// Es verdadera si la semana actual o la anterior contiene al menos un hábito
  /// de cada sección (físico, mental y alma).
  static bool completadoEstaSemana(List<Habito> habits) {
    if (habits.isEmpty) return false;
    final ref = AppClock.now();

    final currentWeekKey = _weekKey(ref);
    final previousWeekDate = DateTime.parse(Racha.getMondayOfWeek(ref))
        .subtract(const Duration(days: 7));
    final previousWeekKey = _weekKey(previousWeekDate);

    final successfulWeeks = _successfulWeekKeys(habits);
    return successfulWeeks.contains(currentWeekKey) ||
        successfulWeeks.contains(previousWeekKey);
  }
  /// Obtiene el mensaje de recuperación para la racha semanal
  static String getRecuperationMessage() => 'Recupérala esta semana.';
}
