
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'solve_result.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SolveResult extends Equatable {
  const SolveResult({this.solution, this.finalResult, this.error});

  factory SolveResult.fromJson(Map<String, dynamic> json) => _$SolveResultFromJson(json);

  final String? solution;
  final String? finalResult;
  final String? error;

  Map<String, dynamic> toJson() => _$SolveResultToJson(this);

  @override
  List<Object?> get props => [solution, finalResult, error];
}
