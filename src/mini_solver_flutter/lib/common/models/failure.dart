import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'failure.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Failure extends Equatable {
  const Failure({
    required this.message,
    this.code,
    this.data,
  });

  factory Failure.fromJson(Map<String, dynamic> json) => _$FailureFromJson(json);

  final int? code;
  final String message;
  final Map<String, dynamic>? data;

  @override
  List<Object?> get props => [message];

  Map<String, dynamic> toJson() => _$FailureToJson(this);
}
