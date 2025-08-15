import 'package:flutter/material.dart';

class AppStyles {
  static const largeButtonHeight = 56.0;
  static const mediumButtonHeight = 40.0;
  static const smallButtonHeight = 32.0;

  static List<BoxShadow> boxShadow = <BoxShadow>[
    BoxShadow(
      color: Colors.black.withOpacity(.08),
      blurRadius: 4,
      offset: const Offset(1, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(.12),
      blurRadius: 2,
    ),
  ];
}
