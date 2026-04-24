import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:sensors_plus/sensors_plus.dart';

import '../model/focus_mode.dart';
import '../model/focus_sensitivity_mode.dart';
import '../model/focus_stats.dart';
import '../model/notification_preferences.dart';
import '../model/stats_repository.dart';
import '../services/notification_service.dart';
import 'base_viewmodel.dart';

class FocusViewModel extends BaseViewModel {
  final StatsRepository _repository;
  final NotificationService _notificationService;
  NotificationPreferences _notificationPreferences;
  FocusSensitivityMode _sensitivityMode;
  bool _initialized = false;
  bool _gyroscopeAvailable = true;

  static const String _gyroscopeUnavailableMessage =
      'Este dispositivo no tiene giroscopio disponible para sesiones de foco.';

  static const int _sessionNotificationId = 1001;
  static const int _interruptionNotificationId = 1002;

  Timer? _timer;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<UserAccelerometerEvent>? _userAccelerometerSubscription;

  FocusStats _stats = FocusStats.initial();
  FocusMode _mode = FocusMode.idle;
  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  bool _phoneTurned = false;

  double? _baseMagnitude;
  double? _baseX;
  double? _baseY;
  double? _baseZ;
  int _accelEvidenceSamples = 0;
  int _gyroEvidenceSamples = 0;
  int _linearEvidenceSamples = 0;
  int _fusedEvidenceSamples = 0;
  DateTime? _lastGyroEvidenceAt;
  DateTime? _lastLinearEvidenceAt;
  bool _interruptionInProgress = false;

  FocusViewModel({
    required StatsRepository repository,
    required NotificationService notificationService,
    NotificationPreferences notificationPreferences =
        const NotificationPreferences(),
    FocusSensitivityMode sensitivityMode = FocusSensitivityMode.balanced,
  }) : _repository = repository,
       _notificationService = notificationService,
       _notificationPreferences = notificationPreferences,
       _sensitivityMode = sensitivityMode;

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
  bool get isGyroscopeAvailable => _gyroscopeAvailable;
  FocusSensitivityMode get sensitivityMode => _sensitivityMode;

  void updateNotificationPreferences(NotificationPreferences preferences) {
    _notificationPreferences = preferences;
  }

  void updateSensitivityMode(FocusSensitivityMode mode) {
    _sensitivityMode = mode;
  }

  double get _accelAngleThreshold {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 36;
      case FocusSensitivityMode.balanced:
        return 28;
      case FocusSensitivityMode.high:
        return 22;
      case FocusSensitivityMode.extreme:
        return 16;
    }
  }

  double get _accelDeltaThreshold {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 2.8;
      case FocusSensitivityMode.balanced:
        return 2.2;
      case FocusSensitivityMode.high:
        return 1.8;
      case FocusSensitivityMode.extreme:
        return 1.3;
    }
  }

  double get _gyroVelocityThreshold {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 1.4;
      case FocusSensitivityMode.balanced:
        return 1.0;
      case FocusSensitivityMode.high:
        return 0.7;
      case FocusSensitivityMode.extreme:
        return 0.5;
    }
  }

  int get _requiredAccelSamples {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 3;
      case FocusSensitivityMode.balanced:
        return 2;
      case FocusSensitivityMode.high:
        return 2;
      case FocusSensitivityMode.extreme:
        return 1;
    }
  }

  int get _requiredGyroSamples {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 2;
      case FocusSensitivityMode.balanced:
        return 2;
      case FocusSensitivityMode.high:
        return 1;
      case FocusSensitivityMode.extreme:
        return 1;
    }
  }

  int get _requiredFusedSamples {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 2;
      case FocusSensitivityMode.balanced:
        return 2;
      case FocusSensitivityMode.high:
        return 1;
      case FocusSensitivityMode.extreme:
        return 1;
    }
  }

  double get _linearAccelerationThreshold {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 1.3;
      case FocusSensitivityMode.balanced:
        return 0.9;
      case FocusSensitivityMode.high:
        return 0.65;
      case FocusSensitivityMode.extreme:
        return 0.45;
    }
  }

  int get _requiredLinearSamples {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 5;
      case FocusSensitivityMode.balanced:
        return 4;
      case FocusSensitivityMode.high:
        return 3;
      case FocusSensitivityMode.extreme:
        return 2;
    }
  }

  int get _gyroEvidenceWindowMs {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 1100;
      case FocusSensitivityMode.balanced:
        return 1400;
      case FocusSensitivityMode.high:
        return 1700;
      case FocusSensitivityMode.extreme:
        return 2000;
    }
  }

  int get _linearEvidenceWindowMs {
    switch (_sensitivityMode) {
      case FocusSensitivityMode.low:
        return 1200;
      case FocusSensitivityMode.balanced:
        return 1600;
      case FocusSensitivityMode.high:
        return 1900;
      case FocusSensitivityMode.extreme:
        return 2200;
    }
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _loadStats();
    await _validateGyroscopeAvailability();
  }

  Future<void> _validateGyroscopeAvailability() async {
    try {
      await gyroscopeEventStream().first.timeout(const Duration(seconds: 2));
      _gyroscopeAvailable = true;
    } on TimeoutException {
      _gyroscopeAvailable = false;
      setError(_gyroscopeUnavailableMessage);
    } catch (_) {
      _gyroscopeAvailable = false;
      setError(_gyroscopeUnavailableMessage);
    }
  }

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

    if (!_gyroscopeAvailable) {
      setError(_gyroscopeUnavailableMessage);
      return;
    }

    final bool wasPaused = isPaused;

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

    final bool shouldNotify = wasPaused
        ? _notificationPreferences.sessionResumed
        : _notificationPreferences.sessionStarted;
    if (shouldNotify) {
      unawaited(
        _showSessionNotification(
          title: wasPaused ? 'Sesion reanudada' : 'Sesion iniciada',
          body: wasPaused
              ? 'Continua con ${formatRemainingTime()} restantes.'
              : 'Tu sesion de $_selectedMinutes minutos ya esta en marcha.',
        ),
      );
    }

    notifyListeners();
  }

  void pauseSession() {
    if (!isRunning) {
      return;
    }

    _timer?.cancel();
    _stopRotationDetection();
    _mode = FocusMode.paused;
    if (_notificationPreferences.sessionPaused) {
      unawaited(
        _showSessionNotification(
          title: 'Sesion pausada',
          body: 'Has detenido la sesion con ${formatRemainingTime()} restantes.',
        ),
      );
    }
    notifyListeners();
  }

  void resetSession() {
    final FocusMode previousMode = _mode;

    _timer?.cancel();
    _stopRotationDetection();
    _remainingSeconds = _selectedMinutes * 60;
    _phoneTurned = false;
    _mode = FocusMode.idle;

    if (previousMode != FocusMode.idle && _notificationPreferences.sessionReset) {
      unawaited(
        _showSessionNotification(
          title: 'Sesion reiniciada',
          body: 'La sesion volvio a $_selectedMinutes minutos.',
        ),
      );
    }

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
    if (_notificationPreferences.sessionCompleted) {
      await _showSessionNotification(
        title: 'Sesion completada',
        body: 'Sumaste una sesion mas. Combo actual: $updatedCombo.',
      );
    }
    notifyListeners();

    await _persistStats();
  }

  Future<void> _interruptSessionByRotation() async {
    if (_interruptionInProgress) {
      return;
    }
    _interruptionInProgress = true;

    _timer?.cancel();
    _stopRotationDetection();

    _phoneTurned = true;
    _stats = _stats.copyWith(currentCombo: 0);
    _mode = FocusMode.interrupted;
    if (_notificationPreferences.sessionInterrupted) {
      unawaited(_notificationService.vibrateInterruptionAlert());
      await _showSessionNotification(
        id: _interruptionNotificationId,
        title: 'Sesion interrumpida',
        body: 'Se detecto un giro del telefono y el combo se reinicio.',
        vibrationPattern: Int64List.fromList(<int>[0, 350, 180, 600]),
      );
    }
    notifyListeners();

    await _persistStats();
    _interruptionInProgress = false;
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
    _accelEvidenceSamples = 0;
    _gyroEvidenceSamples = 0;
    _linearEvidenceSamples = 0;
    _fusedEvidenceSamples = 0;
    _lastGyroEvidenceAt = null;
    _lastLinearEvidenceAt = null;
    _interruptionInProgress = false;

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

      if (angleDegrees > _accelAngleThreshold || delta > _accelDeltaThreshold) {
        _accelEvidenceSamples = (_accelEvidenceSamples + 1).clamp(0, 12);
      } else {
        _accelEvidenceSamples = (_accelEvidenceSamples - 1).clamp(0, 12);
      }

      _tryTriggerInterruption();
    });

    _gyroscopeSubscription = gyroscopeEventStream().listen((
      GyroscopeEvent event,
    ) {
      if (!isRunning) {
        return;
      }

      final double angularVelocity = sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );

      if (angularVelocity > _gyroVelocityThreshold) {
        _gyroEvidenceSamples = (_gyroEvidenceSamples + 1).clamp(0, 14);
        _lastGyroEvidenceAt = DateTime.now();
      } else {
        _gyroEvidenceSamples = (_gyroEvidenceSamples - 1).clamp(0, 14);
      }

      _tryTriggerInterruption();
    });

    _userAccelerometerSubscription = userAccelerometerEventStream().listen((
      UserAccelerometerEvent event,
    ) {
      if (!isRunning) {
        return;
      }

      final double horizontalLinearMotion = sqrt(
        (event.x * event.x) + (event.y * event.y),
      );
      final double linearMagnitude = sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );

      final bool strongLinearMovement =
          horizontalLinearMotion > _linearAccelerationThreshold ||
          linearMagnitude > (_linearAccelerationThreshold + 0.7);

      if (strongLinearMovement) {
        _linearEvidenceSamples = (_linearEvidenceSamples + 1).clamp(0, 16);
        _lastLinearEvidenceAt = DateTime.now();
      } else {
        _linearEvidenceSamples = (_linearEvidenceSamples - 1).clamp(0, 16);
      }

      _tryTriggerInterruption();
    });
  }

  void _tryTriggerInterruption() {
    if (!isRunning || _interruptionInProgress) {
      return;
    }

    final DateTime now = DateTime.now();
    final bool hasRecentGyroEvidence =
        _lastGyroEvidenceAt != null &&
        now.difference(_lastGyroEvidenceAt!).inMilliseconds <=
            _gyroEvidenceWindowMs;
    final bool hasRecentLinearEvidence =
      _lastLinearEvidenceAt != null &&
      now.difference(_lastLinearEvidenceAt!).inMilliseconds <=
        _linearEvidenceWindowMs;

    final bool accelEvidenceReady = _accelEvidenceSamples >= _requiredAccelSamples;
    final bool gyroEvidenceReady = _gyroEvidenceSamples >= _requiredGyroSamples;
    final bool linearEvidenceReady =
      _linearEvidenceSamples >= _requiredLinearSamples;

    final bool fusedByRotation =
      accelEvidenceReady && gyroEvidenceReady && hasRecentGyroEvidence;

    // Fallback path for desk sliding: sustained linear movement can interrupt
    // even when orientation does not change enough for accelerometer angle.
    final bool fusedByLinearMovement =
      linearEvidenceReady && hasRecentLinearEvidence;

    if (fusedByRotation || fusedByLinearMovement) {
      _fusedEvidenceSamples = (_fusedEvidenceSamples + 1).clamp(0, 6);
    } else {
      _fusedEvidenceSamples = (_fusedEvidenceSamples - 1).clamp(0, 6);
    }

    if (_fusedEvidenceSamples >= _requiredFusedSamples) {
      _interruptSessionByRotation();
    }
  }

  void _stopRotationDetection() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
    _userAccelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _userAccelerometerSubscription = null;
    _baseMagnitude = null;
    _baseX = null;
    _baseY = null;
    _baseZ = null;
    _accelEvidenceSamples = 0;
    _gyroEvidenceSamples = 0;
    _linearEvidenceSamples = 0;
    _fusedEvidenceSamples = 0;
    _lastGyroEvidenceAt = null;
    _lastLinearEvidenceAt = null;
    _interruptionInProgress = false;
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

  Future<void> _showSessionNotification({
    int? id,
    required String title,
    required String body,
    Int64List? vibrationPattern,
  }) async {
    final bool isInterruptionNotification = id == _interruptionNotificationId;

    await _notificationService.showNotification(
      id: id ?? _sessionNotificationId,
      title: title,
      body: body,
      payload: _mode.name,
      vibrationPattern: vibrationPattern,
      channelId: isInterruptionNotification
          ? 'focusguard_interruption_channel'
          : 'focusguard_channel',
      channelName: isInterruptionNotification
          ? 'Focus Interrupted Alerts'
          : 'Focus Sessions',
      channelDescription: isInterruptionNotification
          ? 'High-priority alerts when a focus session is interrupted'
          : 'Notifications for focus session events',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopRotationDetection();
    super.dispose();
  }
}
