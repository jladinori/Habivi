import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/repositories/habit_repository.dart';

class HabitCompletionService {
  final HabitRepository _repository;

  HabitCompletionService({HabitRepository? repository})
      : _repository = repository ?? HabitRepository();

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<Habito> toggle(int index, Habito habito) async {
    final hoy = _today();
    habito.completadoHoy = !habito.completadoHoy;
    habito.fechaUltimoCompletado = hoy;

    final fechas = List<String>.from(habito.safeFechasCompletadas);
    if (habito.completadoHoy) {
      if (!fechas.contains(hoy)) fechas.add(hoy);
    } else {
      fechas.remove(hoy);
    }
    habito.fechasCompletadas = fechas;

    await _repository.updateAt(index, habito);
    return habito;
  }
}
