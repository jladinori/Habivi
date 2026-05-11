
import 'package:hive/hive.dart';

part 'sesion_pomodoro.g.dart';

@HiveType(typeId: 5)
class SesionPomodoro {

  @HiveField(0)
  int idSesion;

  @HiveField(1)
  String fechaInicio;

  @HiveField(2)
  String fechaFinal;

  @HiveField(3)
  int duracion;

  @HiveField(4)
  bool completada;

  @HiveField(5)
  String tipoSesion;

  SesionPomodoro(
    this.idSesion,
    this.fechaInicio,
    this.fechaFinal,
    this.duracion,
    this.completada,
    this.tipoSesion,
  );
}