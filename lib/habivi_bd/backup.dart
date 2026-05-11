
import 'package:hive/hive.dart';

part 'backup.g.dart';

@HiveType(typeId: 8)
class Backup {

  @HiveField(0)
  int idBackup;

  @HiveField(1)
  String fechaBackup;

  @HiveField(2)
  String descripcion;

  Backup(
    this.idBackup,
    this.fechaBackup,
    this.descripcion,
  );
}