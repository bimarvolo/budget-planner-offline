// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserMetadataAdapter extends TypeAdapter<UserMetadata> {
  @override
  final int typeId = 4;

  @override
  UserMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserMetadata()
      ..currency = fields[0] as String
      ..lang = fields[1] as String
      ..theme = fields[2] as String
      ..currentBudget = fields[3] as int;
  }

  @override
  void write(BinaryWriter writer, UserMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currency)
      ..writeByte(1)
      ..write(obj.lang)
      ..writeByte(2)
      ..write(obj.theme)
      ..writeByte(3)
      ..write(obj.currentBudget);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
