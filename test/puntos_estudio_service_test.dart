import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/domain/services/puntos_estudio_service.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_estudio_test');
    await HiveInitializer.initForTesting(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('MetodosEstudio', () {
    test('tiene 7 métodos predefinidos', () {
      expect(EstudioService.metodos.length, equals(7));
    });

    test('cada método tiene id único y nombre no vacío', () {
      final ids = EstudioService.metodos.map((m) => m.id).toSet();
      expect(ids.length, equals(EstudioService.metodos.length));
      for (final m in EstudioService.metodos) {
        expect(m.nombre.isNotEmpty, isTrue);
        expect(m.descripcion.isNotEmpty, isTrue);
      }
    });

    test('buscarMetodo retorna el método correcto', () {
      final metodo = EstudioService.buscarMetodo('feynman');
      expect(metodo, isNotNull);
      expect(metodo!.nombre, equals('Técnica Feynman'));
    });

    test('buscarMetodo retorna null para id inexistente', () {
      final metodo = EstudioService.buscarMetodo('inexistente');
      expect(metodo, isNull);
    });
  });

  group('calcularMinutos', () {
    test('calcula minutos para 60 minutos exactos', () {
      final minutos = EstudioService.calcularMinutos('pomodoro', 60);
      expect(minutos, equals(60));
    });

    test('calcula minutos para 30 minutos (mitad)', () {
      final minutos = EstudioService.calcularMinutos('pomodoro', 30);
      expect(minutos, equals(30));
    });

    test('retorna 0 para 0 minutos', () {
      final minutos = EstudioService.calcularMinutos('pomodoro', 0);
      expect(minutos, equals(0));
    });

    test('Feynman retorna los mismos minutos que Pomodoro al mismo tiempo', () {
      final pomodoro = EstudioService.calcularMinutos('pomodoro', 60);
      final feynman = EstudioService.calcularMinutos('feynman', 60);
      expect(feynman, equals(pomodoro));
    });
  });

  group('minutosDeHoy', () {
    test('retorna 0 cuando no hay sesiones', () async {
      final box = await Hive.openBox<SesionEstudio>('testMinutosHoy');
      await box.clear();
      await box.close();

      final minutos = await EstudioService.minutosDeHoy();
      expect(minutos, equals(0));
    });
  });
}
