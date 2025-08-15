// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'failure.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Failure _$FailureFromJson(Map<String, dynamic> json) => Failure(
  message: json['message'] as String,
  code: (json['code'] as num?)?.toInt(),
  data: json['data'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$FailureToJson(Failure instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
