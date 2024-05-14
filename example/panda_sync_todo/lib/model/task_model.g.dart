// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      title: json['title'] as String,
      priority: json['priority'] as String,
      status: (json['status'] as num).toInt(),
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      id: (json['id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'date': instance.date.toIso8601String(),
      'priority': instance.priority,
      'status': instance.status,
    };
