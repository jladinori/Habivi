import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/habito.dart';

class HabitRepository {
  Box<Habito>? _box;

  Future<Box<Habito>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    return _box!;
  }

  Future<void> add(Habito habito) async {
    final b = await box;
    await b.add(habito);
  }

  Future<Map<dynamic, Habito>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, Habito habito) async {
    final b = await box;
    await b.putAt(index, habito);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
