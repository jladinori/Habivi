
import 'package:hive/hive.dart';

part 'registro_habito.g.dart';

@HiveType(typeId: 3)
class RegistroHabito {

  @HiveField(0)
  int idRegistro;

  @HiveField(1)
  String fecha;

  @HiveField(2)
  bool completado;

  @HiveField(3)
  int impacto;

  RegistroHabito(
    this.idRegistro,
    this.fecha,
    this.completado,
    this.impacto,
  );
}