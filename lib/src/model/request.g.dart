// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RequestAdapter extends TypeAdapter<Request> {
  @override
  final int typeId = 999;

  @override
  Request read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Request(
      url: fields[0] as String,
      data: (fields[1] as Map?)?.cast<String, dynamic>(),
      queryParameters: (fields[2] as Map?)?.cast<String, dynamic>(),
      headers: (fields[3] as Map?)?.cast<String, String>(),
      httpMethod: fields[4] as HttpMethod,
    );
  }

  @override
  void write(BinaryWriter writer, Request obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.queryParameters)
      ..writeByte(3)
      ..write(obj.headers)
      ..writeByte(4)
      ..write(obj.httpMethod);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
