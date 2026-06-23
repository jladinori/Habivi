import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';

class EnergyService {
  static const int maxEnergy = 100;
  static const int daysToZero = 7;
  static const int dailyDecay = maxEnergy ~/ daysToZero;
  static const int energyPerHabit = 8;
  static const int energyPerTask = 5;

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
