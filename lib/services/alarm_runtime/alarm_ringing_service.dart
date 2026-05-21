import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class AlarmRingingService {
  static const String _assetPath = 'audio/reverse_alarm_ring.mp3';
  static const List<int> _pattern = [0, 700, 250, 700, 250, 1200];

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _fallbackAlertTimer;
  bool _isRinging = false;
  String? _alarmId;

  bool get isRinging => _isRinging;
  String? get alarmId => _alarmId;

  Future<void> startRinging({required String alarmId}) async {
    await stopRinging();
    _alarmId = alarmId;

    await _startAudio();
    await startVibration();
    _isRinging = true;
  }

  Future<void> _startAudio() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(_assetPath), volume: 1.0);
      return;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[AlarmRingingService] Missing or invalid audio asset at $_assetPath. Falling back to periodic system alert. Error: $error',
        );
      }
    }

    _fallbackAlertTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      SystemSound.play(SystemSoundType.alert);
    });
  }

  Future<void> startVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) return;
      await Vibration.vibrate(pattern: _pattern, repeat: 0);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AlarmRingingService] Vibration unavailable: $error');
      }
    }
  }

  Future<void> stopVibration() async {
    try {
      await Vibration.cancel();
    } catch (_) {}
  }

  Future<void> stopRinging() async {
    _fallbackAlertTimer?.cancel();
    _fallbackAlertTimer = null;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    await stopVibration();
    _isRinging = false;
    _alarmId = null;
  }

  Future<void> dispose() async {
    await stopRinging();
    await _audioPlayer.dispose();
  }
}
