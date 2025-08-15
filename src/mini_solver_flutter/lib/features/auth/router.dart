import 'package:go_router/go_router.dart';

import 'ui/pages/login_page.dart';
import 'ui/pages/register_page.dart';
import 'ui/pages/loading_page.dart';

class AuthRouter {
  static const String loading = '/loading';
  static const String login = '/login';
  static const String signUp = '/signup';

  static final List<RouteBase> routes = [
    GoRoute(
      path: loading,
      builder: (context, state) => const LoadingPage(),
    ),
    GoRoute(
      path: login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: signUp,
      builder: (context, state) => const RegisterPage(),
    ),
  ];
}
