import 'package:go_router/go_router.dart';

import '../features/intake/views/intake_shell.dart';
import '../features/intake/views/session_view.dart';
import '../features/intake/views/welcome_view.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => IntakeShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          name: 'welcome',
          builder: (context, state) => const WelcomeView(),
        ),
        GoRoute(
          path: '/session',
          name: 'session',
          builder: (context, state) => const SessionView(),
        ),
      ],
    ),
  ],
);
