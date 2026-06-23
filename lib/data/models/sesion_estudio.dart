import 'package:hive/hive.dart';

@HiveType(typeId: 9)
class SesionEstudio {
  @HiveField(0)
  int idSesion;

  @HiveField(1)
  String metodo;

  @HiveField(2)
  int duracionMinutos;

  @HiveField(3)
  int puntosObtenidos;

  @HiveField(4)
  String fecha;

  @HiveField(5)
  String nota;

  SesionEstudio(
    this.idSesion,
    this.metodo,
    this.duracionMinutos,
    this.puntosObtenidos,
    this.fecha, {
    this.nota = '',
  });
}

class SesionEstudioAdapter extends TypeAdapter<SesionEstudio> {
  @override
  final int typeId = 9;

  @override
  SesionEstudio read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SesionEstudio(
      fields[0] as int,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
      fields[4] as String,
      nota: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, SesionEstudio obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.idSesion)
      ..writeByte(1)
      ..write(obj.metodo)
      ..writeByte(2)
      ..write(obj.duracionMinutos)
      ..writeByte(3)
      ..write(obj.puntosObtenidos)
      ..writeByte(4)
      ..write(obj.fecha)
      ..writeByte(5)
      ..write(obj.nota);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionEstudioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
