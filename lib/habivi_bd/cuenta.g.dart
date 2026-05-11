// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cuenta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CuentaAdapter extends TypeAdapter<Cuenta> {
  @override
  final int typeId = 1;

  @override
  Cuenta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cuenta(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Cuenta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.idUsuario)
      ..writeByte(1)
      ..write(obj.nickname)
      ..writeByte(2)
      ..write(obj.contrasena)
      ..writeByte(3)
      ..write(obj.correo)
      ..writeByte(4)
      ..write(obj.telefono);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CuentaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
