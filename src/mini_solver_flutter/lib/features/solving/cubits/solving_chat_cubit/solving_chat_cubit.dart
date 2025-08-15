import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../../../entities/solve_request/solve_result.dart' as entity;
import '../../data/repository/solving_repository.dart';
import 'solving_chat_state.dart';

class SolvingChatCubit extends Cubit<SolvingChatState> {
  SolvingChatCubit({File? initialImage}) : super(const SolvingChatState()) {
    if (initialImage != null) {
      emit(SolvingChatState(items: [...state.items, ChatItem(image: initialImage, isMe: true)]));
      _submitImage(initialImage);
    }
  }

  final SolvingRepository _repo = getIt<SolvingRepository>();

  Future<void> _submitImage(File image) async {
    if (state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true, errorMessage: null));
    final res = await _repo.submitSolveImage(image: image);
    res.fold(
      (failure) {
        emit(state.copyWith(isSubmitting: false, errorMessage: failure.message));
      },
      (req) {
        // Root-level error from API
        if (req.error != null && req.error!.isNotEmpty) {
          emit(state.copyWith(isSubmitting: false, errorMessage: req.error));
          return;
        }
        final results = req.results;
        if (results.isEmpty) {
          emit(state.copyWith(isSubmitting: false, errorMessage: 'No result returned'));
          return;
        }
        // If any result has error, show first error as snackbar
        final firstError = results.firstWhere(
          (r) => (r.error != null && r.error!.isNotEmpty),
          orElse: () => const entity.SolveResult(),
        );
        if (firstError.error != null && firstError.error!.isNotEmpty) {
          emit(state.copyWith(isSubmitting: false, errorMessage: firstError.error));
          return;
        }
        emit(
          state.copyWith(
            isSubmitting: false,
            items: [...state.items, ChatItem(results: results, isMe: false)],
          ),
        );
      },
    );
  }

  void addUserText(String text) {
    if (text.trim().isEmpty) return;
    emit(state.copyWith(items: [...state.items, ChatItem(text: text, isMe: true)]));
  }

  void addAiText(String text) {
    emit(state.copyWith(items: [...state.items, ChatItem(text: text, isMe: false)]));
  }
}
