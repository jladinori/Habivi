import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/data/repositories/achievement_repository.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';
import 'package:habivi/domain/services/energy_service.dart';

class AchievementService {
  final AchievementRepository _repo;
  final EstudioRepository _estudioRepo;

  AchievementService({
    AchievementRepository? repository,
    EstudioRepository? estudioRepository,
  })  : _repo = repository ?? AchievementRepository(),
        _estudioRepo = estudioRepository ?? EstudioRepository();

  static String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<GamificationStats> buildStats() async {
    final habitoBox = await Hive.openBox<Habito>(HiveBoxNames.habito);
    final habitos = habitoBox.values.toList();

    int totalCompletados = 0;
    for (final h in habitos) {
      totalCompletados += h.safeFechasCompletadas.length;
    }

    final sesiones = await _estudioRepo.readAll();

    return GamificationStats(
      totalCompletados: totalCompletados,
      racha: await EnergyService.rachaActual(),
      habitosHoy: await EnergyService.habitosCompletadosHoy(),
      totalHabitos: habitos.length,
      sesionesEstudio: sesiones.length,
      puntosEstudio: await _estudioRepo.totalPuntos(),
      atributos: await EnergyService.calculatePorAtributo(),
    );
  }

  Future<List<AchievementDef>> checkAndUnlock() async {
    final stats = await buildStats();
    final unlocked = await _repo.unlockedIds();
    final nuevos = <AchievementDef>[];

    for (final def in achievementCatalog) {
      if (unlocked.contains(def.id)) continue;
      if (def.condicion(stats)) {
        await _repo.add(Logro(def.id, _today()));
        nuevos.add(def);
      }
    }
    return nuevos;
  }

  Future<Set<String>> unlockedIds() => _repo.unlockedIds();

  Future<List<Logro>> unlockedLogros() async {
    final all = await _repo.readAll();
    final list = all.values.toList()
      ..sort((a, b) => b.fechaDesbloqueo.compareTo(a.fechaDesbloqueo));
    return list;
  }
}
