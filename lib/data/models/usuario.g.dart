// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsuarioAdapter extends TypeAdapter<Usuario> {
  @override
  final int typeId = 0;

  @override
  Usuario read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Usuario(
      idUsuario: fields[0] as int,
      nombre: fields[1] as String,
      apellido: fields[2] as String,
      energia: fields[3] as int,
      energiaMax: fields[4] as int? ?? 100,
      puntosProductividad: fields[5] as int? ?? 0,
      estadoPersonaje: fields[6] as String? ?? 'neutral',
      fechaInicio: fields[7] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  @override
  void write(BinaryWriter writer, Usuario obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.idUsuario)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.apellido)
      ..writeByte(3)
      ..write(obj.energia)
      ..writeByte(4)
      ..write(obj.energiaMax)
      ..writeByte(5)
      ..write(obj.puntosProductividad)
      ..writeByte(6)
      ..write(obj.estadoPersonaje)
      ..writeByte(7)
      ..write(obj.fechaInicio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
