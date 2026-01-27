// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 0;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Challenge(
      id: fields[0] as String,
      name: fields[1] as String,
      packId: fields[2] as String,
      startDateUtc: fields[3] as int,
      completionDatesUtc: (fields[4] as List?)?.cast<int>(),
      reminderTimeMinutes: fields[5] as int?,
      isStreakFrozen: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.packId)
      ..writeByte(3)
      ..write(obj.startDateUtc)
      ..writeByte(4)
      ..write(obj.completionDatesUtc)
      ..writeByte(5)
      ..write(obj.reminderTimeMinutes)
      ..writeByte(6)
      ..write(obj.isStreakFrozen);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
