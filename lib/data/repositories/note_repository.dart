import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/nota.dart';

class NoteRepository {
  Box<Nota>? _box;

  Future<Box<Nota>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Nota>(HiveBoxNames.nota);
    return _box!;
  }

  Future<void> add(Nota nota) async {
    final b = await box;
    await b.add(nota);
  }

  Future<Map<dynamic, Nota>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, Nota nota) async {
    final b = await box;
    await b.putAt(index, nota);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
