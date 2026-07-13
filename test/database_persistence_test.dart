import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/data/models/backup.dart';
import 'package:habivi/data/models/cuenta.dart';
import 'package:habivi/data/models/evento.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/data/models/nota.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/registro_habito.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/sesion_pomodoro.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/models/usuario.dart';

void main() {
  late Directory tempDir;
  const testString = r'ñáéíóúüÑ 汉字 العربية!@#$%^&*()';

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_db_test');
    await HiveInitializer.initForTesting(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  // =============================================================
  //  USUARIO (typeId 0) – int, String, String, int
  // =============================================================
  group('Usuario', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<Usuario>(HiveBoxNames.usuario);

      // Crear
      final usuario = Usuario(idUsuario: 1, nombre: 'Carlos', apellido: 'López', energia: 85, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: '');
      await box.add(usuario);
      await box.flush();

      // Leer
      final recuperado = box.getAt(0);
      expect(recuperado, isNotNull);
      expect(recuperado!.idUsuario, 1);
      expect(recuperado.nombre, 'Carlos');
      expect(recuperado.apellido, 'López');
      expect(recuperado.energia, 85);

      // Actualizar
      recuperado.nombre = 'Ana';
      recuperado.energia = 42;
      await box.putAt(0, recuperado);
      await box.flush();

      final actualizado = box.getAt(0);
      expect(actualizado!.nombre, 'Ana');
      expect(actualizado.energia, 42);

      // Eliminar
      await box.deleteAt(0);
      await box.flush();
      expect(box.length, 0);

      await box.close();
    });

    test('valores extremos – energía al límite', () async {
      final box = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
      await box.add(Usuario(idUsuario: 2, nombre: 'Test', apellido: '', energia: 0, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: ''));
      await box.add(Usuario(idUsuario: 3, nombre: '', apellido: 'Apellido', energia: 100, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: ''));
      await box.add(Usuario(idUsuario: 4, nombre: testString, apellido: testString, energia: 50, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: ''));
      await box.flush();

      expect(box.getAt(0)!.energia, 0);
      expect(box.getAt(0)!.apellido, '');
      expect(box.getAt(1)!.nombre, '');
      expect(box.getAt(1)!.energia, 100);
      expect(box.getAt(2)!.nombre, testString);

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  CUENTA (typeId 1) – int, String, String, String, int
  // =============================================================
  group('Cuenta', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<Cuenta>(HiveBoxNames.cuenta);

      final cuenta = Cuenta(1, 'juan123', 'passSegura99', 'juan@mail.com', 555123456);
      await box.add(cuenta);
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idUsuario, 1);
      expect(r.nickname, 'juan123');
      expect(r.contrasena, 'passSegura99');
      expect(r.correo, 'juan@mail.com');
      expect(r.telefono, 555123456);

      r.nickname = 'juan_edit';
      r.contrasena = 'nuevaPass!';
      await box.putAt(0, r);
      await box.flush();
      expect(box.getAt(0)!.nickname, 'juan_edit');

      await box.deleteAt(0);
      expect(box.length, 0);
      await box.close();
    });

    test('caracteres especiales en campos de texto', () async {
      final box = await Hive.openBox<Cuenta>(HiveBoxNames.cuenta);
      await box.add(Cuenta(1, testString, testString, 'test@test.com', 0));
      await box.flush();
      expect(box.getAt(0)!.nickname, testString);
      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  HABITO (typeId 2) – int, String, String, String, bool, String, List<String>?
  // =============================================================
  group('Habito', () {
    test('CRUD completo con fechas', () async {
      final box = await Hive.openBox<Habito>(HiveBoxNames.habito);

      final fechas = ['2026-07-01', '2026-07-02', '2026-07-03'];
      final habito = Habito(
        1,
        'Hacer ejercicio',
        'Ejercicio diario',
        'físico|run',
        completadoHoy: true,
        fechaUltimoCompletado: '2026-07-03',
        fechasCompletadas: fechas,
      );
      await box.add(habito);
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idHabito, 1);
      expect(r.nombreHabito, 'Hacer ejercicio');
      expect(r.atributo, 'Ejercicio diario');
      expect(r.tipo, 'físico|run');
      expect(r.completadoHoy, true);
      expect(r.fechaUltimoCompletado, '2026-07-03');
      expect(r.safeFechasCompletadas, fechas);
      expect(r.aspecto, 'físico');
      expect(r.iconoKey, 'run');

      // Actualizar
      r.completadoHoy = false;
      r.fechasCompletadas = [];
      await box.putAt(0, r);
      await box.flush();
      final a = box.getAt(0)!;
      expect(a.completadoHoy, false);
      expect(a.safeFechasCompletadas, []);

      await box.clear();
      await box.close();
    });

    test('lista nula de fechas se maneja como vacía', () async {
      final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
      await box.add(Habito(1, 'Test', '', 'mental|book'));
      await box.flush();
      expect(box.getAt(0)!.safeFechasCompletadas, []);
      await box.clear();
      await box.close();
    });

    test('múltiples hábitos con índices correctos', () async {
      final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
      for (int i = 1; i <= 10; i++) {
        await box.add(Habito(i, 'Habito $i', 'Desc $i', 'físico|run'));
      }
      await box.flush();
      expect(box.length, 10);
      expect(box.getAt(5)!.nombreHabito, 'Habito 6');
      expect(box.getAt(9)!.idHabito, 10);
      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  REGISTRO_HABITO (typeId 3) – int, String, bool, int
  // =============================================================
  group('RegistroHabito', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<RegistroHabito>(HiveBoxNames.registroHabito);

      await box.add(RegistroHabito(1, '2026-07-01', true, 10));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idRegistro, 1);
      expect(r.fecha, '2026-07-01');
      expect(r.completado, true);
      expect(r.impacto, 10);

      r.completado = false;
      await box.putAt(0, r);
      expect(box.getAt(0)!.completado, false);

      await box.deleteAt(0);
      expect(box.length, 0);
      await box.close();
    });
  });

  // =============================================================
  //  TAREA (typeId 4) – int, String, int, String
  // =============================================================
  group('Tarea', () {
    test('CRUD completo con metadata', () async {
      final box = await Hive.openBox<Tarea>(HiveBoxNames.tarea);

      final tarea = Tarea(1, 'Estudiar matemáticas', 50, fecha: '2026-07-15', notas: 'Comprar materiales');
      await box.add(tarea);
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idTarea, 1);
      expect(r.nombreTarea, 'Estudiar matemáticas');
      expect(r.puntaje, 50);
      expect(r.fecha, '2026-07-15');
      expect(r.notas, 'Comprar materiales');

      // Sin metadata
      await box.add(Tarea(2, 'Tarea simple', 0));
      await box.flush();
      final s = box.getAt(1)!;
      expect(s.fecha, '');
      expect(s.notas, '');

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  SESION_POMODORO (typeId 5) – int, String, String, int, bool, String
  // =============================================================
  group('SesionPomodoro', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro);

      await box.add(SesionPomodoro(1, '2026-07-10 10:00', '2026-07-10 10:25', 25, true, 'pomodoro'));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idSesion, 1);
      expect(r.fechaInicio, '2026-07-10 10:00');
      expect(r.fechaFinal, '2026-07-10 10:25');
      expect(r.duracion, 25);
      expect(r.completada, true);
      expect(r.tipoSesion, 'pomodoro');

      // Sesión no completada
      await box.add(SesionPomodoro(2, '2026-07-10 11:00', '2026-07-10 11:10', 10, false, 'descanso'));
      expect(box.getAt(1)!.completada, false);

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  NOTA (typeId 6) – int, String
  // =============================================================
  group('Nota', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<Nota>(HiveBoxNames.nota);

      await box.add(Nota(1, 'Esta es una nota de prueba con acentos: ñáéíóú.'));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idNota, 1);
      expect(r.valor, contains('acentos'));
      expect(r.valor, contains('ñáéíóú'));

      r.valor = 'Nota editada';
      await box.putAt(0, r);
      expect(box.getAt(0)!.valor, 'Nota editada');

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  EVENTO (typeId 7) – int, String, bool
  // =============================================================
  group('Evento', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<Evento>(HiveBoxNames.evento);

      await box.add(Evento(1, '2026-12-25', false));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idEvento, 1);
      expect(r.fechaEvento, '2026-12-25');
      expect(r.finalizado, false);

      r.finalizado = true;
      await box.putAt(0, r);
      expect(box.getAt(0)!.finalizado, true);

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  BACKUP (typeId 8) – int, String, String
  // =============================================================
  group('Backup', () {
    test('CRUD completo', () async {
      final box = await Hive.openBox<Backup>(HiveBoxNames.backup);

      await box.add(Backup(1, '2026-07-10', 'Backup semanal completo'));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idBackup, 1);
      expect(r.fechaBackup, '2026-07-10');
      expect(r.descripcion, 'Backup semanal completo');

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  SESION_ESTUDIO (typeId 9) – int, String, int, int, String, String
  // =============================================================
  group('SesionEstudio', () {
    test('CRUD completo con adapter manual', () async {
      final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);

      await box.add(SesionEstudio(1, 'feynman', 45, 112, '2026-07-10', nota: 'Estudiando física cuántica'));
      await box.flush();

      final r = box.getAt(0)!;
      expect(r.idSesion, 1);
      expect(r.metodo, 'feynman');
      expect(r.duracionMinutos, 45);
      expect(r.puntosObtenidos, 112);
      expect(r.fecha, '2026-07-10');
      expect(r.nota, 'Estudiando física cuántica');

      // Sin nota
      await box.add(SesionEstudio(2, 'pomodoro', 25, 42, '2026-07-10'));
      expect(box.getAt(1)!.nota, '');

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  LOGRO (typeId 10) – String, String (adapter manual)
  // =============================================================
  group('Logro', () {
    test('CRUD completo con adapter manual', () async {
      final box = await Hive.openBox<Logro>(HiveBoxNames.logro);

      await box.add(Logro('primer_paso', '2026-07-01'));
      await box.add(Logro('racha_7', '2026-07-08'));
      await box.add(Logro('estudiante', '2026-07-10'));
      await box.flush();

      expect(box.length, 3);
      expect(box.getAt(0)!.idLogro, 'primer_paso');
      expect(box.getAt(0)!.fechaDesbloqueo, '2026-07-01');
      expect(box.getAt(2)!.idLogro, 'estudiante');

      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  RACHA (typeId 11) – int, String, int, String, bool, String, String? (adapter manual)
  // =============================================================
  group('Racha', () {
    test('CRUD completo con adapter manual', () async {
      final box = await Hive.openBox<Racha>(HiveBoxNames.racha);

      final rachaDiaria = Racha(
        idRacha: 1,
        tipo: 'diaria',
        cantidad: 5,
        fechaUltimoCompletado: '2026-07-10',
      );
      await box.put(1, rachaDiaria);
      await box.flush();

      final r1 = box.get(1)!;
      expect(r1.idRacha, 1);
      expect(r1.tipo, 'diaria');
      expect(r1.cantidad, 5);
      expect(r1.fechaUltimoCompletado, '2026-07-10');
      expect(r1.enRiesgo, false);
      expect(r1.fechaInicioPeriodoRecuperacion, '');
      expect(r1.fechaCreacion, isNull);

      // Racha semanal en riesgo
      final rachaSemanal = Racha(
        idRacha: 2,
        tipo: 'semanal',
        cantidad: 3,
        fechaUltimoCompletado: '2026-07-06',
        enRiesgo: true,
        fechaInicioPeriodoRecuperacion: '2026-07-07',
        fechaCreacion: '2026-06-15',
      );
      await box.put(2, rachaSemanal);
      await box.flush();

      final r2 = box.get(2)!;
      expect(r2.idRacha, 2);
      expect(r2.tipo, 'semanal');
      expect(r2.cantidad, 3);
      expect(r2.enRiesgo, true);
      expect(r2.fechaInicioPeriodoRecuperacion, '2026-07-07');
      expect(r2.fechaCreacion, '2026-06-15');

      // copyWith
      final actualizada = r2.copyWith(cantidad: 4, enRiesgo: false);
      await box.put(2, actualizada);
      expect(box.get(2)!.cantidad, 4);
      expect(box.get(2)!.enRiesgo, false);

      await box.flush();
      await box.clear();
      await box.close();
    });
  });

  // =============================================================
  //  PERSISTENCIA – cierre y reapertura de todas las cajas
  // =============================================================
  group('Persistence across close/reopen', () {
    test('todos los datos sobreviven al cierre y reapertura', () async {
      // --- Insertar datos ---
      final uBox = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
      await uBox.add(Usuario(idUsuario: 1, nombre: 'Persistencia', apellido: 'Test', energia: 77, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: ''));
      await uBox.flush();
      await uBox.close();

      final hBox = await Hive.openBox<Habito>(HiveBoxNames.habito);
      await hBox.add(Habito(1, 'Hábito persistente', '', 'físico|gym', fechasCompletadas: ['2026-07-01', '2026-07-02']));
      await hBox.flush();
      await hBox.close();

      final rBox = await Hive.openBox<Racha>(HiveBoxNames.racha);
      await rBox.put(1, Racha(idRacha: 1, tipo: 'diaria', cantidad: 10, fechaUltimoCompletado: '2026-07-10'));
      await rBox.flush();
      await rBox.close();

      final tBox = await Hive.openBox<Tarea>(HiveBoxNames.tarea);
      await tBox.add(Tarea(1, 'Tarea persistente', 30, fecha: '2026-07-10'));
      await tBox.flush();
      await tBox.close();

      final lBox = await Hive.openBox<Logro>(HiveBoxNames.logro);
      await lBox.add(Logro('primer_paso', '2026-07-01'));
      await lBox.flush();
      await lBox.close();

      final pBox = await Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro);
      await pBox.add(SesionPomodoro(1, '10:00', '10:25', 25, true, 'pomodoro'));
      await pBox.flush();
      await pBox.close();

      // --- Cerrar todo y reinicializar ---
      await Hive.close();
      await HiveInitializer.initForTesting(tempDir.path);

      // --- Verificar que los datos persisten ---
      final uBox2 = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
      expect(uBox2.length, 1);
      expect(uBox2.getAt(0)!.nombre, 'Persistencia');
      expect(uBox2.getAt(0)!.energia, 77);
      await uBox2.close();

      final hBox2 = await Hive.openBox<Habito>(HiveBoxNames.habito);
      expect(hBox2.length, 1);
      expect(hBox2.getAt(0)!.nombreHabito, 'Hábito persistente');
      expect(hBox2.getAt(0)!.safeFechasCompletadas.length, 2);
      await hBox2.close();

      final rBox2 = await Hive.openBox<Racha>(HiveBoxNames.racha);
      expect(rBox2.length, 1);
      expect(rBox2.get(1)!.cantidad, 10);
      await rBox2.close();

      final tBox2 = await Hive.openBox<Tarea>(HiveBoxNames.tarea);
      expect(tBox2.length, 1);
      expect(tBox2.getAt(0)!.nombreTarea, 'Tarea persistente');
      expect(tBox2.getAt(0)!.fecha, '2026-07-10');
      await tBox2.close();

      final lBox2 = await Hive.openBox<Logro>(HiveBoxNames.logro);
      expect(lBox2.length, 1);
      expect(lBox2.getAt(0)!.idLogro, 'primer_paso');
      await lBox2.close();

      final pBox2 = await Hive.openBox<SesionPomodoro>(HiveBoxNames.sesionPomodoro);
      expect(pBox2.length, 1);
      expect(pBox2.getAt(0)!.duracion, 25);
      await pBox2.close();
    });

    test('caja de usuario con energía 0 y valores vacíos persiste', () async {
      final box = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
      await box.put(99, Usuario(idUsuario: 99, nombre: '', apellido: '', energia: 0, energiaMax: 100, puntosProductividad: 0, estadoPersonaje: '', fechaInicio: ''));
      await box.flush();
      await box.close();

      await Hive.close();
      await HiveInitializer.initForTesting(tempDir.path);

      final box2 = await Hive.openBox<Usuario>(HiveBoxNames.usuario);
      final r = box2.get(99)!;
      expect(r.nombre, '');
      expect(r.apellido, '');
      expect(r.energia, 0);
      await box2.close();
    });
  });
}
