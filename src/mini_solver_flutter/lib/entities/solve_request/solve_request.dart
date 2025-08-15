import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'solve_result.dart';

part 'solve_request.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SolveRequest extends Equatable {
  const SolveRequest({
    required this.requestId,
    required this.status,
    this.error,
    this.results = const [],
  });

  factory SolveRequest.fromJson(Map<String, dynamic> json) => _$SolveRequestFromJson(json);

  final String requestId;
  final String status;
  final String? error;
  final List<SolveResult> results;

  Map<String, dynamic> toJson() => _$SolveRequestToJson(this);

  @override
  List<Object?> get props => [requestId, status, error, results];
}
