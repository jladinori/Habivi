import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/presentation/features/task/task_screen.dart';
import 'package:habivi/presentation/features/habits/habit_detail_screen.dart';
import 'package:habivi/presentation/features/habits/habits_list_screen.dart';
import 'package:habivi/presentation/features/home/home_screen.dart';
import 'package:habivi/presentation/features/notes/notes_screen.dart';
import 'package:habivi/presentation/features/settings/settings_screen.dart';
import 'package:habivi/presentation/features/Productivity/productivity_screen.dart';
import 'package:habivi/presentation/shell/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                builder: (context, state) => const HabitsListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return HabitDetailScreen(habitId: id);
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
                builder: (context, state) => const ProductivityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tasks',
                builder: (context, state) => const TaskScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotesScreen(),
      ),
    ],
  );
});
