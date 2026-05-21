// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nota.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotaAdapter extends TypeAdapter<Nota> {
  @override
  final int typeId = 6;

  @override
  Nota read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Nota(
      fields[0] as int,
      fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Nota obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.idNota)
      ..writeByte(1)
      ..write(obj.valor);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
