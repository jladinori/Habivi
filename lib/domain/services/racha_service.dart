import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/core/utils/app_clock.dart';

/// Servicio de negocio para gestionar la lógica de rachas
class RachaService {
  /// Actualiza la racha diaria basada en si se completó un hábito diario hoy
  static Racha updateDailyRacha({
    required Racha currentRacha,
    required bool completedDailyHabitToday,
  }) {
    final today = Racha.getTodayFormatted();
    final lastCompleted = currentRacha.fechaUltimoCompletado;

    if (completedDailyHabitToday) {
      // Completó un hábito hoy
      if (lastCompleted.isEmpty) {
        // Primera racha
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      } else if (Racha.isSameDay(lastCompleted, today)) {
        // Ya completó hoy, NO incrementar nuevamente
        // Solo mantener y actualizar fecha
        return currentRacha;
      } else if (Racha.isNextDay(lastCompleted, today)) {
        // Continúa la racha de ayer
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        // Se rompió la racha (pasaron días)
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      }
    } else {
      // No completó ningún hábito hoy
      if (Racha.isSameDay(lastCompleted, today)) {
        // Hoy ya se había registrado pero no hay hábitos
        return currentRacha;
      }
      
      // Si ayer fue el último día, se pierde la racha
      if (Racha.isNextDay(lastCompleted, today)) {
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      } else if (lastCompleted.isNotEmpty && !Racha.isSameDay(lastCompleted, today)) {
        // Pasó más de un día sin completar
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      }
    }

    return currentRacha;
  }

  /// Actualiza la racha semanal basada en si se completó un hábito semanal esta semana
  static Racha updateWeeklyRacha({
    required Racha currentRacha,
    required bool completedWeeklyHabitThisWeek,
  }) {
    final today = Racha.getTodayFormatted();
    final lastCompleted = currentRacha.fechaUltimoCompletado;
    final enRiesgo = currentRacha.enRiesgo;
    final fechaInicioPeriodoRecuperacion =
        currentRacha.fechaInicioPeriodoRecuperacion;

    // Caso 1: Ya se completó en la semana actual
    if (lastCompleted.isNotEmpty && Racha.isSameWeek(lastCompleted, today)) {
      if (enRiesgo) {
        // Se recuperó la racha
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      // Ya estaba en racha y se completó de nuevo (mantener)
      return currentRacha.copyWith(
        fechaUltimoCompletado: today,
      );
    }

    // Caso 2: Racha estaba en riesgo
    if (enRiesgo && fechaInicioPeriodoRecuperacion.isNotEmpty) {
      final diasDesdeInicio =
          Racha.daysBetween(fechaInicioPeriodoRecuperacion, today);

      if (diasDesdeInicio >= 8) {
        // Pasó el período de recuperación (8 días), se pierde la racha
        return currentRacha.copyWith(
          cantidad: 0,
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      } else if (completedWeeklyHabitThisWeek) {
        // Se recuperó en el período de gracia
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      // Sigue en período de recuperación sin completar
      return currentRacha;
    }

    // Caso 3: Racha activa, no en riesgo
    if (lastCompleted.isNotEmpty && !enRiesgo) {
      if (completedWeeklyHabitThisWeek) {
        // Se completó esta semana, incrementar racha
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        // No se completó esta semana, pasar a estado de riesgo
        final monday = Racha.getMondayOfWeek(AppClock.now());
        return currentRacha.copyWith(
          enRiesgo: true,
          fechaInicioPeriodoRecuperacion: monday,
          fechaUltimoCompletado: today,
        );
      }
    }

    // Caso 4: Primera racha
    if (lastCompleted.isEmpty && completedWeeklyHabitThisWeek) {
      return currentRacha.copyWith(
        cantidad: 1,
        fechaUltimoCompletado: today,
      );
    }

    return currentRacha;
  }

  /// Verifica si se completó un hábito diario hoy
  /// SOLO cuenta hábitos EXCLUSIVAMENTE diarios (vecesPorSemana >= 7)
  static bool hasCompletedDailyHabitToday(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana >= 7) // SOLO hábitos diarios
        .toList();
    
    return dailyHabits.any((h) {
      // Primero verificar fechasCompletadas (fuente de verdad)
      if (h.safeFechasCompletadas.contains(today)) {
        return true;
      }
      // Luego verificar completadoHoy como fallback
      return h.completadoHoy;
    });
  }

  /// Verifica si se completó un hábito semanal esta semana
  /// SOLO cuenta hábitos EXCLUSIVAMENTE semanales (vecesPorSemana < 7)
  static bool hasCompletedWeeklyHabitThisWeek(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final monday = Racha.getMondayOfWeek(DateTime.now());
    
    final weeklyHabits = habits
        .where((h) => h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0) // SOLO hábitos semanales
        .toList();

    return weeklyHabits.any((h) {
      // Verificar si hay alguna fecha completada en la semana actual
      return h.safeFechasCompletadas.any((fecha) {
        return fecha.compareTo(monday) >= 0 && fecha.compareTo(today) <= 0;
      });
    });
  }
  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Racha DIARIA: días consecutivos (terminando hoy) con al menos un hábito
  /// completado. Si hoy aún no hay nada, no se rompe: se cuenta desde ayer.
  static int calcularRachaDiaria(List<Habito> habits) {
    bool completadoEn(DateTime dia) {
      final s = _fmt(dia);
      return habits.any((h) => h.safeFechasCompletadas.contains(s));
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
  static bool completadoHoy(List<Habito> habits) {
    final hoy = _fmt(AppClock.now());
    return habits.any((h) => h.safeFechasCompletadas.contains(hoy));
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
