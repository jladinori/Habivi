
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

  Habito(
    this.idHabito,
    this.nombreHabito,
    this.atributo,
    this.tipo, {
    this.completadoHoy = false,
    this.fechaUltimoCompletado = '',
  });
}