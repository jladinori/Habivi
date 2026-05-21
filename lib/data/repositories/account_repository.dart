import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/cuenta.dart';

class AccountRepository {
  Box<Cuenta>? _box;

  Future<Box<Cuenta>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<Cuenta>(HiveBoxNames.cuenta);
    return _box!;
  }

  Future<void> add(Cuenta cuenta) async {
    final b = await box;
    await b.add(cuenta);
  }

  Future<Map<dynamic, Cuenta>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
  }

  Future<void> updateAt(int index, Cuenta cuenta) async {
    final b = await box;
    await b.putAt(index, cuenta);
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
