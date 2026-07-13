import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

class EstudioRepository {
  Box<SesionEstudio>? _box;

  Future<Box<SesionEstudio>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    return _box!;
  }

  Future<void> add(SesionEstudio sesion) async {
    final b = await box;
    await b.add(sesion);
    await b.flush();
  }

  Future<Map<dynamic, SesionEstudio>> readAll() async {
    final b = await box;
    return b.toMap();
  }

  Future<void> deleteAt(int index) async {
    final b = await box;
    await b.deleteAt(index);
    await b.flush();
  }

  Future<void> updateAt(int index, SesionEstudio sesion) async {
    final b = await box;
    await b.putAt(index, sesion);
    await b.flush();
  }

  Future<int> totalPuntos() async {
    final b = await box;
    int total = 0;
    for (final s in b.values) {
      total += s.puntosObtenidos;
    }
    return total;
  }

  Future<void> dispose() async {
    if (_box?.isOpen ?? false) await _box!.close();
    _box = null;
  }
}
