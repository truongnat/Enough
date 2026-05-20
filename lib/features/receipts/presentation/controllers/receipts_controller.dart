import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/stop_receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../../../app/di/providers.dart';

class ReceiptsController extends StateNotifier<ReceiptsState> {
  final ReceiptRepository _repository;

  ReceiptsController(this._repository) : super(ReceiptsState.initial()) {
    loadReceipts();
  }

  Future<void> loadReceipts() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final receipts = await _repository.getReceipts();
      state = state.copyWith(
        receipts: receipts,
        filteredReceipts: receipts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void filterByStatus(String? status) {
    final allReceipts = state.receipts;
    
    if (status == null || status == 'all') {
      state = state.copyWith(filteredReceipts: allReceipts);
      return;
    }

    // For now, all receipts are success
    // When we add session history with snooze/missed, we'll filter accordingly
    state = state.copyWith(filteredReceipts: allReceipts);
  }

  Future<void> deleteReceipt(String receiptId) async {
    try {
      await _repository.deleteReceipt(receiptId);
      await loadReceipts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

class ReceiptsState {
  final List<StopReceipt> receipts;
  final List<StopReceipt> filteredReceipts;
  final bool isLoading;
  final String? error;

  ReceiptsState({
    required this.receipts,
    required this.filteredReceipts,
    required this.isLoading,
    this.error,
  });

  factory ReceiptsState.initial() {
    return ReceiptsState(
      receipts: [],
      filteredReceipts: [],
      isLoading: false,
      error: null,
    );
  }

  ReceiptsState copyWith({
    List<StopReceipt>? receipts,
    List<StopReceipt>? filteredReceipts,
    bool? isLoading,
    String? error,
  }) {
    return ReceiptsState(
      receipts: receipts ?? this.receipts,
      filteredReceipts: filteredReceipts ?? this.filteredReceipts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Provider
final receiptsControllerProvider = StateNotifierProvider<ReceiptsController, ReceiptsState>((ref) {
  final repository = ref.watch(receiptRepositoryProvider);
  return ReceiptsController(repository);
});
