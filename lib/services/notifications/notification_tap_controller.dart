import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'notification_payload.dart';

class NotificationTapController extends StateNotifier<NotificationTapState> {
  NotificationTapController() : super(NotificationTapState.initial());

  void handleNotificationTap(String? payload, GoRouter router) {
    if (payload == null || payload.isEmpty) {
      state = state.copyWith(error: 'No payload');
      return;
    }

    try {
      final notificationPayload = NotificationPayload.fromJson(payload);
      final alarmId = notificationPayload.alarmId;
      final action = notificationPayload.action;
      
      if (alarmId.isNotEmpty) {
        if (action == NotificationPayload.actionOpenStopSession) {
          router.push('/session?alarmId=$alarmId');
        } else if (action == NotificationPayload.actionOpenSnoozedSession) {
          router.push('/session?alarmId=$alarmId&sessionId=${notificationPayload.sessionId}');
        }
        state = state.copyWith(lastPayload: payload, error: null);
      } else {
        state = state.copyWith(error: 'No alarmId in payload');
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to parse payload: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class NotificationTapState {
  final String? lastPayload;
  final String? error;

  NotificationTapState({
    this.lastPayload,
    this.error,
  });

  factory NotificationTapState.initial() {
    return NotificationTapState();
  }

  NotificationTapState copyWith({
    String? lastPayload,
    String? error,
  }) {
    return NotificationTapState(
      lastPayload: lastPayload ?? this.lastPayload,
      error: error,
    );
  }
}

final notificationTapControllerProvider =
    StateNotifierProvider<NotificationTapController, NotificationTapState>((ref) {
  return NotificationTapController();
});
