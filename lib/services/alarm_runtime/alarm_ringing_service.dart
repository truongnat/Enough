import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../features/alarms/domain/entities/stop_mode.dart';

class AlarmRingingService {
  static const String _assetPath = 'audio/reverse_alarm_ring.mp3';

  // Vibration patterns for different modes
  static const List<int> _generalPattern = [0, 700, 250, 700, 250, 1200];
  static const List<int> _strictPattern = [
    0,
    500,
    150,
    500,
    150,
    500,
    150,
    800,
  ];
  static const List<int> _memePattern = [0, 300, 200, 300, 200, 300, 200, 500];

  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _fallbackAlertTimer;
  bool _isRinging = false;
  String? _alarmId;

  bool get isRinging => _isRinging;
  String? get alarmId => _alarmId;

  Future<void> startRinging({
    required String alarmId,
    StopMode mode = StopMode.general,
  }) async {
    await stopRinging();
    _alarmId = alarmId;

    await _startAudio(mode);
    await startVibration(mode);
    _isRinging = true;
  }

  double _getVolumeForMode(StopMode mode) {
    switch (mode) {
      case StopMode.strict:
        return 1.0; // Max volume for strict mode
      case StopMode.general:
        return 0.7; // Softer volume for general mode
      case StopMode.meme:
        return 0.8; // Medium volume for meme mode
    }
  }

  List<int> _getPatternForMode(StopMode mode) {
    switch (mode) {
      case StopMode.strict:
        return _strictPattern;
      case StopMode.general:
        return _generalPattern;
      case StopMode.meme:
        return _memePattern;
    }
  }

  Future<void> _startAudio(StopMode mode) async {
    try {
      final volume = _getVolumeForMode(mode);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource(_assetPath), volume: volume);
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

  Future<void> startVibration(StopMode mode) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (!hasVibrator) return;
      final pattern = _getPatternForMode(mode);
      await Vibration.vibrate(pattern: pattern, repeat: 0);
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
