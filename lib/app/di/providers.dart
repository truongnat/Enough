import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reverse_alarm/services/storage/local_storage_service.dart';
import 'package:reverse_alarm/services/notifications/notification_service.dart';
import 'package:reverse_alarm/features/alarms/data/datasources/alarm_local_datasource.dart';
import 'package:reverse_alarm/features/alarms/data/repositories/alarm_repository_impl.dart';
import 'package:reverse_alarm/features/alarms/domain/repositories/alarm_repository.dart';
import 'package:reverse_alarm/features/receipts/data/datasources/receipt_local_datasource.dart';
import 'package:reverse_alarm/features/receipts/data/repositories/receipt_repository_impl.dart';
import 'package:reverse_alarm/features/receipts/domain/repositories/receipt_repository.dart';
import 'package:reverse_alarm/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:reverse_alarm/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:reverse_alarm/features/settings/domain/repositories/settings_repository.dart';
import 'package:reverse_alarm/features/stop_session/data/datasources/stop_session_local_datasource.dart';
import 'package:reverse_alarm/features/stop_session/data/repositories/stop_session_repository_impl.dart';
import 'package:reverse_alarm/features/stop_session/domain/repositories/stop_session_repository.dart';

// 1. Services Providers
final storageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// 2. Datasource Providers
final alarmLocalDatasourceProvider = Provider<AlarmLocalDatasource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AlarmLocalDatasource(storage);
});

final receiptLocalDatasourceProvider = Provider<ReceiptLocalDatasource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ReceiptLocalDatasource(storage);
});

final settingsLocalDatasourceProvider = Provider<SettingsLocalDatasource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsLocalDatasource(storage);
});

final stopSessionLocalDatasourceProvider = Provider<StopSessionLocalDatasource>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return StopSessionLocalDatasource(storage);
});

// 3. Repository Providers
final alarmRepositoryProvider = Provider<AlarmRepository>((ref) {
  final datasource = ref.watch(alarmLocalDatasourceProvider);
  return AlarmRepositoryImpl(datasource) as AlarmRepository;
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final datasource = ref.watch(receiptLocalDatasourceProvider);
  return ReceiptRepositoryImpl(datasource) as ReceiptRepository;
});

final stopSessionRepositoryProvider = Provider<StopSessionRepository>((ref) {
  final datasource = ref.watch(stopSessionLocalDatasourceProvider);
  return StopSessionRepositoryImpl(datasource);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final datasource = ref.watch(settingsLocalDatasourceProvider);
  return SettingsRepositoryImpl(datasource);
});
