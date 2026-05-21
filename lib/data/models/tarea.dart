
import 'package:hive/hive.dart';

part 'tarea.g.dart';

@HiveType(typeId: 4)
class Tarea {

  @HiveField(0)
  int idTarea;

  @HiveField(1)
  String nombreTarea;

  @HiveField(2)
  int puntaje;

  Tarea(
    this.idTarea,
    this.nombreTarea,
    this.puntaje,
  );
}