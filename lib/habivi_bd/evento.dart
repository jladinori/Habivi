
import 'package:hive/hive.dart';

part 'evento.g.dart';

@HiveType(typeId: 7)
class Evento {

  @HiveField(0)
  int idEvento;

  @HiveField(1)
  String fechaEvento;

  @HiveField(2)
  bool finalizado;

  Evento(
    this.idEvento,
    this.fechaEvento,
    this.finalizado,
  );
}