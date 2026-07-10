import 'package:hive_flutter/hive_flutter.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/data/models/backup.dart';
import 'package:habivi/data/models/cuenta.dart';
import 'package:habivi/data/models/evento.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/nota.dart';
import 'package:habivi/data/models/registro_habito.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/sesion_pomodoro.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/models/usuario.dart';

/// Servicio central que define la base de datos local de Habivi.
///
/// Contiene todas las cajas necesarias para guardar:
/// - cuentas de usuario y datos de sesión
/// - perfiles de usuario, energía y estado del personaje
/// - hábitos y días marcados
/// - pendientes y su estado de completado
/// - sesiones de productividad Pomodoro y estudio
/// - eventos, notas y respaldos
class AppDatabase {
  AppDatabase._();

  static Future<void> initialize() async {
    await HiveInitializer.init();
    await openAllBoxes();
  }

  static Future<void> openAllBoxes() async {
    await Future.wait([
      Hive.openBox<Usuario>(HiveBoxNames.usuario),
      Hive.openBox<Cuenta>(HiveBoxNames.cuenta),
      Hive.openBox<Habito>(HiveBoxNames.habito),
      Hive.openBox<RegistroHabito>(HiveBoxNames.registroHabito),
      Hive.openBox<Tarea>(HiveBoxNames.tarea),
      Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro),
      Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio),
      Hive.openBox<Nota>(HiveBoxNames.nota),
      Hive.openBox<Evento>(HiveBoxNames.evento),
      Hive.openBox<Backup>(HiveBoxNames.backup),
    ]);
  }

  static Future<Box<Usuario>> userBox() => Hive.openBox<Usuario>(HiveBoxNames.usuario);
  static Future<Box<Cuenta>> accountBox() => Hive.openBox<Cuenta>(HiveBoxNames.cuenta);
  static Future<Box<Habito>> habitBox() => Hive.openBox<Habito>(HiveBoxNames.habito);
  static Future<Box<RegistroHabito>> habitLogBox() => Hive.openBox<RegistroHabito>(HiveBoxNames.registroHabito);
  static Future<Box<Tarea>> taskBox() => Hive.openBox<Tarea>(HiveBoxNames.tarea);
  static Future<Box<SesionPomodoro>> pomodoroBox() => Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro);
  static Future<Box<SesionEstudio>> estudioBox() => Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
  static Future<Box<Nota>> noteBox() => Hive.openBox<Nota>(HiveBoxNames.nota);
  static Future<Box<Evento>> eventBox() => Hive.openBox<Evento>(HiveBoxNames.evento);
  static Future<Box<Backup>> backupBox() => Hive.openBox<Backup>(HiveBoxNames.backup);

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
