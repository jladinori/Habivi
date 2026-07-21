import 'package:flutter/material.dart';
import 'package:habivi/core/utils/app_clock.dart';
import 'package:habivi/data/repositories/habit_repository.dart';

class HabitMoodService {
  static final HabitRepository _repository = HabitRepository();

  /// Calcula el % de energía de la barra según la FRECUENCIA de cada hábito.
  /// Un hábito diario mantiene su energía 1 día y luego baja; uno semanal
  /// la mantiene 7 días antes de bajar, etc.
  static Future<double> calculateMoodPercentage() async {
    try {
      final habitosMap = await _repository.readAll();
      if (habitosMap.isEmpty) return 0.0;
      final habitos = habitosMap.values.toList();

      double sumaAportes = 0;
      int contados = 0;

            for (final h in habitos) {
        contados++;

        final fechas = h.safeFechasCompletadas;
        if (fechas.isEmpty) continue; // nunca completado → aporta 0

        // periodo = días que "dura" una completada según su frecuencia
        final int periodo =
            (7 / h.safeVecesPorSemana).ceil().clamp(1, 7).toInt();

        // días desde la ÚLTIMA fecha realmente marcada (la LISTA es la verdad,
        // NO fechaUltimoCompletado, que no se revierte al desmarcar)
        final ultima = fechas.reduce((a, b) => a.compareTo(b) > 0 ? a : b);
        final diasDesde = _daysSince(ultima);

        double aporte;
        if (diasDesde < periodo) {
          aporte = 1.0; // dentro de su ventana → aporta lleno
        } else {
          // pasada su ventana: se descuenta por cada día extra
          final exceso = diasDesde - periodo + 1;
          aporte = (1.0 - exceso * 0.2).clamp(0.0, 1.0);
        }
        sumaAportes += aporte;
      }

      if (contados == 0) return 0.0;
      return (sumaAportes / contados).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  static int _daysSince(String date) {
    try {
      final parts = date.split('-');
      final dt = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return AppClock.now().difference(dt).inDays;
    } catch (_) {
      return 0;
    }
  }

  /// Obtiene el estado de ánimo basado en el porcentaje
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