import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/registro_habito.dart';

class HabitLogRepository {
  Box<RegistroHabito>? _box;

  Future<Box<RegistroHabito>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<RegistroHabito>(HiveBoxNames.registroHabito);
    return _box!;
  }

  Future<void> add(RegistroHabito registro) async {
    final b = await box;
    await b.add(registro);
  }

  Future<Map<dynamic, RegistroHabito>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, RegistroHabito registro) async {
    final b = await box;
    await b.putAt(index, registro);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
