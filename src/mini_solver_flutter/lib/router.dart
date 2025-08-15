import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/router.dart';
import 'features/home/router.dart';


class AppRouter {
  AppRouter() : goRouter = _router;
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel: 'app-nav-key');

  final GoRouter goRouter;

  static GoRouter get _router => GoRouter(
    debugLogDiagnostics: kDebugMode,
    navigatorKey: navigatorKey,
    initialLocation: AuthRouter.loading,
    routes: [
      ...AuthRouter.routes,
      ...HomeRouter.routes,
    ],
    onException: (context, state, error) {
      log('An exception occurred: $error ${state.error}');
    },
  );
}
