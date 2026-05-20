import '../../../../../services/storage/local_storage_service.dart';

class ReceiptLocalDatasource {
  final LocalStorageService _storageService;

  ReceiptLocalDatasource(this._storageService);

  Future<List<Map<String, dynamic>>> getReceipts() async {
    return _storageService.getReceipts();
  }

  Future<void> saveReceipt(String id, Map<String, dynamic> receiptJson) async {
    await _storageService.saveReceipt(id, receiptJson);
  }

  Future<void> deleteReceipt(String id) async {
    await _storageService.deleteReceipt(id);
  }
}
