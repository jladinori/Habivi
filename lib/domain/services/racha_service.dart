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
  /// (vecesPorSemana >= 7). Si hoy aún no hay nada, no se rompe: se cuenta desde ayer.
  static int calcularRachaDiaria(List<Habito> habits) {
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana >= 7 && h.safeVecesPorSemana > 0)
        .toList();
    if (dailyHabits.isEmpty) return 0;

    bool completadoEn(DateTime dia) {
      final s = _fmt(dia);
      return dailyHabits.any((h) => h.safeFechasCompletadas.contains(s));
    }

    final hoy = AppClock.now();
    int inicio = completadoEn(hoy) ? 0 : 1; // gracia para el día en curso
    int streak = 0;
    for (int d = inicio; d < 730; d++) {
      if (completadoEn(hoy.subtract(Duration(days: d)))) {
        streak++;
      } else {
        break; // un día sin nada → se corta la racha
      }
    }
    return streak;
  }

  /// Racha SEMANAL: semanas consecutivas (terminando esta semana) con al menos
  /// un hábito SEMANAL (vecesPorSemana < 7) completado dentro de la semana.
  static int calcularRachaSemanal(List<Habito> habits) {
    final semanales = habits
        .where((h) => h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0)
        .toList();
    if (semanales.isEmpty) return 0;

    bool completadoEnSemanaDe(DateTime ref) {
      final lunes = Racha.getMondayOfWeek(ref);
      final domingo = Racha.getSundayOfWeek(ref);
      return semanales.any((h) => h.safeFechasCompletadas
          .any((f) => f.compareTo(lunes) >= 0 && f.compareTo(domingo) <= 0));
    }

    final hoy = AppClock.now();
    int inicio =
        completadoEnSemanaDe(hoy) ? 0 : 1; // gracia para la semana actual
    int streak = 0;
    for (int w = inicio; w < 520; w++) {
      if (completadoEnSemanaDe(hoy.subtract(Duration(days: 7 * w)))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
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
  /// SOLO cuentan hábitos EXCLUSIVAMENTE diarios (vecesPorSemana >= 7)
  static bool completadoHoy(List<Habito> habits) {
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana >= 7 && h.safeVecesPorSemana > 0)
        .toList();
    if (dailyHabits.isEmpty) return false;
    final hoy = _fmt(AppClock.now());
    return dailyHabits.any((h) => h.safeFechasCompletadas.contains(hoy));
  }

  /// ¿Se completó algún hábito SEMANAL esta semana? (para la racha semanal)
  static bool completadoEstaSemana(List<Habito> habits) {
    final semanales = habits
        .where((h) => h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0)
        .toList();
    if (semanales.isEmpty) return false;
    final ref = AppClock.now();
    final lunes = Racha.getMondayOfWeek(ref);
    final domingo = Racha.getSundayOfWeek(ref);
    return semanales.any((h) => h.safeFechasCompletadas
        .any((f) => f.compareTo(lunes) >= 0 && f.compareTo(domingo) <= 0));
  }
  /// Obtiene el mensaje de recuperación para la racha semanal
  static String getRecuperationMessage() => 'Recupérala esta semana.';
}
