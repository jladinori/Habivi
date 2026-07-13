import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/presentation/features/task/task_screen.dart';
import 'package:habivi/presentation/features/habits/habit_detail_screen.dart';
import 'package:habivi/presentation/features/habits/habits_list_screen.dart';
import 'package:habivi/presentation/features/home/home_screen.dart';
import 'package:habivi/presentation/features/auth/login_screen.dart';
import 'package:habivi/presentation/features/notes/notes_screen.dart';
import 'package:habivi/presentation/features/settings/settings_screen.dart';
import 'package:habivi/presentation/features/productivity/productivity_screen.dart';
import 'package:habivi/presentation/features/productivity/pomodoro_info_screen.dart';
import 'package:habivi/presentation/features/productivity/pomodoro_config_screen.dart';
import 'package:habivi/presentation/features/productivity/pomodoro_screen.dart';
import 'package:habivi/presentation/features/productivity/feynman_info_screen.dart';
import 'package:habivi/presentation/features/productivity/feynman_action_screen.dart';
import 'package:habivi/presentation/features/productivity/active_recall_info_screen.dart';
import 'package:habivi/presentation/features/productivity/active_recall_action_screen.dart';
import 'package:habivi/presentation/features/productivity/spaced_repetition_info_screen.dart';
import 'package:habivi/presentation/features/productivity/spaced_repetition_action_screen.dart';
import 'package:habivi/presentation/features/productivity/cornell_info_screen.dart';
import 'package:habivi/presentation/features/productivity/cornell_action_screen.dart';
import 'package:habivi/presentation/features/productivity/time_blocking_info_screen.dart';
import 'package:habivi/presentation/features/productivity/time_blocking_action_screen.dart';
import 'package:habivi/presentation/features/productivity/fifty_ten_info_screen.dart';
import 'package:habivi/presentation/features/productivity/fifty_ten_config_screen.dart';
import 'package:habivi/presentation/features/productivity/mind_maps_info_screen.dart';
import 'package:habivi/presentation/features/productivity/mind_maps_action_screen.dart';
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
                path: '/tasks',
                pageBuilder: (context, state) => _slideTransition(context, state, const TaskScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/productivity',
                pageBuilder: (context, state) => _slideTransition(context, state, const ProductivityScreen()),
                routes: [
                  // Pomodoro
                  GoRoute(
                    path: 'pomodoro-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const PomodoroInfoScreen()),
                  ),
                  GoRoute(
                    path: 'pomodoro-config',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const PomodoroConfigScreen()),
                  ),
                  GoRoute(
                    path: 'pomodoro',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final args = state.extra as Map<String, int>?;
                      return _slideTransition(
                        context,
                        state,
                        PomodoroScreen(
                          tiempoTrabajo: args?['tiempoTrabajo'] ?? 25,
                          tiempoDescanso: args?['tiempoDescanso'] ?? 5,
                        ),
                      );
                    },
                  ),
                  // Feynman
                  GoRoute(
                    path: 'feynman-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const FeynmanInfoScreen()),
                  ),
                  GoRoute(
                    path: 'feynman-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const FeynmanActionScreen()),
                  ),
                  // Active Recall
                  GoRoute(
                    path: 'active-recall-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const ActiveRecallInfoScreen()),
                  ),
                  GoRoute(
                    path: 'active-recall-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const ActiveRecallActionScreen()),
                  ),
                  // Spaced Repetition
                  GoRoute(
                    path: 'spaced-repetition-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const SpacedRepetitionInfoScreen()),
                  ),
                  GoRoute(
                    path: 'spaced-repetition-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const SpacedRepetitionActionScreen()),
                  ),
                  // Cornell
                  GoRoute(
                    path: 'cornell-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const CornellInfoScreen()),
                  ),
                  GoRoute(
                    path: 'cornell-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const CornellActionScreen()),
                  ),
                  // Time Blocking
                  GoRoute(
                    path: 'time-blocking-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const TimeBlockingInfoScreen()),
                  ),
                  GoRoute(
                    path: 'time-blocking-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const TimeBlockingActionScreen()),
                  ),
                  // 50/10
                  GoRoute(
                    path: 'fifty-ten-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const FiftyTenInfoScreen()),
                  ),
                  GoRoute(
                    path: 'fifty-ten-config',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const FiftyTenConfigScreen()),
                  ),
                  // Mind Maps
                  GoRoute(
                    path: 'mind-maps-info',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const MindMapsInfoScreen()),
                  ),
                  GoRoute(
                    path: 'mind-maps-action',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) => _slideTransition(context, state, const MindMapsActionScreen()),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Settings accesible via push (no es pestaña)
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _slideTransition(context, state, const SettingsScreen()),
        routes: [
          GoRoute(
            path: 'notes',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => _slideTransition(context, state, const NotesScreen()),
          ),
          GoRoute(
            path: 'login',
            parentNavigatorKey: _rootNavigatorKey,
            pageBuilder: (context, state) => _slideTransition(context, state, const LoginScreen()),
          ),
        ],
      ),
    ],
  );
});
