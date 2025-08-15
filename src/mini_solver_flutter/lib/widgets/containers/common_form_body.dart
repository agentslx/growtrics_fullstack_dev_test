import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../generated/colors.gen.dart';

class CommonFormBody extends StatelessWidget {
  const CommonFormBody({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.childTopPadding = 40.0,
    this.bottomWidget,
    this.minBottomSpacing = 16.0,
    this.onBack,
    this.autoImplyBack = true,
    this.scrollable = true,
  });

  final Widget child;
  final String? title, subtitle;
  final double childTopPadding;
  final Widget? bottomWidget;
  final double minBottomSpacing;
  final bool autoImplyBack;
  final VoidCallback? onBack;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final widget = Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16.0,
        right: 16.0,
        bottom: max(16, MediaQuery.of(context).padding.bottom),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final isInfinity = constraints.maxHeight == double.infinity;
        // child should not be infinity (should not have expanded
        if (isInfinity) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backRow(context),
                  ..._headers(context),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: child,
                  ),
                ],
              ),
              if (bottomWidget != null) _bottomWidget(context),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backRow(context),
                  ..._headers(context),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: child,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (bottomWidget != null) _bottomWidget(context),
          ],
        );
      }),
    );

    if (scrollable) {
      return _CommonScrollableWrapper(
        child: widget,
      );
    }
    return widget;
  }

  Widget _backRow(BuildContext context) {
    return SizedBox(
      height: 64,
      child: (autoImplyBack && context.canPop() || onBack != null)
          ? Align(
              alignment: Alignment.topLeft,
            child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorName.gray800,
                ),
                onPressed: onBack ?? () => context.pop(),
              ),
          )
          : null,
    );
  }

  List<Widget> _headers(BuildContext context) {
    if (title == null) {
      return [];
    }
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          title!.toUpperCase(),
          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontSize: 32.0,
              ),
        ),
      ),
      if (subtitle != null) ...[
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: ColorName.gray800,
                ),
          ),
        ),
      ],
      SizedBox(height: childTopPadding),
    ];
  }

  Widget _bottomWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: minBottomSpacing,
        bottom: MediaQuery.of(context).padding.bottom,
        left: 8,
        right: 8,
      ),
      child: bottomWidget!,
    );
  }
}

class _CommonScrollableWrapper extends StatelessWidget {
  const _CommonScrollableWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraint.maxHeight),
          child: child,
        ),
      );
    });
  }
}
