import 'package:flutter/material.dart';

import '../../generated/colors.gen.dart';
import '../components/keyboard_dismisser.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.expandBody = true,
    this.appBarHeight,
    this.bottomNavigationBar,
  });

  final Widget body;
  final bool expandBody;
  final double? appBarHeight;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: ColorName.background,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      ),
    );
  }
}
