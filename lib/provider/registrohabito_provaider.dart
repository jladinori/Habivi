// registro_habito_provider.dart

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/registro_habito.dart';

class RegistroHabitoProvider {

  late Box<RegistroHabito> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<RegistroHabito>('registroHabitoBox');
    return box.isOpen;
  }

  Future<bool> anadirRegistroHabito(RegistroHabito registroHabito) async {
    await box.add(registroHabito);
    return true;
  }

  Map<dynamic, RegistroHabito> leerRegistroHabito() {
    return box.toMap();
  }

  Future<bool> eliminarRegistroHabito(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarRegistroHabito(
    int indice,
    RegistroHabito registroHabito,
  ) async {
    await box.putAt(indice, registroHabito);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}