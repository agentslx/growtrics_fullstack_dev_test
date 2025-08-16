import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_solver_flutter/features/solving/cubits/solving_session_cubit/solving_session_state.dart';
import 'package:mini_solver_flutter/features/solving/ui/widgets/result_bubble.dart';
import 'package:mini_solver_flutter/generated/colors.gen.dart';

import '../../../../widgets/buttons/app_buttons.dart';
import '../../../../widgets/components/circular_loading_indicator.dart';
import '../../cubits/solving_session_cubit/solving_session_cubit.dart';

class SolveRequestCard extends StatelessWidget {
  const SolveRequestCard({super.key, required this.item, required this.itemIndex});

  final SolvingItem item;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: ColorName.white,
      elevation: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Image.file(item.image, height: 220, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white30,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.read<SolvingSessionCubit>().removeItem(item);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.isSubmitting) Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: CircularLoadingIndicator()),
          ),
          if (item.errorMessage != null && item.errorMessage!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16).copyWith(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    (item.errorMessage!.startsWith('solving.')) ? item.errorMessage!.tr() : item.errorMessage!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w500),
                  ),
                  AppPrimaryButton(
                    onPressed: () {
                      context.read<SolvingSessionCubit>().retryItem(item);
                    },
                    label: 'solving.retry'.tr(),
                  ),
                ],
              ),
            ),
          if (!item.isSubmitting && item.results.isNotEmpty) ...[
            for (final r in item.results) ...[
              SolveResultBubble(
                result: r,
                index: item.results.indexOf(r),
                length: item.results.length,
                shouldExpandByDefault: itemIndex == 0,
                onRetry: () {
                  context.read<SolvingSessionCubit>().retryItem(item);
                },
              ),
              const SizedBox(height: 2),
              if (item.results.indexOf(r) < item.results.length - 1)
                Divider(height: 1, color: ColorName.gray400),

            ],
          ],
        ],
      ),
    );
  }
}
