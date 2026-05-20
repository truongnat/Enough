import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/stop_alarm.dart';
import '../../domain/entities/stop_type.dart';
import '../../domain/entities/stop_mode.dart';
import '../../domain/entities/repeat_day.dart';
import '../../domain/entities/stop_protocol.dart';
import '../../domain/usecases/create_alarm.dart';
import '../../domain/usecases/update_alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../../../../services/notifications/notification_service.dart';
import '../../../../app/di/providers.dart';

class AlarmState {
  final String? alarmId;
  final String title;
  final StopType stopType;
  final String? customTypeLabel;
  final int hour;
  final int minute;
  final List<RepeatDay> repeatDays;
  final StopMode mode;
  final String protocolId;
  final bool isEnabled;
  final DateTime? createdAt;
  final bool isSaving;
  final bool isSaved;
  final String? error;

  AlarmState({
    this.alarmId,
    required this.title,
    required this.stopType,
    this.customTypeLabel,
    required this.hour,
    required this.minute,
    required this.repeatDays,
    required this.mode,
    required this.protocolId,
    required this.isEnabled,
    this.createdAt,
    this.isSaving = false,
    this.isSaved = false,
    this.error,
  });

  factory AlarmState.initial() {
    return AlarmState(
      alarmId: null,
      title: '',
      stopType: StopType.coding,
      customTypeLabel: null,
      hour: 23,
      minute: 30,
      repeatDays: [],
      mode: StopMode.meme,
      protocolId: StopProtocol.getDefaultTemplate(StopType.coding).id,
      isEnabled: true,
      createdAt: null,
      isSaving: false,
      isSaved: false,
      error: null,
    );
  }

  AlarmState copyWith({
    String? alarmId,
    String? title,
    StopType? stopType,
    String? customTypeLabel,
    int? hour,
    int? minute,
    List<RepeatDay>? repeatDays,
    StopMode? mode,
    String? protocolId,
    bool? isEnabled,
    DateTime? createdAt,
    bool? isSaving,
    bool? isSaved,
    String? error,
  }) {
    return AlarmState(
      alarmId: alarmId ?? this.alarmId,
      title: title ?? this.title,
      stopType: stopType ?? this.stopType,
      customTypeLabel: customTypeLabel ?? this.customTypeLabel,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      repeatDays: repeatDays ?? this.repeatDays,
      mode: mode ?? this.mode,
      protocolId: protocolId ?? this.protocolId,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error,
    );
  }
}

class AlarmController extends StateNotifier<AlarmState> {
  final CreateAlarm _createAlarm;
  final UpdateAlarm _updateAlarm;
  final AlarmRepository _repository;
  final NotificationService _notificationService;

  AlarmController(
    this._createAlarm,
    this._updateAlarm,
    this._repository,
    this._notificationService,
  ) : super(AlarmState.initial());

  void setStopType(StopType type) {
    state = state.copyWith(stopType: type);
    final protocol = StopProtocol.getDefaultTemplate(type);
    state = state.copyWith(protocolId: protocol.id);
  }

  void setTime(int hour, int minute) {
    state = state.copyWith(hour: hour, minute: minute);
  }

  void setRepeatDays(List<RepeatDay> days) {
    state = state.copyWith(repeatDays: days);
  }

  void setMode(StopMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setProtocol(String protocolId) {
    state = state.copyWith(protocolId: protocolId);
  }

  void setEnabled(bool enabled) {
    state = state.copyWith(isEnabled: enabled);
  }

  void setCustomTypeLabel(String label) {
    state = state.copyWith(customTypeLabel: label);
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  Future<bool> saveAlarm() async {
    state = state.copyWith(isSaving: true, error: null);

    try {
      // Request notification permission before saving alarm
      final notificationService = _notificationService;
      await notificationService.requestPermissionsIfNeeded();
      
      final now = DateTime.now();
      final alarm = StopAlarm(
        id: state.alarmId ?? Uuid().v4(),
        title: state.title,
        stopType: state.stopType,
        customTypeLabel: state.customTypeLabel,
        timeOfDayHour: state.hour,
        timeOfDayMinute: state.minute,
        repeatDays: state.repeatDays,
        mode: state.mode,
        protocolId: state.protocolId,
        isEnabled: state.isEnabled,
        createdAt: state.createdAt ?? now,
        updatedAt: now,
      );

      if (state.alarmId == null) {
        await _createAlarm(alarm);
      } else {
        await _updateAlarm(alarm);
      }

      await _notificationService.rescheduleAll(await _repository.getAlarms());

      state = state.copyWith(
        isSaving: false,
        isSaved: true,
        alarmId: alarm.id,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isSaved: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> deleteAlarm(String alarmId) async {
    try {
      await _repository.deleteAlarm(alarmId);
      await _notificationService.cancelStopAlarm(alarmId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void loadAlarm(StopAlarm alarm) {
    state = state.copyWith(
      alarmId: alarm.id,
      title: alarm.title,
      stopType: alarm.stopType,
      customTypeLabel: alarm.customTypeLabel,
      hour: alarm.timeOfDayHour,
      minute: alarm.timeOfDayMinute,
      repeatDays: alarm.repeatDays,
      mode: alarm.mode,
      protocolId: alarm.protocolId,
      isEnabled: alarm.isEnabled,
      createdAt: alarm.createdAt,
    );
  }

  void reset() {
    state = AlarmState.initial();
  }
}

final alarmControllerProvider = StateNotifierProvider<AlarmController, AlarmState>((ref) {
  final repository = ref.watch(alarmRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return AlarmController(
    CreateAlarm(repository),
    UpdateAlarm(repository),
    repository,
    notificationService,
  );
});
