import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../model/focus_mode.dart';
import '../model/focus_stats.dart';
import '../model/stats_repository.dart';
import 'base_viewmodel.dart';

class FocusViewModel extends BaseViewModel {
  final StatsRepository _repository;

  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  FocusStats _stats = FocusStats.initial();
  FocusMode _mode = FocusMode.idle;
  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _phoneTurned = false;

  double? _baseMagnitude;
  double? _baseX;
  double? _baseY;
  double? _baseZ;
  int _rotationOverThresholdSamples = 0;

  FocusViewModel({required StatsRepository repository})
    : _repository = repository {
    _loadStats();
  }

  FocusStats get stats => _stats;
  FocusMode get mode => _mode;
  int get selectedMinutes => _selectedMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get phoneTurned => _phoneTurned;

  bool get canStart =>
      _mode == FocusMode.idle ||
      _mode == FocusMode.completed ||
      _mode == FocusMode.interrupted;
  bool get isRunning => _mode == FocusMode.running;
  bool get isPaused => _mode == FocusMode.paused;

  Future<void> _loadStats() async {
    setBusy(true);
    try {
      _stats = await _repository.loadStats();
      setError(null);
    } catch (_) {
      setError('No se pudieron cargar las estadisticas.');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void selectMinutes(int minutes) {
    if (isRunning || isPaused) {
      return;
    }

    _selectedMinutes = minutes;
    _remainingSeconds = minutes * 60;
    _phoneTurned = false;
    _mode = FocusMode.idle;
    notifyListeners();
  }

  void startSession() {
    if (isRunning) {
      return;
    }

    if (!isPaused) {
      _remainingSeconds = _selectedMinutes * 60;
    }

    _phoneTurned = false;
    _mode = FocusMode.running;

    _startRotationDetection();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _completeSession();
        return;
      }

      _remainingSeconds -= 1;
      notifyListeners();
    });

    notifyListeners();
  }

  void pauseSession() {
    if (!isRunning) {
      return;
    }

    _timer?.cancel();
    _stopRotationDetection();
    _mode = FocusMode.paused;
    notifyListeners();
  }

  void resetSession() {
    _timer?.cancel();
    _stopRotationDetection();
    _remainingSeconds = _selectedMinutes * 60;
    _phoneTurned = false;
    _mode = FocusMode.idle;
    notifyListeners();
  }

  Future<void> _completeSession() async {
    _timer?.cancel();
    _stopRotationDetection();

    final int updatedCombo = _stats.currentCombo + 1;
    _stats = _stats.copyWith(
      totalSessions: _stats.totalSessions + 1,
      totalFocusSeconds: _stats.totalFocusSeconds + (_selectedMinutes * 60),
      currentCombo: updatedCombo,
      bestCombo: max(_stats.bestCombo, updatedCombo),
    );

    _mode = FocusMode.completed;
    _remainingSeconds = 0;
    notifyListeners();

    await _persistStats();
  }

  Future<void> _interruptSessionByRotation() async {
    _timer?.cancel();
    _stopRotationDetection();

    _phoneTurned = true;
    _stats = _stats.copyWith(currentCombo: 0);
    _mode = FocusMode.interrupted;
    notifyListeners();

    await _persistStats();
  }

  Future<void> _persistStats() async {
    try {
      await _repository.saveStats(_stats);
      setError(null);
    } catch (_) {
      setError('No se pudieron guardar las estadisticas.');
    }
  }

  void _startRotationDetection() {
    _stopRotationDetection();
    _baseMagnitude = null;
    _baseX = null;
    _baseY = null;
    _baseZ = null;
    _rotationOverThresholdSamples = 0;

    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      if (!isRunning) {
        return;
      }

      final double magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      _baseMagnitude ??= magnitude;
      _baseX ??= event.x;
      _baseY ??= event.y;
      _baseZ ??= event.z;

      final double baseMagnitude = sqrt(
        _baseX! * _baseX! + _baseY! * _baseY! + _baseZ! * _baseZ!,
      );

      // Protect against invalid sensor values.
      if (magnitude < 0.1 || baseMagnitude < 0.1) {
        return;
      }

      final double dot =
          (_baseX! * event.x) + (_baseY! * event.y) + (_baseZ! * event.z);
      final double cosine = (dot / (baseMagnitude * magnitude)).clamp(
        -1.0,
        1.0,
      );
      final double angleDegrees = acos(cosine) * (180 / pi);

      final double delta = (_baseMagnitude! - magnitude).abs();

      // Trigger when orientation changes enough, including slow rotations.
      if (angleDegrees > 35 || delta > 3.2) {
        _rotationOverThresholdSamples += 1;
      } else {
        _rotationOverThresholdSamples = 0;
      }

      if (_rotationOverThresholdSamples >= 3) {
        _interruptSessionByRotation();
      }
    });
  }

  void _stopRotationDetection() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _baseMagnitude = null;
    _baseX = null;
    _baseY = null;
    _baseZ = null;
    _rotationOverThresholdSamples = 0;
  }

  String formatRemainingTime() {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String formatTotalFocusTime() {
    final int hours = _stats.totalFocusSeconds ~/ 3600;
    final int minutes = (_stats.totalFocusSeconds % 3600) ~/ 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopRotationDetection();
    super.dispose();
  }
}
