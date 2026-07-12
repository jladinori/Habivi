import 'package:flutter/foundation.dart';
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

    if (kDebugMode) {
      print('🔍 [RachaService] updateDailyRacha:');
      print('   today: $today');
      print('   lastCompleted: $lastCompleted');
      print('   completedDailyHabitToday: $completedDailyHabitToday');
      print('   currentRacha.cantidad: ${currentRacha.cantidad}');
    }

    // Si ya se registró hoy, no hacer cambios
    if (Racha.isSameDay(lastCompleted, today)) {
      if (kDebugMode) print('   ✓ Ya se registró hoy, sin cambios');
      return currentRacha;
    }

    if (completedDailyHabitToday) {
      // Completó un hábito hoy
      if (lastCompleted.isEmpty) {
        // Primera vez
        if (kDebugMode) print('   ✓ Primera racha diaria, cantidad = 1');
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      } else if (Racha.isNextDay(lastCompleted, today)) {
        // Continúa la racha
        if (kDebugMode) print('   ✓ Continúa racha diaria, cantidad = ${currentRacha.cantidad + 1}');
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        // Se rompió la racha (no fue el día siguiente)
        if (kDebugMode) print('   ⚠ Se rompió racha, reinicia en 1');
        return currentRacha.copyWith(
          cantidad: 1,
          fechaUltimoCompletado: today,
        );
      }
    } else {
      // No completó ningún hábito hoy
      if (kDebugMode) print('   ℹ No hay hábito completado hoy');
      // Si ayer fue el último día, se pierde la racha
      if (Racha.isNextDay(lastCompleted, today)) {
        if (kDebugMode) print('   ⚠ Se pierde racha diaria');
        return currentRacha.copyWith(
          cantidad: 0,
          fechaUltimoCompletado: today,
        );
      } else if (!Racha.isSameDay(lastCompleted, today)) {
        // Ya pasó más de un día, la racha ya estaba perdida
        if (kDebugMode) print('   ⚠ Racha ya estaba perdida');
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

    if (kDebugMode) {
      print('🔍 [RachaService] updateWeeklyRacha:');
      print('   today: $today');
      print('   lastCompleted: $lastCompleted');
      print('   completedWeeklyHabitThisWeek: $completedWeeklyHabitThisWeek');
      print('   enRiesgo: $enRiesgo');
    }

    // Caso 1: Ya se completó en la semana actual
    if (lastCompleted.isNotEmpty && Racha.isSameWeek(lastCompleted, today)) {
      if (enRiesgo) {
        // Se recuperó la racha
        if (kDebugMode) print('   ✓ Se recuperó racha semanal');
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      // Ya estaba en racha y se completó de nuevo (mantener)
      if (kDebugMode) print('   ✓ Ya estaba en racha');
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
        if (kDebugMode) print('   ⚠ Pasó período de recuperación, se pierde');
        return currentRacha.copyWith(
          cantidad: 0,
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      } else if (completedWeeklyHabitThisWeek) {
        // Se recuperó en el período de gracia
        if (kDebugMode) print('   ✓ Se recuperó en período de gracia');
        return currentRacha.copyWith(
          enRiesgo: false,
          fechaInicioPeriodoRecuperacion: '',
          fechaUltimoCompletado: today,
        );
      }
      // Sigue en período de recuperación sin completar
      if (kDebugMode) print('   ℹ Sigue en período de recuperación');
      return currentRacha;
    }

    // Caso 3: Racha activa, no en riesgo
    if (lastCompleted.isNotEmpty && !enRiesgo) {
      if (completedWeeklyHabitThisWeek) {
        // Se completó esta semana, incrementar racha
        if (kDebugMode) print('   ✓ Incrementa racha semanal a ${currentRacha.cantidad + 1}');
        return currentRacha.copyWith(
          cantidad: currentRacha.cantidad + 1,
          fechaUltimoCompletado: today,
        );
      } else {
        // No se completó esta semana, pasar a estado de riesgo
        if (kDebugMode) print('   ⚠ Pasa a estado de riesgo');
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
      if (kDebugMode) print('   ✓ Primera racha semanal');
      return currentRacha.copyWith(
        cantidad: 1,
        fechaUltimoCompletado: today,
      );
    }

    if (kDebugMode) print('   ℹ Sin cambios');
    return currentRacha;
  }

  /// Verifica si se completó un hábito diario hoy
  static bool hasCompletedDailyHabitToday(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final dailyHabits = habits
        .where((h) => h.tipo.contains('diario') || h.safeVecesPorSemana >= 7)
        .toList();
    
    if (kDebugMode) {
      print('🔍 [RachaService] hasCompletedDailyHabitToday:');
      print('   today: $today');
      print('   total habits: ${habits.length}');
      print('   daily habits: ${dailyHabits.length}');
      for (var h in dailyHabits) {
        print('   - ${h.nombreHabito}: vecesPorSemana=${h.safeVecesPorSemana}, completadoHoy=${h.completadoHoy}, fechasCompletadas=${h.safeFechasCompletadas}');
      }
    }
    
    final result = dailyHabits.any((h) {
      // Primero verificar fechasCompletadas (fuente de verdad)
      if (h.safeFechasCompletadas.contains(today)) {
        if (kDebugMode) print('   ✓ ${h.nombreHabito} está en fechasCompletadas');
        return true;
      }
      // Luego verificar completadoHoy como fallback
      if (h.completadoHoy) {
        if (kDebugMode) print('   ✓ ${h.nombreHabito} tiene completadoHoy=true');
        return true;
      }
      return false;
    });
    
    if (kDebugMode) print('   result: $result');
    return result;
  }

  /// Verifica si se completó un hábito semanal esta semana
  static bool hasCompletedWeeklyHabitThisWeek(List<Habito> habits) {
    final today = Racha.getTodayFormatted();
    final monday = Racha.getMondayOfWeek(DateTime.now());
    
    final weeklyHabits = habits
        .where((h) => h.tipo.contains('semanal') || (h.safeVecesPorSemana < 7 && h.safeVecesPorSemana > 0))
        .toList();

    if (kDebugMode) {
      print('🔍 [RachaService] hasCompletedWeeklyHabitThisWeek:');
      print('   today: $today');
      print('   monday: $monday');
      print('   total habits: ${habits.length}');
      print('   weekly habits: ${weeklyHabits.length}');
      for (var h in weeklyHabits) {
        print('   - ${h.nombreHabito}: vecesPorSemana=${h.safeVecesPorSemana}, fechasCompletadas=${h.safeFechasCompletadas}');
      }
    }

    final result = weeklyHabits.any((h) {
      // Verificar si hay alguna fecha completada en la semana actual
      return h.safeFechasCompletadas.any((fecha) {
        return fecha.compareTo(monday) >= 0 && fecha.compareTo(today) <= 0;
      });
    });
    
    if (kDebugMode) print('   result: $result');
    return result;
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
