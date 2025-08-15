import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubits/solving_session_cubit/solving_session_cubit.dart';
import '../../cubits/solving_session_cubit/solving_session_state.dart';
import '../widgets/result_bubble.dart';
import 'solving_capture_page.dart';

class SolvingMainPage extends StatelessWidget {
  const SolvingMainPage({super.key});

  Future<void> _openCaptureAndSubmit(BuildContext context) async {
    final file = await Navigator.of(context).push<File?> (
      MaterialPageRoute(builder: (_) => const SolvingCapturePage()),
    );
    if (file != null) {
      // ignore: use_build_context_synchronously
      context.read<SolvingSessionCubit>().addImageAndSubmit(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SolvingSessionCubit(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Solve')),
          body: BlocBuilder<SolvingSessionCubit, SolvingSessionState>(
            builder: (context, state) {
              if (state.items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_camera, size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text('No solves yet', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Tap the + button to capture a problem and see results here.',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              item.image,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (item.isSubmitting) const LinearProgressIndicator(minHeight: 2),
                          if (item.errorMessage != null && item.errorMessage!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                item.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w500),
                              ),
                            ),
                          if (!item.isSubmitting && item.results.isNotEmpty) ...[
                            for (final r in item.results) ...[
                              ResultBubble(result: r),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCaptureAndSubmit(context),
            child: const Icon(Icons.add_a_photo_outlined),
          ),
        ),
      ),
    );
  }
}
