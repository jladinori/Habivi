import 'package:flutter_test/flutter_test.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';
import 'package:habivi/domain/services/energy_service.dart';

GamificationStats stats({
  int totalCompletados = 0,
  int racha = 0,
  int habitosHoy = 0,
  int totalHabitos = 0,
  int sesionesEstudio = 0,
  int puntosEstudio = 0,
  EnergiaAtributos atributos = const EnergiaAtributos(cuerpo: 0, mente: 0, alma: 0),
}) {
  return GamificationStats(
    totalCompletados: totalCompletados,
    racha: racha,
    habitosHoy: habitosHoy,
    totalHabitos: totalHabitos,
    sesionesEstudio: sesionesEstudio,
    puntosEstudio: puntosEstudio,
    atributos: atributos,
  );
}

AchievementDef byId(String id) => achievementCatalog.firstWhere((d) => d.id == id);

void main() {
  test('el catalogo tiene ids unicos', () {
    final ids = achievementCatalog.map((d) => d.id).toSet();
    expect(ids.length, achievementCatalog.length);
  });

  test('primer_paso se cumple con 1 completado', () {
    expect(byId('primer_paso').condicion(stats(totalCompletados: 1)), isTrue);
    expect(byId('primer_paso').condicion(stats()), isFalse);
  });

  test('rachas se cumplen en sus umbrales', () {
    expect(byId('racha_3').condicion(stats(racha: 3)), isTrue);
    expect(byId('racha_3').condicion(stats(racha: 2)), isFalse);
    expect(byId('racha_7').condicion(stats(racha: 7)), isTrue);
    expect(byId('racha_30').condicion(stats(racha: 30)), isTrue);
  });

  test('dia_perfecto requiere todos los habitos completados hoy', () {
    expect(byId('dia_perfecto').condicion(stats(totalHabitos: 3, habitosHoy: 3)), isTrue);
    expect(byId('dia_perfecto').condicion(stats(totalHabitos: 3, habitosHoy: 2)), isFalse);
    expect(byId('dia_perfecto').condicion(stats()), isFalse);
  });

  test('equilibrio_total exige los 3 atributos activos y >= 70', () {
    const bien = EnergiaAtributos(cuerpo: 75, mente: 80, alma: 70);
    const unoFlojo = EnergiaAtributos(cuerpo: 75, mente: 80, alma: 60);
    const sinAlma = EnergiaAtributos(cuerpo: 90, mente: 90, alma: 0, tieneAlma: false);
    expect(byId('equilibrio_total').condicion(stats(atributos: bien)), isTrue);
    expect(byId('equilibrio_total').condicion(stats(atributos: unoFlojo)), isFalse);
    expect(byId('equilibrio_total').condicion(stats(atributos: sinAlma)), isFalse);
  });

  test('estudiante y sabio_500 usan las stats de estudio', () {
    expect(byId('estudiante').condicion(stats(sesionesEstudio: 1)), isTrue);
    expect(byId('sabio_500').condicion(stats(puntosEstudio: 500)), isTrue);
    expect(byId('sabio_500').condicion(stats(puntosEstudio: 499)), isFalse);
  });
}
