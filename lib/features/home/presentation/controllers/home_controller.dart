import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_next_alarm.dart';
import '../../domain/usecases/get_today_stats.dart';
import '../../domain/usecases/get_latest_receipt.dart';
import '../../../../app/di/providers.dart';
import '../../../alarms/domain/entities/stop_alarm.dart';
import '../../../alarms/domain/repositories/alarm_repository.dart';
import '../../../receipts/domain/entities/stop_receipt.dart';

class HomeController extends StateNotifier<HomeState> {
  final GetNextAlarm _getNextAlarm;
  final GetTodayStats _getTodayStats;
  final GetLatestReceipt _getLatestReceipt;
  final AlarmRepository _alarmRepository;

  HomeController(
    this._getNextAlarm,
    this._getTodayStats,
    this._getLatestReceipt,
    this._alarmRepository,
  ) : super(HomeState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final nextAlarm = await _getNextAlarm();
      final stats = await _getTodayStats();
      final latestReceipt = await _getLatestReceipt();
      final allAlarms = await _alarmRepository.getAlarms();
      
      // Sort alarms by next trigger time ascending
      final now = DateTime.now();
      allAlarms.sort((a, b) {
        final triggerA = a.getNextTrigger(now);
        final triggerB = b.getNextTrigger(now);
        return triggerA.compareTo(triggerB);
      });
      
      debugPrint('[HomeController] Loaded data. NextAlarm: ${nextAlarm?.id ?? 'null'} (${nextAlarm?.timeOfDayHour}:${nextAlarm?.timeOfDayMinute}), Alarms count: ${allAlarms.length}, StoppedCount: ${stats['stoppedCount']}, LatestReceipt: ${latestReceipt?.id ?? 'null'}');

      state = state.copyWith(
        nextAlarm: nextAlarm,
        alarms: allAlarms,
        stoppedCount: stats['stoppedCount'] ?? 0,
        latestReceipt: latestReceipt,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      debugPrint('[HomeController] Error loading data: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadData();
}

const _unset = Object();

class HomeState {
  final StopAlarm? nextAlarm;
  final List<StopAlarm> alarms;
  final int stoppedCount;
  final StopReceipt? latestReceipt;
  final bool isLoading;
  final String? error;

  HomeState({
    this.nextAlarm,
    required this.alarms,
    required this.stoppedCount,
    this.latestReceipt,
    required this.isLoading,
    this.error,
  });

  factory HomeState.initial() {
    return HomeState(
      nextAlarm: null,
      alarms: const [],
      stoppedCount: 0,
      latestReceipt: null,
      isLoading: false,
      error: null,
    );
  }

  HomeState copyWith({
    Object? nextAlarm = _unset,
    List<StopAlarm>? alarms,
    int? stoppedCount,
    Object? latestReceipt = _unset,
    bool? isLoading,
    Object? error = _unset,
  }) {
    return HomeState(
      nextAlarm: identical(nextAlarm, _unset)
          ? this.nextAlarm
          : nextAlarm as StopAlarm?,
      alarms: alarms ?? this.alarms,
      stoppedCount: stoppedCount ?? this.stoppedCount,
      latestReceipt: identical(latestReceipt, _unset)
          ? this.latestReceipt
          : latestReceipt as StopReceipt?,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

// Provider
final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  final alarmRepository = ref.watch(alarmRepositoryProvider);
  final receiptRepository = ref.watch(receiptRepositoryProvider);
  final sessionDatasource = ref.watch(stopSessionLocalDatasourceProvider);
  
  final getNextAlarm = GetNextAlarm(alarmRepository);
  final getTodayStats = GetTodayStats(receiptRepository, sessionDatasource);
  final getLatestReceipt = GetLatestReceipt(receiptRepository);
  
  return HomeController(getNextAlarm, getTodayStats, getLatestReceipt, alarmRepository);
});
