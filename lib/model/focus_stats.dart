class FocusStats {
  final int totalSessions;
  final int totalFocusSeconds;
  final int currentCombo;
  final int bestCombo;

  const FocusStats({
    required this.totalSessions,
    required this.totalFocusSeconds,
    required this.currentCombo,
    required this.bestCombo,
  });

  factory FocusStats.initial() {
    return const FocusStats(
      totalSessions: 0,
      totalFocusSeconds: 0,
      currentCombo: 0,
      bestCombo: 0,
    );
  }

  FocusStats copyWith({
    int? totalSessions,
    int? totalFocusSeconds,
    int? currentCombo,
    int? bestCombo,
  }) {
    return FocusStats(
      totalSessions: totalSessions ?? this.totalSessions,
      totalFocusSeconds: totalFocusSeconds ?? this.totalFocusSeconds,
      currentCombo: currentCombo ?? this.currentCombo,
      bestCombo: bestCombo ?? this.bestCombo,
    );
  }

  Map<String, int> toMap() {
    return {
      'totalSessions': totalSessions,
      'totalFocusSeconds': totalFocusSeconds,
      'currentCombo': currentCombo,
      'bestCombo': bestCombo,
    };
  }

  factory FocusStats.fromMap(Map<String, Object?> map) {
    return FocusStats(
      totalSessions: map['totalSessions'] as int? ?? 0,
      totalFocusSeconds: map['totalFocusSeconds'] as int? ?? 0,
      currentCombo: map['currentCombo'] as int? ?? 0,
      bestCombo: map['bestCombo'] as int? ?? 0,
    );
  }
}
