enum NotificationPreferenceType {
  sessionStarted,
  sessionResumed,
  sessionPaused,
  sessionReset,
  sessionCompleted,
  sessionInterrupted,
}

class NotificationPreferences {
  final bool sessionStarted;
  final bool sessionResumed;
  final bool sessionPaused;
  final bool sessionReset;
  final bool sessionCompleted;
  final bool sessionInterrupted;

  const NotificationPreferences({
    this.sessionStarted = true,
    this.sessionResumed = true,
    this.sessionPaused = true,
    this.sessionReset = true,
    this.sessionCompleted = true,
    this.sessionInterrupted = true,
  });

  NotificationPreferences copyWith({
    bool? sessionStarted,
    bool? sessionResumed,
    bool? sessionPaused,
    bool? sessionReset,
    bool? sessionCompleted,
    bool? sessionInterrupted,
  }) {
    return NotificationPreferences(
      sessionStarted: sessionStarted ?? this.sessionStarted,
      sessionResumed: sessionResumed ?? this.sessionResumed,
      sessionPaused: sessionPaused ?? this.sessionPaused,
      sessionReset: sessionReset ?? this.sessionReset,
      sessionCompleted: sessionCompleted ?? this.sessionCompleted,
      sessionInterrupted: sessionInterrupted ?? this.sessionInterrupted,
    );
  }

  bool valueFor(NotificationPreferenceType type) {
    switch (type) {
      case NotificationPreferenceType.sessionStarted:
        return sessionStarted;
      case NotificationPreferenceType.sessionResumed:
        return sessionResumed;
      case NotificationPreferenceType.sessionPaused:
        return sessionPaused;
      case NotificationPreferenceType.sessionReset:
        return sessionReset;
      case NotificationPreferenceType.sessionCompleted:
        return sessionCompleted;
      case NotificationPreferenceType.sessionInterrupted:
        return sessionInterrupted;
    }
  }

  NotificationPreferences setValue(
    NotificationPreferenceType type,
    bool enabled,
  ) {
    switch (type) {
      case NotificationPreferenceType.sessionStarted:
        return copyWith(sessionStarted: enabled);
      case NotificationPreferenceType.sessionResumed:
        return copyWith(sessionResumed: enabled);
      case NotificationPreferenceType.sessionPaused:
        return copyWith(sessionPaused: enabled);
      case NotificationPreferenceType.sessionReset:
        return copyWith(sessionReset: enabled);
      case NotificationPreferenceType.sessionCompleted:
        return copyWith(sessionCompleted: enabled);
      case NotificationPreferenceType.sessionInterrupted:
        return copyWith(sessionInterrupted: enabled);
    }
  }
}