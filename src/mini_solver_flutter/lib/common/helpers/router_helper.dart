import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtension on BuildContext {
  // Navigate back to a specific route
  void popUntilPath(String ancestorPath) {
    while (GoRouter.of(this).routerDelegate.currentConfiguration.matches.last.matchedLocation != ancestorPath) {
      if (!canPop()) {
        return;
      }
      pop();
    }
  }
}
