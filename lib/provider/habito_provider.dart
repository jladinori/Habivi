// habito_provider.dart

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/habito.dart';

class HabitoProvider {

  late Box<Habito> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<Habito>('habitoBox');
    return box.isOpen;
  }

  Future<bool> anadirHabito(Habito habito) async {
    await box.add(habito);
    return true;
  }

  Map<dynamic, Habito> leerHabito() {
    return box.toMap();
  }

  Future<bool> eliminarHabito(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarHabito(int indice, Habito habito) async {
    await box.putAt(indice, habito);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}