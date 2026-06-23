
import 'package:hive/hive.dart';

part 'habito.g.dart';

@HiveType(typeId: 2)
class Habito {

  @HiveField(0)
  int idHabito;

  @HiveField(1)
  String nombreHabito;

  @HiveField(2)
  String atributo;

  @HiveField(3)
  String tipo;

  @HiveField(4)
  bool completadoHoy;

  @HiveField(5)
  String fechaUltimoCompletado;

  @HiveField(6)
  List<String>? fechasCompletadas;

  List<String> get safeFechasCompletadas => fechasCompletadas ?? [];

  String get aspecto {
    if (tipo.contains('|')) {
      return tipo.split('|')[0];
    }
    return 'físico'; // Default aspect
  }

  String get iconoKey {
    if (tipo.contains('|')) {
      final parts = tipo.split('|');
      if (parts.length > 1) return parts[1];
    }
    // Default fallback based on ID
    final defaultKeys = ['spa', 'heart', 'book', 'smoke'];
    return defaultKeys[idHabito % defaultKeys.length];
  }

  set aspecto(String val) {
    tipo = "$val|$iconoKey";
  }

  set iconoKey(String val) {
    tipo = "$aspecto|$val";
  }

  Habito(
    this.idHabito,
    this.nombreHabito,
    this.atributo,
    this.tipo, {
    this.completadoHoy = false,
    this.fechaUltimoCompletado = '',
    List<String>? fechasCompletadas,
  }) : fechasCompletadas = fechasCompletadas ?? [];
}