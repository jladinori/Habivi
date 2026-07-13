import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/logro.dart';

class AchievementRepository {
  Box<Logro>? _box;

  Future<Box<Logro>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Logro>(HiveBoxNames.logro);
    return _box!;
  }

  Future<void> add(Logro logro) async {
    final b = await box;
    await b.add(logro);
    await b.flush();
  }

  Future<Map<dynamic, Logro>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<Set<String>> unlockedIds() async {
    final b = await box;
    return b.values.map((l) => l.idLogro).toSet();
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
