import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/racha.dart';

class RachaRepository {
  Future<Box<Racha>> get _box => Hive.openBox<Racha>(HiveBoxNames.racha);

  Future<Map<dynamic, Racha>> readAll() async {
    final box = await _box;
    return box.toMap();
  }

  Future<Racha?> readById(int id) async {
    final box = await _box;
    return box.get(id);
  }

  Future<Racha?> readDailyRacha() async {
    final box = await _box;
    final all = box.toMap();
    try {
      return all.values.firstWhere((racha) => racha.tipo == 'diaria');
    } catch (e) {
      return null;
    }
  }

  Future<Racha?> readWeeklyRacha() async {
    final box = await _box;
    final all = box.toMap();
    try {
      return all.values.firstWhere((racha) => racha.tipo == 'semanal');
    } catch (e) {
      return null;
    }
  }

  Future<void> create(Racha racha) async {
    final box = await _box;
    await box.put(racha.idRacha, racha);
  }

  Future<void> updateAt(int key, Racha racha) async {
    final box = await _box;
    await box.put(key, racha);
  }

  Future<void> update(Racha racha) async {
    final box = await _box;
    await box.put(racha.idRacha, racha);
  }

  Future<void> deleteAt(int key) async {
    final box = await _box;
    await box.delete(key);
  }

  Future<void> deleteAll() async {
    final box = await _box;
    await box.clear();
  }

  Future<void> initializeDefaults() async {
    final dailyRacha = await readDailyRacha();
    final weeklyRacha = await readWeeklyRacha();

    if (dailyRacha == null) {
      await create(Racha(
        idRacha: 1,
        tipo: 'diaria',
        cantidad: 0,
        fechaUltimoCompletado: '',
        fechaCreacion: Racha.getTodayFormatted(),
      ));
    }

    if (weeklyRacha == null) {
      await create(Racha(
        idRacha: 2,
        tipo: 'semanal',
        cantidad: 0,
        fechaUltimoCompletado: '',
        fechaCreacion: Racha.getTodayFormatted(),
      ));
    }
  }
}
