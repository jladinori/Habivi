import 'package:hive/hive.dart';

part 'usuario.g.dart';

@HiveType(typeId: 0)
class Usuario {

  @HiveField(0)
  int idUsuario;

  @HiveField(1)
  String nombre;

  @HiveField(2)
  String apellido;

  @HiveField(3)
  int energia;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.energia,
  });
}