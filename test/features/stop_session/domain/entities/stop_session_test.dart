import 'package:flutter_test/flutter_test.dart';
import 'package:reverse_alarm/features/stop_session/domain/entities/stop_session.dart';
import 'package:reverse_alarm/features/stop_session/domain/entities/stop_session_status.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_type.dart';
import 'package:reverse_alarm/features/alarms/domain/entities/stop_mode.dart';

void main() {
  group('StopSession - Business Rules', () {
    test('canComplete should return false when no steps checked', () {
      final session = StopSession(
        id: '1',
        alarmId: 'alarm1',
        stopType: StopType.coding,
        startedAt: DateTime.now(),
        status: StopSessionStatus.active,
        snoozeCount: 0,
        checkedStepIndexes: [],
      );

      expect(session.canComplete, isFalse);
    });

    test('canComplete should return true when at least one step checked', () {
      final session = StopSession(
        id: '1',
        alarmId: 'alarm1',
        stopType: StopType.coding,
        startedAt: DateTime.now(),
        status: StopSessionStatus.active,
        snoozeCount: 0,
        checkedStepIndexes: [0],
      );

      expect(session.canComplete, isTrue);
    });

    test('isMissed should return true for active session older than 2 hours', () {
      final session = StopSession(
        id: '1',
        alarmId: 'alarm1',
        stopType: StopType.coding,
        startedAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: StopSessionStatus.active,
        snoozeCount: 0,
        checkedStepIndexes: [],
      );

      expect(session.isMissed(DateTime.now()), isTrue);
    });

    test('isMissed should return false for active session younger than 2 hours', () {
      final session = StopSession(
        id: '1',
        alarmId: 'alarm1',
        stopType: StopType.coding,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: StopSessionStatus.active,
        snoozeCount: 0,
        checkedStepIndexes: [],
      );

      expect(session.isMissed(DateTime.now()), isFalse);
    });

    test('isMissed should return false for completed session', () {
      final session = StopSession(
        id: '1',
        alarmId: 'alarm1',
        stopType: StopType.coding,
        startedAt: DateTime.now().subtract(const Duration(hours: 3)),
        completedAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: StopSessionStatus.completed,
        snoozeCount: 0,
        checkedStepIndexes: [0],
      );

      expect(session.isMissed(DateTime.now()), isFalse);
    });

    test('getWittyQuote should return gentle mode quote', () {
      final quote = StopSession.getWittyQuote(StopMode.gentle, 0);
      expect(quote, isNotEmpty);
      expect(quote.contains('Đủ rồi'), isTrue);
    });

    test('getWittyQuote should return strict mode quote', () {
      final quote = StopSession.getWittyQuote(StopMode.strict, 0);
      expect(quote, isNotEmpty);
      expect(quote.contains('tự bào pin'), isTrue);
    });

    test('getWittyQuote should return meme mode quote', () {
      final quote = StopSession.getWittyQuote(StopMode.meme, 0);
      expect(quote, isNotEmpty);
      expect(quote.contains('chiến thần') || quote.contains('server'), isTrue);
    });
  });
}
