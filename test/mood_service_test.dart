import 'package:flutter_test/flutter_test.dart';
import 'package:habivi/domain/enums/character_mood.dart';
import 'package:habivi/domain/services/energy_service.dart';
import 'package:habivi/domain/services/mood_service.dart';

void main() {
  group('MoodService.calculateFrom', () {
    const balanceados = EnergiaAtributos(cuerpo: 80, mente: 75, alma: 70);
    const desbalanceados = EnergiaAtributos(cuerpo: 90, mente: 20, alma: 30);

    test('apagado cuando hay 2+ dias sin actividad (gana a todo)', () {
      final mood = MoodService.calculateFrom(energia: 90, atributos: balanceados, diasSinActividad: 2);
      expect(mood, CharacterMood.apagado);
    });

    test('triste cuando la energia es critica (< 30)', () {
      final mood = MoodService.calculateFrom(energia: 29, atributos: balanceados, diasSinActividad: 0);
      expect(mood, CharacterMood.triste);
    });

    test('frustrado cuando los atributos estan desbalanceados', () {
      final mood = MoodService.calculateFrom(energia: 80, atributos: desbalanceados, diasSinActividad: 0);
      expect(mood, CharacterMood.frustrado);
    });

    test('feliz con energia alta y balance', () {
      final mood = MoodService.calculateFrom(energia: 70, atributos: balanceados, diasSinActividad: 0);
      expect(mood, CharacterMood.feliz);
    });

    test('sonoliento con energia moderada', () {
      final mood = MoodService.calculateFrom(energia: 50, atributos: balanceados, diasSinActividad: 0);
      expect(mood, CharacterMood.sonoliento);
    });

    test('triste gana sobre frustrado (energia critica + desbalance)', () {
      final mood = MoodService.calculateFrom(energia: 10, atributos: desbalanceados, diasSinActividad: 0);
      expect(mood, CharacterMood.triste);
    });
  });

  group('EnergiaAtributos', () {
    test('desbalance ignora atributos sin habitos', () {
      const atributos = EnergiaAtributos(cuerpo: 90, mente: 85, alma: 0, tieneAlma: false);
      expect(atributos.desbalance, 5);
      expect(atributos.estaDesbalanceada, isFalse);
    });

    test('con un solo atributo activo nunca hay desbalance', () {
      const atributos = EnergiaAtributos(cuerpo: 100, mente: 0, alma: 0, tieneMente: false, tieneAlma: false);
      expect(atributos.desbalance, 0);
      expect(atributos.estaDesbalanceada, isFalse);
    });

    test('promedio solo cuenta atributos activos', () {
      const atributos = EnergiaAtributos(cuerpo: 80, mente: 40, alma: 0, tieneAlma: false);
      expect(atributos.promedio, 60);
    });
  });
}
