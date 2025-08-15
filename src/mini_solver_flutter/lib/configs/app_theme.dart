import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generated/colors.gen.dart';
import 'app_text_theme.dart';

class AppTheme {
  static const String fontName = 'Roboto';

  static final dark = ThemeData.light().copyWith(
    primaryColor: ColorName.brandTeal,
    disabledColor: ColorName.gray400,
    hintColor: ColorName.gray500,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: ColorName.brandTeal,
      onPrimary: ColorName.white,
      secondary: ColorName.brandBlue,
      onSecondary: ColorName.white,
      error: ColorName.error,
      onError: ColorName.white,
      surface: ColorName.background,
      onSurface: ColorName.gray900,
    ),
    scaffoldBackgroundColor: ColorName.background,
    appBarTheme: AppBarTheme(
      color: ColorName.brandTeal,
      toolbarHeight: 64,
      titleTextStyle: AppTextTheme.defaultTextTheme.headlineLarge,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      floatingLabelStyle: AppTextTheme.defaultTextTheme.titleSmall!.copyWith(
        color: ColorName.white,
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: ColorName.gray400,
          width: 1,
        ),
      ),
      errorStyle: AppTextTheme.defaultTextTheme.bodySmall!.copyWith(
        color: ColorName.gray600,
      ),
      hintStyle: AppTextTheme.defaultTextTheme.bodySmall?.copyWith(
        color: ColorName.gray500,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: ColorName.error,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: ColorName.gray400,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: ColorName.gray300,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(
          color: ColorName.brandBlue,
          width: 2,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
    ),
    textTheme: AppTextTheme.defaultTextTheme,
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      colorScheme: const ColorScheme.light(
        primary: ColorName.white,
        secondary: ColorName.gray200,
        outline: ColorName.gray400,
      ),
      textTheme: ButtonTextTheme.primary,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 16,
      ),
    ),
    textButtonTheme: const TextButtonThemeData(),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
            return ColorName.gray300;
          }
          return ColorName.gray200;
        }),
        textStyle: WidgetStateProperty.resolveWith<TextStyle?>(
          (states) {
            final textStyle = AppTextTheme.defaultTextTheme.labelSmall?.copyWith(
              color: ColorName.gray900,
            );
            if (states.contains(WidgetState.disabled)) {
              return textStyle?.copyWith(color: ColorName.gray400);
            }
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return textStyle?.copyWith(color: ColorName.gray600);
            }
            return textStyle;
          },
        ),
        iconColor: WidgetStateProperty.resolveWith<Color?>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return ColorName.gray400;
            }
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return ColorName.gray600;
            }
            return ColorName.gray900;
          },
        ),
        iconSize: WidgetStateProperty.all<double>(24),
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return ColorName.gray600;
            }
            if (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed)) {
              return ColorName.gray300;
            }
            return ColorName.gray200;
          },
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return ColorName.success;
          }
          return Colors.transparent;
        },
      ),
      checkColor: WidgetStateProperty.resolveWith<Color>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return ColorName.white;
          }
          return Colors.transparent;
        },
      ),
      shape: const CircleBorder(
        side: BorderSide(
          width: 1.0,
        ),
      ),
      side: const BorderSide(
        width: 1.0,
        color: ColorName.gray400,
      ),
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: 0,
      margin: EdgeInsets.zero,
      color: ColorName.background,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        iconSize: WidgetStateProperty.all<double>(24),
        // iconColor: WidgetStateProperty.resolveWith<Color>(_foregroundColor),
        alignment: Alignment.center,
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: AppTextTheme.defaultTextTheme.labelSmall?.copyWith(
        color: ColorName.gray600,
      ),
      subtitleTextStyle: AppTextTheme.defaultTextTheme.bodySmall?.copyWith(
        color: ColorName.gray600,
      ),
      iconColor: ColorName.gray600,
      textColor: ColorName.gray600,
      contentPadding: const EdgeInsets.only(left: 16, right: 8),
    ),
    dividerTheme: const DividerThemeData(
      color: ColorName.gray300,
      thickness: 1,
      indent: 0,
      endIndent: 0,
      space: 1,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Colors.transparent,
      disabledColor: ColorName.gray200,
      selectedColor: ColorName.gray600,
      pressElevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      shape: StadiumBorder(
        side: BorderSide.none,
      ),
      elevation: 0,
      side: BorderSide.none,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ColorName.success,
      refreshBackgroundColor: ColorName.background,
    ),
  );
}
