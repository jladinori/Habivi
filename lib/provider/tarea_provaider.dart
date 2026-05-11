// tarea_provider.dart

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/tarea.dart';

class TareaProvider {

  late Box<Tarea> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<Tarea>('tareaBox');
    return box.isOpen;
  }

  Future<bool> anadirTarea(Tarea tarea) async {
    await box.add(tarea);
    return true;
  }

  Map<dynamic, Tarea> leerTarea() {
    return box.toMap();
  }

  Future<bool> eliminarTarea(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarTarea(int indice, Tarea tarea) async {
    await box.putAt(indice, tarea);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}