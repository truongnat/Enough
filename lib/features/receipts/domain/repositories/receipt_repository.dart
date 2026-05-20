import '../entities/stop_receipt.dart';

abstract class ReceiptRepository {
  Future<List<StopReceipt>> getReceipts();
  Future<void> saveReceipt(StopReceipt receipt);
  Future<void> deleteReceipt(String id);
}
