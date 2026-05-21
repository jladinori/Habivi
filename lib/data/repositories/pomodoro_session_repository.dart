import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/sesion_pomodoro.dart';

class PomodoroSessionRepository {
  Box<SesionPomodoro>? _box;

  Future<Box<SesionPomodoro>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro);
    return _box!;
  }

  Future<void> add(SesionPomodoro sesion) async {
    final b = await box;
    await b.add(sesion);
  }

  Future<Map<dynamic, SesionPomodoro>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, SesionPomodoro sesion) async {
    final b = await box;
    await b.putAt(index, sesion);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
