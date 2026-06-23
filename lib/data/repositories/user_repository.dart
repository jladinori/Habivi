import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/usuario.dart';

class UserRepository {
  Box<Usuario>? _box;

  Future<Box<Usuario>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
    return _box!;
  }

  Future<void> add(Usuario usuario) async {
    final b = await box;
    await b.add(usuario);
    await b.flush();
  }

  Future<Map<dynamic, Usuario>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
    await b.flush();
  }

  Future<void> updateAt(int index, Usuario usuario) async {
    final b = await box;
    await b.putAt(index, usuario);
    await b.flush();
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
