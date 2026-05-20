import '../../domain/entities/stop_receipt.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../datasources/receipt_local_datasource.dart';
import '../models/stop_receipt_model.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDatasource _datasource;

  ReceiptRepositoryImpl(this._datasource);

  @override
  Future<List<StopReceipt>> getReceipts() async {
    try {
      final list = await _datasource.getReceipts();
      return list.map((json) => StopReceiptModel.fromJson(json)).toList();
    } catch (e) {
      print('[ReceiptRepository] Error getting receipts: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveReceipt(StopReceipt receipt) async {
    final json = StopReceiptModel.toJson(receipt);
    await _datasource.saveReceipt(receipt.id, json);
  }

  @override
  Future<void> deleteReceipt(String id) async {
    await _datasource.deleteReceipt(id);
  }
}
