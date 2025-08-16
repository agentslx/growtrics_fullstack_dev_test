import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mini_solver_flutter/generated/colors.gen.dart';

import '../../../../di.dart';
import '../../cubits/solving_session_cubit/solving_session_cubit.dart';
import '../../cubits/solving_session_cubit/solving_session_state.dart';
import '../widgets/solve_request_card.dart';
import 'solving_capture_page.dart';

class SolvingMainPage extends StatefulWidget {
  const SolvingMainPage({super.key});

  @override
  State<SolvingMainPage> createState() => _SolvingMainPageState();
}

class _SolvingMainPageState extends State<SolvingMainPage> {

  final ScrollController _scrollController = ScrollController();

  Future<void> _openCaptureAndSubmit(BuildContext context) async {
    final file = await Navigator.of(context).push<File?>(MaterialPageRoute(builder: (_) => const SolvingCapturePage()));
    if (file != null) {
      _scrollToTop();
      // ignore: use_build_context_synchronously
      await context.read<SolvingSessionCubit>().addImageAndSubmit(file);
    }
  }

  _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SolvingSessionCubit>(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(backgroundColor: ColorName.background, title: Text('app_title'.tr())),
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
                        Text('solving.empty_title'.tr(), style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'solving.empty_subtitle'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(12).copyWith(bottom: 120),
                itemCount: state.items.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return SolveRequestCard(
                    item: item,
                    itemIndex: index,
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openCaptureAndSubmit(context),
            child: const Icon(Icons.add_a_photo_outlined),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),
      ),
    );
  }
}
