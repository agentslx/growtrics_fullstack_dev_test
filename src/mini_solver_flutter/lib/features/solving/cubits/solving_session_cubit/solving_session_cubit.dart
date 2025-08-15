
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di.dart';
import '../../data/repository/solving_repository.dart';
import 'solving_session_state.dart';

class SolvingSessionCubit extends Cubit<SolvingSessionState> {
  SolvingSessionCubit() : super(const SolvingSessionState());

  final SolvingRepository _repo = getIt<SolvingRepository>();

  Future<void> addImageAndSubmit(File image, {String? prompt}) async {
    // Add item as submitting
    final newItem = SolvingItem(image: image, isSubmitting: true);
    final items = [...state.items, newItem];
    emit(state.copyWith(items: items));
    final index = items.length - 1;

    final res = await _repo.submitSolveImage(image: image, prompt: prompt);
    res.fold(
      (failure) {
        final updated = [...state.items];
        updated[index] = updated[index].copyWith(isSubmitting: false, errorMessage: failure.message);
        emit(state.copyWith(items: updated));
      },
      (req) {
        final updated = [...state.items];
        // Root-level error
        if (req.error != null && req.error!.isNotEmpty) {
          updated[index] = updated[index].copyWith(isSubmitting: false, errorMessage: req.error);
        } else {
          updated[index] = updated[index].copyWith(isSubmitting: false, results: req.results, errorMessage: null);
        }
        emit(state.copyWith(items: updated));
      },
    );
  }
}

