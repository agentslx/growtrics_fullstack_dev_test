
import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../../entities/solve_request/solve_result.dart';

class SolvingItem extends Equatable {
  const SolvingItem({
    required this.id,
    required this.image,
    this.isSubmitting = false,
    this.errorMessage,
    this.results = const <SolveResult>[],
  });

  final String id;
  final File image;
  final bool isSubmitting;
  final String? errorMessage;
  final List<SolveResult> results;

  SolvingItem copyWith({
    File? image,
    bool? isSubmitting,
    String? errorMessage,
    List<SolveResult>? results,
  }) => SolvingItem(
        id: id,
        image: image ?? this.image,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
        results: results ?? this.results,
      );

  @override
  List<Object?> get props => [id, image.path, isSubmitting, errorMessage, results];
}

class SolvingSessionState extends Equatable {
  const SolvingSessionState({this.items = const <SolvingItem>[]});

  final List<SolvingItem> items;

  SolvingSessionState copyWith({List<SolvingItem>? items}) =>
      SolvingSessionState(items: items ?? this.items);

  @override
  List<Object?> get props => [items];
}

