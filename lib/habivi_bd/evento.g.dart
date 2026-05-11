// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evento.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventoAdapter extends TypeAdapter<Evento> {
  @override
  final int typeId = 7;

  @override
  Evento read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Evento(
      fields[0] as int,
      fields[1] as String,
      fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Evento obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.idEvento)
      ..writeByte(1)
      ..write(obj.fechaEvento)
      ..writeByte(2)
      ..write(obj.finalizado);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
