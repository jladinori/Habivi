
import 'package:hive/hive.dart';

part 'nota.g.dart';

@HiveType(typeId: 6)
class Nota {

  @HiveField(0)
  int idNota;

  @HiveField(1)
  String valor;

  Nota(
    this.idNota,
    this.valor,
  );
}