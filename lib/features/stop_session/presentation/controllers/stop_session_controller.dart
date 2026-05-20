import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/datasources/stop_session_local_datasource.dart';
import '../../data/repositories/stop_session_repository_impl.dart';
import '../../domain/entities/stop_session.dart';
import '../../domain/entities/stop_session_status.dart';
import '../../domain/repositories/stop_session_repository.dart';
import '../../../alarms/domain/entities/stop_alarm.dart';
import '../../../alarms/domain/entities/stop_protocol.dart';
import '../../../alarms/domain/repositories/alarm_repository.dart';
import '../../../receipts/domain/entities/stop_receipt.dart';
import '../../../receipts/domain/repositories/receipt_repository.dart';
import '../../../settings/domain/entities/app_settings.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../../core/constants/copywriting.dart';
import '../../../../app/di/providers.dart';

class StopSessionController extends StateNotifier<StopSessionState> {
  final AlarmRepository _alarmRepository;
  final ReceiptRepository _receiptRepository;
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;
  final StopSessionRepository _sessionRepository;

  StopSessionController(
    this._alarmRepository,
    this._receiptRepository,
    this._settingsRepository,
    this._notificationService,
    this._sessionRepository,
  ) : super(StopSessionState.initial());

  Future<void> loadSession(String? alarmId) async {
    if (alarmId == null) {
      state = state.copyWith(error: 'No alarm ID provided');
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final alarms = await _alarmRepository.getAlarms();
      final alarm = alarms.firstWhere((a) => a.id == alarmId);
      
      // Get protocol
      final protocol = StopProtocol.getTemplatesFor(alarm.stopType)
          .firstWhere((p) => p.id == alarm.protocolId);

      // Create or get active session
      StopSession session;
      final sessions = await _sessionRepository.getSessionsByAlarmId(alarmId);
      final existingSession = sessions.firstWhere(
        (s) => s.status == StopSessionStatus.active,
        orElse: () => StopSession(
          id: '',
          alarmId: '',
          stopType: alarm.stopType,
          startedAt: DateTime.now(),
          status: StopSessionStatus.active,
          snoozeCount: 0,
          checkedStepIndexes: [],
        ),
      );

      if (existingSession.id.isNotEmpty) {
        session = existingSession;
      } else {
        session = StopSession(
          id: IdGenerator.generate(),
          alarmId: alarm.id,
          stopType: alarm.stopType,
          startedAt: DateTime.now(),
          status: StopSessionStatus.active,
          snoozeCount: 0,
          checkedStepIndexes: [],
        );
        await _sessionRepository.saveSession(session);
      }

      state = state.copyWith(
        session: session,
        alarm: alarm,
        protocol: protocol,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void toggleStep(int index) {
    final session = state.session;
    if (session == null) return;

    final checkedIndexes = List<int>.from(session.checkedStepIndexes);
    if (checkedIndexes.contains(index)) {
      checkedIndexes.remove(index);
    } else {
      checkedIndexes.add(index);
    }

    final updatedSession = session.copyWith(checkedStepIndexes: checkedIndexes);
    state = state.copyWith(session: updatedSession);
    _sessionRepository.saveSession(updatedSession);
  }

  Future<void> completeSession() async {
    final session = state.session;
    final alarm = state.alarm;
    if (session == null || alarm == null) return;

    if (!session.canComplete) {
      state = state.copyWith(error: Copywriting.mustCheckStep);
      return;
    }

    try {
      final completedAt = DateTime.now();
      final completedSession = session.copyWith(
        status: StopSessionStatus.completed,
        completedAt: completedAt,
      );

      await _sessionRepository.saveSession(completedSession);

      // Create receipt
      final receipt = StopReceipt(
        id: const Uuid().v4(),
        alarmId: alarm.id,
        sessionId: session.id,
        stopType: session.stopType,
        title: alarm.stopType.displayName,
        startedAt: session.startedAt,
        completedAt: completedAt,
        savedFromMessages: StopReceipt.getPreventedItemsFor(session.stopType),
        resultMessage: Copywriting.receiptResult,
        createdAt: DateTime.now(),
      );

      await _receiptRepository.saveReceipt(receipt);

      state = state.copyWith(
        session: completedSession,
        isCompleted: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> snoozeSession() async {
    final session = state.session;
    final alarm = state.alarm;
    if (session == null || alarm == null) return;

    try {
      final settings = await _settingsRepository.getSettings() ?? AppSettings.defaultSettings();
      final snoozeMinutes = settings.defaultSnoozeMinutes;

      final snoozedSession = session.copyWith(
        status: StopSessionStatus.snoozed,
        snoozeCount: session.snoozeCount + 1,
      );

      await _sessionRepository.saveSession(snoozedSession);
      await _notificationService.scheduleSnooze(session, snoozeMinutes);

      state = state.copyWith(
        session: snoozedSession,
        isSnoozed: true,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class StopSessionState {
  final StopSession? session;
  final StopAlarm? alarm;
  final StopProtocol? protocol;
  final bool isLoading;
  final bool isCompleted;
  final bool isSnoozed;
  final String? error;

  StopSessionState({
    this.session,
    this.alarm,
    this.protocol,
    required this.isLoading,
    this.isCompleted = false,
    this.isSnoozed = false,
    this.error,
  });

  factory StopSessionState.initial() {
    return StopSessionState(
      session: null,
      alarm: null,
      protocol: null,
      isLoading: false,
      isCompleted: false,
      isSnoozed: false,
      error: null,
    );
  }

  StopSessionState copyWith({
    StopSession? session,
    StopAlarm? alarm,
    StopProtocol? protocol,
    bool? isLoading,
    bool? isCompleted,
    bool? isSnoozed,
    String? error,
  }) {
    return StopSessionState(
      session: session ?? this.session,
      alarm: alarm ?? this.alarm,
      protocol: protocol ?? this.protocol,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
      isSnoozed: isSnoozed ?? this.isSnoozed,
      error: error ?? this.error,
    );
  }
}

// Provider
final stopSessionControllerProvider = StateNotifierProvider<StopSessionController, StopSessionState>((ref) {
  final alarmRepo = ref.read(alarmRepositoryProvider);
  final receiptRepo = ref.read(receiptRepositoryProvider);
  final settingsRepo = ref.read(settingsRepositoryProvider);
  final notificationSvc = ref.read(notificationServiceProvider);
  final storage = ref.read(storageServiceProvider);
  return StopSessionController(
    alarmRepo,
    receiptRepo,
    settingsRepo,
    notificationSvc,
    StopSessionRepositoryImpl(StopSessionLocalDatasource(storage)),
  );
});
