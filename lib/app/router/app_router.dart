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

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/alarm/create',
        name: 'createAlarm',
        builder: (context, state) => const CreateAlarmScreen(),
      ),
      GoRoute(
        path: '/alarm/edit/:id',
        name: 'editAlarm',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditAlarmScreen(alarmId: id);
        },
      ),
      GoRoute(
        path: '/session',
        name: 'stopSession',
        builder: (context, state) {
          final alarmId = state.uri.queryParameters['alarmId'];
          return StopSessionScreen(alarmId: alarmId);
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/receipt/:id',
        name: 'receiptDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReceiptDetailScreen(receiptId: id);
        },
      ),
      GoRoute(
        path: '/stats',
        name: 'stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
