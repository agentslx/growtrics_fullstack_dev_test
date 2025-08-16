import 'package:flutter/material.dart';

import '../../generated/colors.gen.dart';

class CircularLoadingIndicator extends StatelessWidget {
  const CircularLoadingIndicator({
    super.key,
    this.color = ColorName.brandTeal,
    this.valueColor = ColorName.brandTeal,
    this.strokeWidth = 4,
    this.value,
  });

  final Color color;
  final Color valueColor;
  final double strokeWidth;
  final double? value;

  @override
  Widget build(BuildContext context) => CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
        color: color,
        strokeWidth: 1.5,
        value: value,
      );
}
