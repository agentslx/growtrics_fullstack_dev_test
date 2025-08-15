import 'package:go_router/go_router.dart';
import 'package:mini_solver_flutter/features/home/ui/pages/home_tabs_page.dart';

class HomeRouter {
  static const String home = '/home';

  static final List<RouteBase> routes = [
    GoRoute(
      path: home,
      builder: (context, state) => const HomeTabsPage(),
    ),
  ];
}
