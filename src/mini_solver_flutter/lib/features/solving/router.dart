import 'package:go_router/go_router.dart';

import 'ui/pages/solving_capture_page.dart';

class SolvingRouter {
  static const String capture = '/solve/capture';

  static final List<RouteBase> routes = [
    GoRoute(
      path: capture,
      builder: (context, state) => const SolvingCapturePage(),
    ),
  ];
}
