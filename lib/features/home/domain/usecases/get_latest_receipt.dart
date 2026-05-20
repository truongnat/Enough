import '../../../receipts/domain/entities/stop_receipt.dart';
import '../../../receipts/domain/repositories/receipt_repository.dart';

class GetLatestReceipt {
  final ReceiptRepository repository;

  GetLatestReceipt(this.repository);

  Future<StopReceipt?> call() async {
    final receipts = await repository.getReceipts();
    if (receipts.isEmpty) return null;
    
    // Sort by createdAt descending and return first
    receipts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return receipts.first;
  }
}
