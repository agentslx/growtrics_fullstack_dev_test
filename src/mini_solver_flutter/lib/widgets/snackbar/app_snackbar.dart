import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';

import '../../generated/assets.gen.dart';
import '../../generated/colors.gen.dart';

enum SnackbarType { info, success, error }

class AppSnackbar {
  static void info({required BuildContext context, required String message}) {
    showSnackBar(context: context, message: message, type: SnackbarType.info);
  }

  static void success({required BuildContext context, required String message}) {
    showSnackBar(context: context, message: message, type: SnackbarType.success);
  }

  static void error({required BuildContext context, required String message}) {
    showSnackBar(context: context, message: message, type: SnackbarType.error);
  }

  static void showSnackBar({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    bool showCloseButton = true,
    VoidCallback? onActionTap,
    String? actionText,
  }) {
    AnimatedSnackBar? snackbar;
    snackbar = AnimatedSnackBar(
      builder: ((context) {
        return Material(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                bottom: BorderSide(
                  color: type == SnackbarType.info
                      ? ColorName.gray700
                      : type == SnackbarType.success
                      ? ColorName.success
                      : ColorName.error,
                  width: 4,
                ),
              ),
            ),
            height: 60,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
              child: Row(
                children: [
                  Icon(
                    (type == SnackbarType.info
                        ? Icons.info_outline
                        : type == SnackbarType.success
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_outlined),
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: ColorName.gray900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onActionTap != null && actionText != null)
                    InkWell(
                      onTap: onActionTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          actionText,
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(color: ColorName.gray900),
                        ),
                      ),
                    ),
                  if (showCloseButton)
                    InkWell(
                      onTap: () {
                        snackbar!.remove();
                      },
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: Center(child: Icon(Icons.close, size: 24, color: ColorName.gray700)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
    snackbar.show(context);
  }
}
