import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';

/// Servicio de negocio para gestionar la lógica de rachas
class RachaService {
  /// Actualiza la racha diaria basada en si se completó un hábito diario hoy
  static Racha updateDailyRacha({
    required Racha currentRacha,
    required bool completedDailyHabitToday,
  }) {
    final today = Racha.getTodayFormatted();
    final lastCompleted = currentRacha.fechaUltimoCompletado;

    // Si ya se registró hoy, no hacer cambios
    if (Racha.isSameDay(lastCompleted, today)) {
      return currentRacha;
    }

    if (completedDailyHabitToday) {
      // Completó un hábito hoy
      if (lastCompleted.isEmpty) {
        // Primera vez
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      } else if (Racha.isNextDay(lastCompleted, today)) {
        // Continúa la racha
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        // Se rompió la racha (no fue el día siguiente)
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      }
    } else {
      // No completó ningún hábito hoy
      // Si ayer fue el último día, se pierde la racha
      if (Racha.isNextDay(lastCompleted, today)) {
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      } else if (!Racha.isSameDay(lastCompleted, today)) {
        // Ya pasó más de un día, la racha ya estaba perdida
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
        final monday = Racha.getMondayOfWeek(DateTime.now());
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
  static bool hasCompletedDailyHabitToday(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    return habits
        .where((h) => h.tipo.contains('diario') || h.safeVecesPorSemana >= 7)
        .any((h) => h.completadoHoy || h.safeFechasCompletadas.contains(today));
  }

  /// Verifica si se completó un hábito semanal esta semana
  static bool hasCompletedWeeklyHabitThisWeek(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final monday = Racha.getMondayOfWeek(DateTime.now());

    return habits
        .where((h) => h.tipo.contains('semanal') || (h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0))
        .any((h) {
          return h.safeFechasCompletadas.any((fecha) {
            return fecha.compareTo(monday) >= 0 && fecha.compareTo(today) <= 0;
          });
        });
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

  /// Obtiene el mensaje de recuperación para la racha semanal
  static String getRecuperationMessage() => 'Recupérala esta semana.';
}
