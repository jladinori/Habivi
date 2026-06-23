import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/presentation/features/task/task_screen.dart';
import 'package:habivi/presentation/features/habits/habit_detail_screen.dart';
import 'package:habivi/presentation/features/habits/habits_list_screen.dart';
import 'package:habivi/presentation/features/home/home_screen.dart';
import 'package:habivi/presentation/features/notes/notes_screen.dart';
import 'package:habivi/presentation/features/settings/settings_screen.dart';
import 'package:habivi/presentation/features/productivity/productivity_screen.dart';
import 'package:habivi/presentation/features/productivity/pomodoro_screen.dart';
import 'package:habivi/presentation/shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

Page<void> _slideTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(0.15, 0.0), end: Offset.zero);
      final fadeTween = Tween(begin: 0.0, end: 1.0);
      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) => _slideTransition(context, state, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                pageBuilder: (context, state) => _slideTransition(context, state, const HabitsListScreen()),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return _slideTransition(context, state, HabitDetailScreen(habitId: id));
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/productivity',
                pageBuilder: (context, state) => _slideTransition(context, state, const ProductivityScreen()),
                routes: [
                  GoRoute(
                    path: 'pomodoro',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const PomodoroScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                pageBuilder: (context, state) => _slideTransition(context, state, const TaskScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => _slideTransition(context, state, const SettingsScreen()),
                routes: [
                  GoRoute(
                    path: 'notes',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const NotesScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
