// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'solve_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SolveResult _$SolveResultFromJson(Map<String, dynamic> json) => SolveResult(
  solution: json['solution'] as String?,
  finalResult: json['final_result'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$SolveResultToJson(SolveResult instance) =>
    <String, dynamic>{
      'solution': instance.solution,
      'final_result': instance.finalResult,
      'error': instance.error,
    };
