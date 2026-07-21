import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/core/utils/app_clock.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/data/repositories/habit_repository.dart';
import 'package:habivi/data/repositories/task_repository.dart';
import 'package:habivi/data/repositories/user_repository.dart';
import 'package:habivi/domain/enums/character_mood.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';
import 'package:habivi/domain/services/achievement_service.dart';
import 'package:habivi/domain/services/energy_service.dart';
import 'package:habivi/domain/services/mood_service.dart';
import 'package:habivi/presentation/providers/dev_mode_provider.dart';

class HabitoConIndice {
  final int index;
  final Habito habito;
  const HabitoConIndice(this.index, this.habito);
}

class DashboardData {
  final String nombreUsuario;
  final int energia;
  final EnergiaAtributos atributos;
  final CharacterMood mood;
  final int racha;
  final int puntosEstudio;
  final int habitosHoy;
  final int totalHabitos;
  final List<HabitoConIndice> pendientesHoy;
  final List<Tarea> tareasHoy;
  final List<Logro> ultimosLogros;
  final int totalLogros;
  final int logrosDesbloqueados;

  const DashboardData({
    required this.nombreUsuario,
    required this.energia,
    required this.atributos,
    required this.mood,
    required this.racha,
    required this.puntosEstudio,
    required this.habitosHoy,
    required this.totalHabitos,
    required this.pendientesHoy,
    required this.tareasHoy,
    required this.ultimosLogros,
    required this.totalLogros,
    required this.logrosDesbloqueados,
  });
}

String _today() {
  final now = AppClock.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

// Emite un "tic" cada vez que cambian los hábitos (para refrescar en vivo).
final _habitTick = StreamProvider<int>((ref) async* {
  final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
  yield 0;
  await for (final _ in box.watch()) {
    yield DateTime.now().millisecondsSinceEpoch;
  }
});

// Emite un "tic" cada vez que cambian las sesiones de estudio.
final _estudioTick = StreamProvider<int>((ref) async* {
  final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
  yield 0;
  await for (final _ in box.watch()) {
    yield DateTime.now().millisecondsSinceEpoch;
  }
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  // Al observar estos 3, el dashboard se recalcula solo cuando:
  ref.watch(_habitTick); // cambian los hábitos
  ref.watch(_estudioTick); // cambian los puntos de estudio
  ref.watch(timeOffsetProvider); // avanzas el reloj (modo dev)

  final hoy = _today();

  final energia = await EnergyService.calculate();
  final atributos = await EnergyService.calculatePorAtributo();
  final diasSin = await EnergyService.diasSinActividad();
  final mood = MoodService.calculateFrom(
      energia: energia, atributos: atributos, diasSinActividad: diasSin);
  final racha = await EnergyService.rachaActual();
  final habitosHoy = await EnergyService.habitosCompletadosHoy();

  final habitosMap = await HabitRepository().readAll();
  final habitos = habitosMap.values.toList();
  final pendientes = <HabitoConIndice>[];
  for (var i = 0; i < habitos.length; i++) {
    final h = habitos[i];
    final completado = h.completadoHoy || h.safeFechasCompletadas.contains(hoy);
    if (!completado) pendientes.add(HabitoConIndice(i, h));
  }

  final tareasMap = await TaskRepository().readAll();
  final tareasHoy = tareasMap.values.where((t) => t.fecha == hoy).toList();

  final puntos = await EstudioRepository().totalPuntos();

  String nombre = '';
  try {
    final usuarios = await UserRepository().readAll();
    if (usuarios.isNotEmpty) nombre = usuarios.values.first.nombre;
  } catch (_) {}

  final achievementService = AchievementService();
  final logros = await achievementService.unlockedLogros();

  return DashboardData(
    nombreUsuario: nombre,
    energia: energia,
    atributos: atributos,
    mood: mood,
    racha: racha,
    puntosEstudio: puntos,
    habitosHoy: habitosHoy,
    totalHabitos: habitos.length,
    pendientesHoy: pendientes,
    tareasHoy: tareasHoy,
    ultimosLogros: logros.take(3).toList(),
    totalLogros: achievementCatalog.length,
    logrosDesbloqueados: logros.length,
  );
});
