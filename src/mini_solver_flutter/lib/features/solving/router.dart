import 'dart:io';

import 'package:go_router/go_router.dart';

import 'ui/pages/solving_capture_page.dart';
import 'ui/pages/solving_chat_page.dart';

class SolvingRouter {
  static const String capture = '/solve/capture';
  static const String chat = '/solve/chat';

  static final List<RouteBase> routes = [
    GoRoute(
      path: capture,
      builder: (context, state) => const SolvingCapturePage(),
    ),
    GoRoute(
      path: chat,
      builder: (context, state) {
        final file = state.extra is File ? state.extra as File : null;
        return SolvingChatPage(initialImage: file);
      },
    ),
  ];
}
