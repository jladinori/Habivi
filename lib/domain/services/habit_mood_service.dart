import 'package:flutter/material.dart';
import 'package:habivi/data/repositories/habit_repository.dart';

class HabitMoodService {
  static final HabitRepository _repository = HabitRepository();

  /// Calcula el porcentaje de cumplimiento de hábitos en el último mes
  /// Considera todos los días desde hace 30 días hasta hoy
  static Future<double> calculateMoodPercentage() async {
    try {
      final habitosMap = await _repository.readAll();
      if (habitosMap.isEmpty) return 0.0;

      final habitos = habitosMap.values.toList();
      final today = DateTime.now();

      // Obtener la primera fecha de creación de hábitos para usar como inicio.
      final startDate = habitos
          .map((h) => DateTime.parse(h.safeFechaCreacion))
          .reduce(
              (value, element) => value.isBefore(element) ? value : element);

      final daysSinceStart = today.difference(startDate).inDays + 1;
      final periodLength = daysSinceStart <= 30 ? daysSinceStart : 21;
      if (periodLength <= 0) return 0.0;

      double totalExpected = 0;
      double totalCompleted = 0;

      for (final habito in habitos) {
        final expectedForPeriod =
            (habito.safeVecesPorSemana / 7.0) * periodLength;
        if (expectedForPeriod <= 0) continue;

        totalExpected += expectedForPeriod;

        int completedInWindow = 0;
        for (int i = 0; i < periodLength; i++) {
          final date = today.subtract(Duration(days: i));
          final dateStr = _formatDate(date);
          if (habito.safeFechasCompletadas.contains(dateStr)) {
            completedInWindow++;
          }
        }

        totalCompleted +=
            completedInWindow.toDouble().clamp(0.0, expectedForPeriod);
      }

      if (totalExpected == 0) return 0.0;
      return (totalCompleted / totalExpected).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Obtiene el estado de ánimo basado en el porcentaje
  /// 5 estados: Feliz (80-100), Normal (60-79), Triste (40-59), Frustrado (20-39), Sin Energía (0-19)
  static String getMoodState(double percentage) {
    final percent = (percentage * 100).toInt();
    if (percent >= 80) return 'Feliz 😊';
    if (percent >= 60) return 'Normal 😐';
    if (percent >= 40) return 'Triste 😔';
    if (percent >= 20) return 'Frustrado 😠';
    return 'Sin Energía 😴';
  }

  /// Retorna el asset de video según el estado de ánimo
  static String getMoodVideo(double percentage) {
    final percent = (percentage * 100).toInt();
    if (percent >= 80) return 'assets/images/feliz.mp4';
    if (percent >= 60) return 'assets/images/enojado.mp4';
    if (percent >= 40) return 'assets/images/triste.mp4';
    if (percent >= 20) return 'assets/images/frustado.mp4';
    return 'assets/images/sinenergia.mp4';
  }

  /// Retorna el color según el estado de ánimo
  /// Color del glow del panel, a juego con la paleta de cada video
  static Color getGlowColor(double percentage) {
    final percent = (percentage * 100).toInt();
    if (percent >= 80) return const Color(0xFFFFA000);
    if (percent >= 60) return const Color(0xFFEF5350);
    if (percent >= 40) return const Color(0xFF5C8DBC);
    if (percent >= 20) return const Color.fromARGB(235, 198, 56, 227);
    return const Color(0xFF78909C);
  }
}