import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../../entities/solve_request/solve_result.dart' as entity;

class ChatItem extends Equatable {
  const ChatItem({this.text, this.image, this.results, required this.isMe});

  final String? text;
  final File? image;
  final List<entity.SolveResult>? results;
  final bool isMe;

  bool get hasResults => results != null && results!.isNotEmpty;

  @override
  List<Object?> get props => [text, image?.path, results, isMe];
}

class SolvingChatState extends Equatable {
  const SolvingChatState({this.items = const [], this.isSubmitting = false, this.errorMessage});

  final List<ChatItem> items;
  final bool isSubmitting;
  final String? errorMessage;

  SolvingChatState copyWith({List<ChatItem>? items, bool? isSubmitting, String? errorMessage}) =>
      SolvingChatState(
        items: items ?? this.items,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [items, isSubmitting, errorMessage];
}
