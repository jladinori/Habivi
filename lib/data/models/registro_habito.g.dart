// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'registro_habito.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RegistroHabitoAdapter extends TypeAdapter<RegistroHabito> {
  @override
  final int typeId = 3;

  @override
  RegistroHabito read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RegistroHabito(
      fields[0] as int,
      fields[1] as String,
      fields[2] as bool,
      fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, RegistroHabito obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.idRegistro)
      ..writeByte(1)
      ..write(obj.fecha)
      ..writeByte(2)
      ..write(obj.completado)
      ..writeByte(3)
      ..write(obj.impacto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegistroHabitoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
