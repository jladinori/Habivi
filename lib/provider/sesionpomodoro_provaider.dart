// sesion_pomodoro_provider.dart

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/sesion_pomodoro.dart';

class SesionPomodoroProvider {

  late Box<SesionPomodoro> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<SesionPomodoro>('sesionPomodoroBox');
    return box.isOpen;
  }

  Future<bool> anadirSesionPomodoro(
    SesionPomodoro sesionPomodoro,
  ) async {
    await box.add(sesionPomodoro);
    return true;
  }

  Map<dynamic, SesionPomodoro> leerSesionPomodoro() {
    return box.toMap();
  }

  Future<bool> eliminarSesionPomodoro(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarSesionPomodoro(
    int indice,
    SesionPomodoro sesionPomodoro,
  ) async {
    await box.putAt(indice, sesionPomodoro);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}