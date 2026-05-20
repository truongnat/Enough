import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/alarms/presentation/screens/create_alarm_screen.dart';
import '../../features/alarms/presentation/screens/edit_alarm_screen.dart';
import '../../features/stop_session/presentation/screens/stop_session_screen.dart';
import '../../features/receipts/presentation/screens/receipt_detail_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/stats/presentation/screens/stats_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../core/widgets/main_scaffold.dart';

final routerKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = ref.watch(routerKeyProvider);
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                name: 'stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/alarm/create',
        name: 'createAlarm',
        builder: (context, state) => const CreateAlarmScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/alarm/edit/:id',
        name: 'editAlarm',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditAlarmScreen(alarmId: id);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/session',
        name: 'stopSession',
        builder: (context, state) {
          final alarmId = state.uri.queryParameters['alarmId'];
          return StopSessionScreen(alarmId: alarmId);
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: '/receipt/:id',
        name: 'receiptDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptDetailScreen(receiptId: id);
        },
      ),
    ],
  );
});
