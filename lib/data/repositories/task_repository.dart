import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/tarea.dart';

class TaskRepository {
  Box<Tarea>? _box;

  Future<Box<Tarea>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Tarea>(HiveBoxNames.tarea);
    return _box!;
  }

  Future<void> add(Tarea tarea) async {
    final b = await box;
    await b.add(tarea);
  }

  Future<Map<dynamic, Tarea>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, Tarea tarea) async {
    final b = await box;
    await b.putAt(index, tarea);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
