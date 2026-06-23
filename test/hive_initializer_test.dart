import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_hive_test');
    await HiveInitializer.initForTesting(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Hive abre la caja de hábitos', () async {
    final box = await Hive.openBox<Habito>(HiveBoxNames.habito);
    expect(box.isOpen, isTrue);
    await box.close();
  });

  test('Hive abre la caja de sesiones de estudio', () async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);
    expect(box.isOpen, isTrue);
    await box.close();
  });

  test('SesionEstudio se guarda y recupera correctamente', () async {
    final box = await Hive.openBox<SesionEstudio>(HiveBoxNames.sesionEstudio);

    final sesion = SesionEstudio(
      1,
      'pomodoro',
      25,
      100,
      '2026-06-22',
      nota: 'Sesión de prueba',
    );
    await box.add(sesion);
    await box.flush();

    final recuperado = box.getAt(0);
    expect(recuperado, isNotNull);
    expect(recuperado!.idSesion, equals(1));
    expect(recuperado.metodo, equals('pomodoro'));
    expect(recuperado.duracionMinutos, equals(25));
    expect(recuperado.puntosObtenidos, equals(100));
    expect(recuperado.fecha, equals('2026-06-22'));
    expect(recuperado.nota, equals('Sesión de prueba'));

    await box.clear();
    await box.flush();
    await box.close();
  });
}
