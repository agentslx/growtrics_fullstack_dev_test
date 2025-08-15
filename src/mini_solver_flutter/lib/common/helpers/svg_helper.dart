import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

extension SvgPictureCopyWith on SvgPicture {
  SvgPicture copyWith({
    Key? key,
    String? assetName,
    Color? color,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    bool? allowDrawingOutsideViewBox,
    Widget Function(BuildContext)? placeholderBuilder,
    String? semanticsLabel,
    bool? excludeFromSemantics,
    Clip? clipBehavior,
    double? height,
    double? width,
  }) =>
      SvgPicture(
        bytesLoader,
        height: height ?? this.height,
        width: width ?? this.width,
        key: key ?? this.key,
        colorFilter: colorFilter ??
            (color == null
                ? null
                : ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  )),
        fit: fit ?? this.fit,
        alignment: alignment ?? this.alignment,
        allowDrawingOutsideViewBox: allowDrawingOutsideViewBox ?? this.allowDrawingOutsideViewBox,
        placeholderBuilder: placeholderBuilder ?? this.placeholderBuilder,
        semanticsLabel: semanticsLabel ?? this.semanticsLabel,
        excludeFromSemantics: excludeFromSemantics ?? this.excludeFromSemantics,
        clipBehavior: clipBehavior ?? this.clipBehavior,
      );
}
