import 'package:hive_flutter/hive_flutter.dart';
import 'hive_boxes.dart';

class LocalStorageService {
  LocalStorageService();

  Future<void> init() async {
    await Hive.initFlutter();
    await openBoxes();
  }

  Future<void> openBoxes() async {
    await Future.wait([
      Hive.openBox<Map>(HiveBoxes.alarms),
      Hive.openBox<Map>(HiveBoxes.receipts),
      Hive.openBox<Map>(HiveBoxes.settings),
      Hive.openBox<Map>(HiveBoxes.sessions),
    ]);
  }

  Box<Map> get _alarmsBox => Hive.box<Map>(HiveBoxes.alarms);
  Box<Map> get _receiptsBox => Hive.box<Map>(HiveBoxes.receipts);
  Box<Map> get _settingsBox => Hive.box<Map>(HiveBoxes.settings);
  Box<Map> get _sessionsBox => Hive.box<Map>(HiveBoxes.sessions);

  // General Alarms operations
  List<Map<String, dynamic>> getAlarms() {
    return _alarmsBox.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> saveAlarm(String id, Map<String, dynamic> alarmJson) async {
    await _alarmsBox.put(id, alarmJson);
  }

  Future<void> deleteAlarm(String id) async {
    await _alarmsBox.delete(id);
  }

  // General Receipts / History operations
  List<Map<String, dynamic>> getReceipts() {
    return _receiptsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> saveReceipt(String id, Map<String, dynamic> receiptJson) async {
    await _receiptsBox.put(id, receiptJson);
  }

  Future<void> deleteReceipt(String id) async {
    await _receiptsBox.delete(id);
  }

  // General Settings operations
  Map<String, dynamic>? getSettings(String key) {
    final value = _settingsBox.get(key);
    if (value == null) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<void> saveSettings(
    String key,
    Map<String, dynamic> settingsJson,
  ) async {
    await _settingsBox.put(key, settingsJson);
  }

  Future<void> clearAllData() async {
    await _alarmsBox.clear();
    await _receiptsBox.clear();
    await _settingsBox.clear();
    await _sessionsBox.clear();
  }

  // Stop Session operations
  List<Map<String, dynamic>> getSessions() {
    return _sessionsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> saveSession(String id, Map<String, dynamic> sessionJson) async {
    await _sessionsBox.put(id, sessionJson);
  }

  Future<void> deleteSession(String id) async {
    await _sessionsBox.delete(id);
  }

  // Export all data as JSON
  Map<String, dynamic> exportAllData() {
    return {
      'alarms': getAlarms(),
      'receipts': getReceipts(),
      'sessions': getSessions(),
      'settings': getSettings('appSettings'),
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
  }

  // Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllData();

    // Import alarms
    if (data['alarms'] != null) {
      for (var alarm in data['alarms'] as List) {
        if (alarm is Map<String, dynamic>) {
          await saveAlarm(alarm['id'] as String, alarm);
        }
      }
    }

    // Import receipts
    if (data['receipts'] != null) {
      for (var receipt in data['receipts'] as List) {
        if (receipt is Map<String, dynamic>) {
          await saveReceipt(receipt['id'] as String, receipt);
        }
      }
    }

    // Import sessions
    if (data['sessions'] != null) {
      for (var session in data['sessions'] as List) {
        if (session is Map<String, dynamic>) {
          await saveSession(session['id'] as String, session);
        }
      }
    }

    // Import settings
    if (data['settings'] != null && data['settings'] is Map<String, dynamic>) {
      await saveSettings(
        'appSettings',
        data['settings'] as Map<String, dynamic>,
      );
    }
  }
}
