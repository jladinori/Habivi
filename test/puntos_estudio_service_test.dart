import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:habivi/core/hive/hive_initializer.dart';
import 'package:habivi/domain/services/puntos_estudio_service.dart';
import 'package:habivi/data/models/sesion_estudio.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('habivi_puntos_test');
    await HiveInitializer.initForTesting(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('MetodosEstudio', () {
    test('tiene 8 métodos predefinidos', () {
      expect(PuntosEstudioService.metodos.length, equals(8));
    });

    test('cada método tiene id único y nombre no vacío', () {
      final ids = PuntosEstudioService.metodos.map((m) => m.id).toSet();
      expect(ids.length, equals(PuntosEstudioService.metodos.length));
      for (final m in PuntosEstudioService.metodos) {
        expect(m.nombre.isNotEmpty, isTrue);
        expect(m.descripcion.isNotEmpty, isTrue);
        expect(m.puntosBasePorHora, greaterThan(0));
      }
    });

    test('buscarMetodo retorna el método correcto', () {
      final metodo = PuntosEstudioService.buscarMetodo('feynman');
      expect(metodo, isNotNull);
      expect(metodo!.nombre, equals('Técnica Feynman'));
    });

    test('buscarMetodo retorna null para id inexistente', () {
      final metodo = PuntosEstudioService.buscarMetodo('inexistente');
      expect(metodo, isNull);
    });
  });

  group('calcularPuntos', () {
    test('calcula puntos para 60 minutos exactos', () {
      final puntos = PuntosEstudioService.calcularPuntos('pomodoro', 60);
      expect(puntos, equals(100));
    });

    test('calcula puntos para 30 minutos (mitad)', () {
      final puntos = PuntosEstudioService.calcularPuntos('pomodoro', 30);
      expect(puntos, equals(50));
    });

    test('retorna 0 para método inexistente', () {
      final puntos = PuntosEstudioService.calcularPuntos('inexistente', 60);
      expect(puntos, equals(0));
    });

    test('Feynman da más puntos que Pomodoro al mismo tiempo', () {
      final pomodoro = PuntosEstudioService.calcularPuntos('pomodoro', 60);
      final feynman = PuntosEstudioService.calcularPuntos('feynman', 60);
      expect(feynman, greaterThan(pomodoro));
    });
  });

  group('puntosDeHoy', () {
    test('retorna 0 cuando no hay sesiones', () async {
      final box = await Hive.openBox<SesionEstudio>('testPuntosHoy');
      await box.clear();
      await box.close();

      final puntos = await PuntosEstudioService.puntosDeHoy();
      expect(puntos, equals(0));
    });
  });
}
