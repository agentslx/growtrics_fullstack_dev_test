// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solve_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolveRequest _$SolveRequestFromJson(Map<String, dynamic> json) => SolveRequest(
  requestId: json['request_id'] as String,
  status: json['status'] as String,
  error: json['error'] as String?,
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => SolveResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$SolveRequestToJson(SolveRequest instance) =>
    <String, dynamic>{
      'request_id': instance.requestId,
      'status': instance.status,
      'error': instance.error,
      'results': instance.results,
    };
