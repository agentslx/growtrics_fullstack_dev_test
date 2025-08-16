import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_solver_flutter/features/auth/services/user_service.dart';

import '../../../../di.dart';
import '../../data/repository/solving_repository.dart';
import 'solving_session_state.dart';

class SolvingSessionCubit extends Cubit<SolvingSessionState> {
  SolvingSessionCubit() : super(const SolvingSessionState()) {
    _init();
  }

  final SolvingRepository _repo = getIt<SolvingRepository>();

  void _init() {
    getIt<UserService>().registerLogoutListener(() {
      emit(state.copyWith(items: []));
    });
  }

  Future<void> addImageAndSubmit(File image) async {
    // Add item as submitting
    final newItem = SolvingItem(id: DateTime.now().millisecondsSinceEpoch.toString(), image: image, isSubmitting: true);
    final items = [newItem, ...state.items];
    emit(state.copyWith(items: items));
    final res = await _repo.submitSolveImage(image: image);
    res.fold(
      (failure) {
        final updated = [...state.items];
        final index = updated.indexWhere((item) => item.id == newItem.id);
        updated[index] = updated[index].copyWith(isSubmitting: false, errorMessage: failure.message);
        emit(state.copyWith(items: updated));
      },
      (req) {
        final updated = [...state.items];
        final index = updated.indexWhere((item) => item.id == newItem.id);

        // Root-level error
        if (req.error != null && req.error!.isNotEmpty) {
          updated[index] = updated[index].copyWith(isSubmitting: false, errorMessage: req.error);
        } else {
          if (req.results.isEmpty) {
            updated[index] = updated[index].copyWith(isSubmitting: false, errorMessage: 'solving.no_results');
          } else {
            updated[index] = updated[index].copyWith(isSubmitting: false, results: req.results, errorMessage: null);
          }
        }
        emit(state.copyWith(items: updated));
      },
    );
  }

  Future<void> retryItem(SolvingItem item) async {
    final index = state.items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;

    // Remove the item from the list
    final updatedItems = List<SolvingItem>.from(state.items);
    updatedItems.removeAt(index);
    emit(state.copyWith(items: updatedItems));

    // Retry submission
    await addImageAndSubmit(item.image);
  }

  void removeItem(SolvingItem item) {
    final index = state.items.indexOf(item);
    if (index == -1) return;

    // Remove the item from the list
    final updatedItems = List<SolvingItem>.from(state.items);
    updatedItems.removeAt(index);
    emit(state.copyWith(items: updatedItems));
  }
}
