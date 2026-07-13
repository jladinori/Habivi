import 'dart:math' as math;

import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';

class EnergiaAtributos {
  final int cuerpo;
  final int mente;
  final int alma;
  final bool tieneCuerpo;
  final bool tieneMente;
  final bool tieneAlma;

  const EnergiaAtributos({
    required this.cuerpo,
    required this.mente,
    required this.alma,
    this.tieneCuerpo = true,
    this.tieneMente = true,
    this.tieneAlma = true,
  });

  List<int> get _activos => [
        if (tieneCuerpo) cuerpo,
        if (tieneMente) mente,
        if (tieneAlma) alma,
      ];

  int get promedio {
    final a = _activos;
    if (a.isEmpty) return 0;
    return a.reduce((x, y) => x + y) ~/ a.length;
  }

  int get desbalance {
    final a = _activos;
    if (a.length < 2) return 0;
    return a.reduce(math.max) - a.reduce(math.min);
  }

  bool get estaDesbalanceada => desbalance >= EnergyService.umbralDesbalance;
}

class EnergyService {
  static const int maxEnergy = 100;
  static const int daysToZero = 7;
  static const int dailyDecay = maxEnergy ~/ daysToZero;
  static const int energyPerHabit = 8;
  static const int energyPerTask = 5;
  static const int umbralDesbalance = 40;

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static int _daysSince(String date) {
    try {
      final parts = date.split('-');
      final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return DateTime.now().difference(dt).inDays;
    } catch (_) {
      return 0;
    }
  }

  static Future<int> calculate() async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    final today = _today();

    int totalCompletionsToday = 0;
    String? lastActivityDate;

    for (final habito in box.values) {
      if (habito.completadoHoy || habito.safeFechasCompletadas.contains(today)) {
        totalCompletionsToday++;
      }
      if (habito.fechaUltimoCompletado.isNotEmpty) {
        if (lastActivityDate == null || habito.fechaUltimoCompletado.compareTo(lastActivityDate) > 0) {
          lastActivityDate = habito.fechaUltimoCompletado;
        }
      }
    }

    int energy = maxEnergy;
    if (lastActivityDate != null) {
      final daysInactive = _daysSince(lastActivityDate);
      energy -= daysInactive * dailyDecay;
    }
    energy += totalCompletionsToday * energyPerHabit;

    return energy.clamp(0, maxEnergy);
  }

  static Future<int> habitosCompletadosHoy() async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    final today = _today();
    int count = 0;
    for (final habito in box.values) {
      if (habito.completadoHoy || habito.safeFechasCompletadas.contains(today)) {
        count++;
      }
    }
    return count;
  }

  static Future<EnergiaAtributos> calculatePorAtributo() async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    final habitos = box.values.toList();

    int energiaDe(String aspecto) {
      final propios = habitos.where((h) => h.aspecto == aspecto).toList();
      if (propios.isEmpty) return 0;

      final today = _today();
      int completadosHoy = 0;
      String? ultimaActividad;

      for (final h in propios) {
        if (h.completadoHoy || h.safeFechasCompletadas.contains(today)) completadosHoy++;
        if (h.fechaUltimoCompletado.isNotEmpty) {
          if (ultimaActividad == null || h.fechaUltimoCompletado.compareTo(ultimaActividad) > 0) {
            ultimaActividad = h.fechaUltimoCompletado;
          }
        }
      }

      int energia = maxEnergy;
      if (ultimaActividad != null) {
        energia -= _daysSince(ultimaActividad) * dailyDecay;
      }
      energia += completadosHoy * energyPerHabit;
      return energia.clamp(0, maxEnergy);
    }

    bool tiene(String aspecto) => habitos.any((h) => h.aspecto == aspecto);

    return EnergiaAtributos(
      cuerpo: energiaDe('físico'),
      mente: energiaDe('mental'),
      alma: energiaDe('espiritual'),
      tieneCuerpo: tiene('físico'),
      tieneMente: tiene('mental'),
      tieneAlma: tiene('espiritual'),
    );
  }

  static Future<int> diasSinActividad() async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    String? ultima;
    for (final h in box.values) {
      for (final f in h.safeFechasCompletadas) {
        if (ultima == null || f.compareTo(ultima) > 0) ultima = f;
      }
    }
    if (ultima == null) return 0;
    return _daysSince(ultima);
  }

  static Future<int> rachaActual() async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    int streak = 0;
    final now = DateTime.now();

    for (int d = 0; d < 365; d++) {
      final day = now.subtract(Duration(days: d));
      final dateStr = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      bool anyCompleted = false;
      for (final habito in box.values) {
        if (habito.safeFechasCompletadas.contains(dateStr)) {
          anyCompleted = true;
          break;
        }
      }
      if (anyCompleted) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
