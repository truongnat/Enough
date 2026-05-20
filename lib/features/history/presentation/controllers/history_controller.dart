import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../stop_session/domain/entities/stop_session.dart';
import '../../../stop_session/domain/entities/stop_session_status.dart';
import '../../../stop_session/domain/repositories/stop_session_repository.dart';
import '../../../receipts/domain/entities/stop_receipt.dart';
import '../../../receipts/domain/repositories/receipt_repository.dart';
import '../../../../app/di/providers.dart';

class HistoryController extends StateNotifier<HistoryState> {
  final StopSessionRepository _sessionRepository;
  final ReceiptRepository _receiptRepository;

  HistoryController(
    this._sessionRepository,
    this._receiptRepository,
  ) : super(HistoryState.initial()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final sessions = await _sessionRepository.getSessions();
      final receipts = await _receiptRepository.getReceipts();
      
      // Sort sessions descending by startedAt
      sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

      state = state.copyWith(
        sessions: sessions,
        filteredSessions: sessions, // Match 'all' initially
        receipts: receipts,
        selectedFilter: 'all',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
    _applyFilter();
  }

  void _applyFilter() {
    final sessions = state.sessions;
    String filter = state.selectedFilter;

    List<StopSession> filtered;
    switch (filter) {
      case 'success':
        filtered = sessions.where((s) => s.status == StopSessionStatus.completed).toList();
        break;
      case 'snooze':
        filtered = sessions.where((s) => s.status == StopSessionStatus.snoozed).toList();
        break;
      case 'missed':
        filtered = sessions.where((s) => s.status == StopSessionStatus.missed).toList();
        break;
      default:
        filtered = sessions;
    }

    state = state.copyWith(filteredSessions: filtered);
  }

  void refresh() {
    loadHistory();
  }
}

class HistoryState {
  final List<StopSession> sessions;
  final List<StopSession> filteredSessions;
  final List<StopReceipt> receipts;
  final String selectedFilter;
  final bool isLoading;
  final String? error;

  HistoryState({
    required this.sessions,
    required this.filteredSessions,
    required this.receipts,
    required this.selectedFilter,
    required this.isLoading,
    this.error,
  });

  factory HistoryState.initial() {
    return HistoryState(
      sessions: [],
      filteredSessions: [],
      receipts: [],
      selectedFilter: 'all',
      isLoading: false,
    );
  }

  HistoryState copyWith({
    List<StopSession>? sessions,
    List<StopSession>? filteredSessions,
    List<StopReceipt>? receipts,
    String? selectedFilter,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      sessions: sessions ?? this.sessions,
      filteredSessions: filteredSessions ?? this.filteredSessions,
      receipts: receipts ?? this.receipts,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final historyControllerProvider = StateNotifierProvider<HistoryController, HistoryState>((ref) {
  final sessionRepository = ref.watch(stopSessionRepositoryProvider);
  final receiptRepository = ref.watch(receiptRepositoryProvider);
  return HistoryController(sessionRepository, receiptRepository);
});
