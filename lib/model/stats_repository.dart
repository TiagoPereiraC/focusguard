import 'package:shared_preferences/shared_preferences.dart';

import 'focus_stats.dart';

class StatsRepository {
  static const String _totalSessionsKey = 'total_sessions';
  static const String _totalFocusSecondsKey = 'total_focus_seconds';
  static const String _currentComboKey = 'current_combo';
  static const String _bestComboKey = 'best_combo';

  Future<FocusStats> loadStats() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return FocusStats(
      totalSessions: prefs.getInt(_totalSessionsKey) ?? 0,
      totalFocusSeconds: prefs.getInt(_totalFocusSecondsKey) ?? 0,
      currentCombo: prefs.getInt(_currentComboKey) ?? 0,
      bestCombo: prefs.getInt(_bestComboKey) ?? 0,
    );
  }

  Future<void> saveStats(FocusStats stats) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setInt(_totalSessionsKey, stats.totalSessions),
      prefs.setInt(_totalFocusSecondsKey, stats.totalFocusSeconds),
      prefs.setInt(_currentComboKey, stats.currentCombo),
      prefs.setInt(_bestComboKey, stats.bestCombo),
    ]);
  }
}
