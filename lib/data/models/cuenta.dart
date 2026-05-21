
import 'package:hive/hive.dart';

part 'cuenta.g.dart';

@HiveType(typeId: 1)
class Cuenta{

  @HiveField(0)
  int idUsuario;

  @HiveField(1)
  String nickname;

  @HiveField(2)
  String contrasena;

  @HiveField(3)
  String correo;

  @HiveField(4)
  int telefono;

  Cuenta(
    this.idUsuario,
    this.nickname,
    this.contrasena,
    this.correo,
    this.telefono
  );
}

