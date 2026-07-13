import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/habito.dart';

class RachaService {
  static Racha updateDailyRacha({
    required Racha currentRacha,
    required bool completedDailyHabitToday,
  }) {
    final today = Racha.getTodayFormatted();
    final lastCompleted = currentRacha.fechaUltimoCompletado;

    if (completedDailyHabitToday) {
      if (lastCompleted.isEmpty) {
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      } else if (Racha.isSameDay(lastCompleted, today)) {
        return currentRacha;
      } else if (Racha.isNextDay(lastCompleted, today)) {
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      }
    } else {
      if (Racha.isSameDay(lastCompleted, today)) {
        return currentRacha;
      }

      if (Racha.isNextDay(lastCompleted, today)) {
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      } else if (lastCompleted.isNotEmpty && !Racha.isSameDay(lastCompleted, today)) {
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      }
    }

    return currentRacha;
  }

  static Racha updateWeeklyRacha({
    required Racha currentRacha,
    required bool completedWeeklyHabitThisWeek,
  }) {
    final today = Racha.getTodayFormatted();
    final lastCompleted = currentRacha.fechaUltimoCompletado;
    final enRiesgo = currentRacha.enRiesgo;
    final fechaInicioPeriodoRecuperacion =
        currentRacha.fechaInicioPeriodoRecuperacion;

    if (lastCompleted.isNotEmpty && Racha.isSameWeek(lastCompleted, today)) {
      if (enRiesgo) {
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      return currentRacha.copyWith(
        fechaUltimoCompletado: today,
      );
    }

    if (enRiesgo && fechaInicioPeriodoRecuperacion.isNotEmpty) {
      final diasDesdeInicio =
          Racha.daysBetween(fechaInicioPeriodoRecuperacion, today);

      if (diasDesdeInicio >= 8) {
        return currentRacha.copyWith(
          cantidad: 0,
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      } else if (completedWeeklyHabitThisWeek) {
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      return currentRacha;
    }

    if (lastCompleted.isNotEmpty && !enRiesgo) {
      if (completedWeeklyHabitThisWeek) {
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        final monday = Racha.getMondayOfWeek(DateTime.now());
        return currentRacha.copyWith(
          enRiesgo: true,
          fechaInicioPeriodoRecuperacion: monday,
          fechaUltimoCompletado: today,
        );
      }
    }

    if (lastCompleted.isEmpty && completedWeeklyHabitThisWeek) {
      return currentRacha.copyWith(
        cantidad: 1,
        fechaUltimoCompletado: today,
      );
    }

    return currentRacha;
  }

  static bool hasCompletedDailyHabitToday(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final dailyHabits = habits
        .where((h) => h.safeVecesPorSemana >= 7)
        .toList();

    return dailyHabits.any((h) {
      if (h.safeFechasCompletadas.contains(today)) {
        return true;
      }
      return h.completadoHoy;
    });
  }

  static bool hasCompletedWeeklyHabitThisWeek(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final monday = Racha.getMondayOfWeek(DateTime.now());

    final weeklyHabits = habits
        .where((h) => h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0)
        .toList();

    return weeklyHabits.any((h) {
      return h.safeFechasCompletadas.any((fecha) {
        return fecha.compareTo(monday) >= 0 && fecha.compareTo(today) <= 0;
      });
    });
  }

  static String getRachaColor(String tipo, bool enRiesgo) {
    if (tipo == 'diaria') {
      return '#FF4444';
    } else {
      return enRiesgo ? '#808080' : '#6B5FFF';
    }
  }

  static String getRachaEmoji() => '🔥';

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

  static String getRecuperationMessage() => 'Recupérala esta semana.';
}
