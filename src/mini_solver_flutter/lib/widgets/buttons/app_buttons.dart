import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mini_solver_flutter/common/helpers/svg_helper.dart';

import '../../generated/colors.gen.dart';
import '../components/circular_loading_indicator.dart';

enum AppButtonSize {
  small,
  medium,
  large;

  EdgeInsetsGeometry get defaultPadding {
    switch (this) {
      case AppButtonSize.small:
        return const EdgeInsets.all(6);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double get iconSize {
    switch (this) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
      case AppButtonSize.large:
        return 24;
    }
  }

  double get defaultHeight {
    switch (this) {
      case AppButtonSize.small:
        return 32;
      case AppButtonSize.medium:
        return 40;
      case AppButtonSize.large:
        return 56;
    }
  }
}

abstract class AppBaseButton extends StatelessWidget {
  AppBaseButton({
    super.key,
    this.isLoading = false,
    this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.labelColor,
    this.labelStyle,
    this.width,
    this.height,
    this.size = AppButtonSize.medium,
    this.contentPadding,
    this.labelTextAlign = TextAlign.center,
    WidgetStatesController? stateController,
  })  : assert(label != null || icon != null, 'Label or icon must be provided'),
        assert((height == null) || (height > size.defaultHeight), 'Height must be greater than ${size.defaultHeight}'),
        statesController = stateController ?? WidgetStatesController();

  final double? width, height;
  final AppButtonSize size;
  final bool isLoading;
  final WidgetStatesController statesController;
  final EdgeInsetsGeometry? contentPadding;

  /// if not provided, the button is considered an icon button
  final String? label;

  /// if not provided, the button is considered a text button
  final Widget? icon;

  /// if not provided, the button is considered disabled
  final void Function()? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? labelColor;
  final TextStyle? labelStyle;
  final TextAlign labelTextAlign;

  Color _getBackgroundColor(BuildContext context, Set<WidgetState> states);

  Color _getIconColor(BuildContext context, Set<WidgetState> states);

  TextStyle? _getLabelStyle(BuildContext context, Set<WidgetState> states);

  OutlinedBorder _getBorder(BuildContext context, Set<WidgetState> states);

  static const double defaultSpacing = 8.0;

  static AppBaseButton of(BuildContext context) => context.findAncestorWidgetOfExactType<AppBaseButton>()!;

  @override
  Widget build(BuildContext context) {
    Widget? renderedIcon;
    if (isLoading) {
      renderedIcon = SizedBox.square(
        dimension: size.iconSize,
        child: CircularLoadingIndicator(
          valueColor: _getIconColor(context, statesController.value),
        ),
      );
    } else if (icon != null) {
      if (icon is SvgPicture) {
        renderedIcon = ValueListenableBuilder<Set<WidgetState>>(
          valueListenable: statesController,
          builder: (context, states, child) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: (icon as SvgPicture).copyWith(
              key: ValueKey(states),
              height: size.iconSize,
              width: size.iconSize,
              fit: BoxFit.fill,
              color: _getIconColor(context, states),
            ),
          ),
        );
      } else {
        renderedIcon = icon;
      }
    }
    return SizedBox(
      width: width,
      height: height,
      child: FilledButton(
        statesController: statesController,
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all<Size>(
            Size(size.defaultHeight, size.defaultHeight),
          ),
          elevation: WidgetStateProperty.all<double>(0),
          animationDuration: Duration.zero,
          splashFactory: NoSplash.splashFactory,
          textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (states) => _getLabelStyle(context, states),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => _getBackgroundColor(context, states),
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
                (states) => _getIconColor(context, states),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color>(
            (states) => _getBackgroundColor(context, states),
          ),
          surfaceTintColor: WidgetStateProperty.resolveWith<Color>(
            (states) => _getIconColor(context, states),
          ),
          iconColor: WidgetStateProperty.resolveWith<Color>(
            (states) => _getIconColor(context, states),
          ),
          iconSize: WidgetStateProperty.all<double>(
            size.iconSize,
          ),
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
            contentPadding ?? size.defaultPadding,
          ),
          shape: WidgetStateProperty.resolveWith<OutlinedBorder>(
            (states) => _getBorder(context, states),
          ),

        ),
        onPressed: onPressed != null
            ? () {
                if (!isLoading) onPressed!();
              }
            : null,
        child: Builder(
          builder: (context) {
            final double spacing = renderedIcon != null && label != null ? AppBaseButton.defaultSpacing : 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (renderedIcon != null) renderedIcon,
                SizedBox(
                  width: spacing,
                ),
                if (label != null)
                  Text(
                    label!,
                    style: WidgetStateTextStyle.resolveWith(
                      (states) => _getLabelStyle(
                        context,
                        states,
                      )!,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class AppSecondaryButton extends AppBaseButton {
  AppSecondaryButton({
    super.key,
    super.label,
    super.icon,
    super.onPressed,
    super.backgroundColor,
    super.iconColor,
    super.labelColor,
    super.labelStyle,
    super.width,
    super.height,
    super.size = AppButtonSize.large,
    super.contentPadding,
  });

  @override
  Color _getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    if (backgroundColor != null) return backgroundColor!;
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray400;
    }
    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
      return ColorName.gray400;
    }
    return ColorName.gray400;
  }

  @override
  OutlinedBorder _getBorder(BuildContext context, Set<WidgetState> states) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      );

  @override
  Color _getIconColor(BuildContext context, Set<WidgetState> states) {
    if (iconColor != null) return iconColor!;
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray900;
    }
    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
      return ColorName.gray900;
    }
    return ColorName.gray900;
  }

  @override
  TextStyle? _getLabelStyle(BuildContext context, Set<WidgetState> states) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
            color: labelColor ?? _getIconColor(context, states),
          );
}

class AppPrimaryButton extends AppBaseButton {
  AppPrimaryButton({
    super.key,
    super.label,
    super.icon,
    super.onPressed,
    super.backgroundColor,
    super.iconColor,
    super.labelColor,
    super.labelStyle,
    super.width,
    super.height,
    super.size = AppButtonSize.large,
    super.isLoading,
  });

  @override
  Color _getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    if (backgroundColor != null) return backgroundColor!;
    if (states.contains(WidgetState.disabled) || states.contains(WidgetState.hovered)) {
      return ColorName.brandTeal.withOpacity(0.5);
    }
    if (states.contains(WidgetState.pressed)) {
      return Theme.of(context).colorScheme.onPrimary;
    }
    return ColorName.brandTeal;
  }

  @override
  OutlinedBorder _getBorder(BuildContext context, Set<WidgetState> states) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      );

  @override
  Color _getIconColor(BuildContext context, Set<WidgetState> states) {
    if (iconColor != null) return iconColor!;
    if (labelColor != null) return labelColor!;
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray200;
    }
    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
      return ColorName.white;
    }
    return ColorName.white;
  }

  @override
  TextStyle? _getLabelStyle(BuildContext context, Set<WidgetState> states) => Theme.of(context)
      .textTheme
      .labelSmall
      ?.copyWith(
        color: labelColor ?? _getIconColor(context, states),
      )
      .merge(labelStyle);
}

class AppTextButton extends AppBaseButton {
  AppTextButton({
    super.key,
    super.label,
    super.icon,
    super.onPressed,
    super.backgroundColor,
    super.iconColor,
    super.labelColor,
    super.labelStyle,
    super.width,
    super.height,
    super.isLoading,
    super.size = AppButtonSize.small,
  });

  @override
  Color _getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    if (backgroundColor != null) return backgroundColor!;
    return Colors.transparent;
  }

  @override
  OutlinedBorder _getBorder(BuildContext context, Set<WidgetState> states) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide.none,
      );

  @override
  Color _getIconColor(BuildContext context, Set<WidgetState> states) {
    if (iconColor != null) return iconColor!;
    if (labelColor != null) return labelColor!;
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray400;
    }
    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
      return ColorName.gray500;
    }
    return ColorName.brandTeal;
  }

  @override
  TextStyle? _getLabelStyle(BuildContext context, Set<WidgetState> states) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
            color: labelColor ?? _getIconColor(context, states),
          );
}

class AppBorderButton extends AppBaseButton {
  AppBorderButton({
    super.key,
    super.label,
    super.icon,
    super.onPressed,
    super.backgroundColor,
    super.iconColor,
    super.labelColor,
    super.labelStyle,
    super.width,
    super.height,
    super.size = AppButtonSize.large,
    this.borderColor = ColorName.gray300,
    super.contentPadding,
    super.isLoading,
  });

  final Color borderColor;

  @override
  Color _getBackgroundColor(BuildContext context, Set<WidgetState> states) {
    if (backgroundColor != null) return backgroundColor!;
    return Colors.transparent;
  }

  @override
  OutlinedBorder _getBorder(BuildContext context, Set<WidgetState> states) => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: borderColor,
          width: 1,
        ),
      );

  @override
  Color _getIconColor(BuildContext context, Set<WidgetState> states) {
    if (iconColor != null) return iconColor!;
    if (labelColor != null) return labelColor!;
    if (states.contains(WidgetState.disabled)) {
      return ColorName.gray400;
    }
    if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
      return ColorName.gray500;
    }
    return ColorName.brandTeal;
  }

  @override
  TextStyle? _getLabelStyle(BuildContext context, Set<WidgetState> states) =>
      Theme.of(context).textTheme.labelSmall?.copyWith(
            color: labelColor ?? _getIconColor(context, states),
          );
}
