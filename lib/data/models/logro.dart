import 'package:hive/hive.dart';

@HiveType(typeId: 10)
class Logro {
  @HiveField(0)
  String idLogro;

  @HiveField(1)
  String fechaDesbloqueo;

  Logro(this.idLogro, this.fechaDesbloqueo);
}

class LogroAdapter extends TypeAdapter<Logro> {
  @override
  final int typeId = 10;

  @override
  Logro read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Logro(fields[0] as String, fields[1] as String);
  }

  @override
  void write(BinaryWriter writer, Logro obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.idLogro)
      ..writeByte(1)
      ..write(obj.fechaDesbloqueo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogroAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
