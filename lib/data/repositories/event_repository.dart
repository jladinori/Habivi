import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/evento.dart';

class EventRepository {
  Box<Evento>? _box;

  Future<Box<Evento>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Evento>(HiveBoxNames.evento);
    return _box!;
  }

  Future<void> add(Evento evento) async {
    final b = await box;
    await b.add(evento);
    await b.flush();
  }

  Future<Map<dynamic, Evento>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
    await b.flush();
  }

  Future<void> updateAt(int index, Evento evento) async {
    final b = await box;
    await b.putAt(index, evento);
    await b.flush();
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
