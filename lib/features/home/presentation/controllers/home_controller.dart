import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_next_alarm.dart';
import '../../domain/usecases/get_today_stats.dart';
import '../../domain/usecases/get_latest_receipt.dart';
import '../../../../app/di/providers.dart';
import '../../../alarms/domain/entities/stop_alarm.dart';
import '../../../receipts/domain/entities/stop_receipt.dart';

class HomeController extends StateNotifier<HomeState> {
  final GetNextAlarm _getNextAlarm;
  final GetTodayStats _getTodayStats;
  final GetLatestReceipt _getLatestReceipt;

  HomeController(
    this._getNextAlarm,
    this._getTodayStats,
    this._getLatestReceipt,
  ) : super(HomeState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final nextAlarm = await _getNextAlarm();
      final stats = await _getTodayStats();
      final latestReceipt = await _getLatestReceipt();
      
      state = state.copyWith(
        nextAlarm: nextAlarm,
        stoppedCount: stats['stoppedCount'] ?? 0,
        latestReceipt: latestReceipt,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void refresh() {
    loadData();
  }
}

class HomeState {
  final StopAlarm? nextAlarm;
  final int stoppedCount;
  final StopReceipt? latestReceipt;
  final bool isLoading;
  final String? error;

  HomeState({
    this.nextAlarm,
    required this.stoppedCount,
    this.latestReceipt,
    required this.isLoading,
    this.error,
  });

  factory HomeState.initial() {
    return HomeState(
      nextAlarm: null,
      stoppedCount: 0,
      latestReceipt: null,
      isLoading: false,
      error: null,
    );
  }

  HomeState copyWith({
    StopAlarm? nextAlarm,
    int? stoppedCount,
    StopReceipt? latestReceipt,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      nextAlarm: nextAlarm ?? this.nextAlarm,
      stoppedCount: stoppedCount ?? this.stoppedCount,
      latestReceipt: latestReceipt ?? this.latestReceipt,
      isLoading: isLoading ?? this.isLoading,
      error: error,
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
  
  return HomeController(getNextAlarm, getTodayStats, getLatestReceipt);
});
