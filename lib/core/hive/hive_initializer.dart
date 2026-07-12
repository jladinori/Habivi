import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/data/models/backup.dart';
import 'package:habivi/data/models/cuenta.dart';
import 'package:habivi/data/models/evento.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/nota.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/registro_habito.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/sesion_pomodoro.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/models/usuario.dart';

/// Inicializa Hive y registra todos los adaptadores una sola vez.
class HiveInitializer {
  static Future<void> init() async {
    await Hive.initFlutter();
    registerAdapters();
  }

  /// Para tests unitarios sin plugins nativos.
  static Future<void> initForTesting(String path) async {
    Hive.init(path);
    registerAdapters();
  }

  /// Cierra todas las cajas Hive. Llamar al terminar la app.
  static Future<void> closeAll() async {
    await Hive.close();
  }

  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UsuarioAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CuentaAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HabitoAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(RegistroHabitoAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(TareaAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(SesionPomodoroAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(NotaAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(EventoAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(BackupAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(SesionEstudioAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(RachaAdapter());
    }
  }
}
