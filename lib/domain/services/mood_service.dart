import 'package:habivi/domain/enums/character_mood.dart';
import 'package:habivi/domain/services/energy_service.dart';

class MoodService {
  Future<CharacterMood> calculate() async {
    final energia = await EnergyService.calculate();
    final atributos = await EnergyService.calculatePorAtributo();
    final diasSin = await EnergyService.diasSinActividad();
    return calculateFrom(energia: energia, atributos: atributos, diasSinActividad: diasSin);
  }

  static CharacterMood calculateFrom({
    required int energia,
    required EnergiaAtributos atributos,
    required int diasSinActividad,
  }) {
    if (diasSinActividad >= 2) return CharacterMood.apagado;
    if (energia < 30) return CharacterMood.triste;
    if (atributos.estaDesbalanceada) return CharacterMood.frustrado;
    if (energia >= 70) return CharacterMood.feliz;
    return CharacterMood.sonoliento;
  }
}
