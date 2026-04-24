import 'package:flutter/material.dart';

import '../../model/focus_sensitivity_mode.dart';
import '../../model/notification_preferences.dart';
import 'tos_dialog.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool tosAccepted;
  final ValueChanged<bool> onSetTosAccepted;
  final NotificationPreferences notificationPreferences;
  final Future<void> Function(NotificationPreferenceType, bool)
  onUpdateNotificationPreference;
  final FocusSensitivityMode sensitivityMode;
  final Future<void> Function(FocusSensitivityMode) onUpdateSensitivityMode;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.tosAccepted,
    required this.onSetTosAccepted,
    required this.notificationPreferences,
    required this.onUpdateNotificationPreference,
    required this.sensitivityMode,
    required this.onUpdateSensitivityMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late NotificationPreferences _localPreferences;
  late FocusSensitivityMode _localSensitivityMode;
  bool _isUpdatingAll = false;

  static const List<NotificationPreferenceType> _notificationTypes =
      NotificationPreferenceType.values;

  @override
  void initState() {
    super.initState();
    _localPreferences = widget.notificationPreferences;
    _localSensitivityMode = widget.sensitivityMode;
  }

  Future<void> _onTosTap(BuildContext context) async {
    await showToSDialog(context, canDismiss: true, requireAcceptance: false);
  }

  Future<void> _onNotificationToggle(
    NotificationPreferenceType type,
    bool enabled,
  ) async {
    setState(() {
      _localPreferences = _localPreferences.setValue(type, enabled);
    });
    await widget.onUpdateNotificationPreference(type, enabled);
  }

  bool get _allNotificationsEnabled {
    return _notificationTypes.every(_localPreferences.valueFor);
  }

  Future<void> _onToggleAllNotifications(bool enabled) async {
    if (_isUpdatingAll) {
      return;
    }

    setState(() {
      _isUpdatingAll = true;
      NotificationPreferences updated = _localPreferences;
      for (final NotificationPreferenceType type in _notificationTypes) {
        updated = updated.setValue(type, enabled);
      }
      _localPreferences = updated;
    });

    for (final NotificationPreferenceType type in _notificationTypes) {
      await widget.onUpdateNotificationPreference(type, enabled);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isUpdatingAll = false;
    });
  }

  String _labelForType(NotificationPreferenceType type) {
    switch (type) {
      case NotificationPreferenceType.sessionStarted:
        return 'Sesion iniciada';
      case NotificationPreferenceType.sessionResumed:
        return 'Sesion reanudada';
      case NotificationPreferenceType.sessionPaused:
        return 'Sesion pausada';
      case NotificationPreferenceType.sessionReset:
        return 'Sesion reiniciada';
      case NotificationPreferenceType.sessionCompleted:
        return 'Sesion completada';
      case NotificationPreferenceType.sessionInterrupted:
        return 'Sesion interrumpida';
    }
  }

  String _subtitleForType(NotificationPreferenceType type) {
    switch (type) {
      case NotificationPreferenceType.sessionStarted:
        return 'Avisa cuando comienza una sesion nueva.';
      case NotificationPreferenceType.sessionResumed:
        return 'Avisa cuando retomas una sesion pausada.';
      case NotificationPreferenceType.sessionPaused:
        return 'Avisa cuando pausas una sesion en progreso.';
      case NotificationPreferenceType.sessionReset:
        return 'Avisa cuando reinicias el contador de foco.';
      case NotificationPreferenceType.sessionCompleted:
        return 'Avisa cuando finaliza una sesion con exito.';
      case NotificationPreferenceType.sessionInterrupted:
        return 'Avisa cuando se detecta giro y se rompe el combo.';
    }
  }

  IconData _iconForType(NotificationPreferenceType type) {
    switch (type) {
      case NotificationPreferenceType.sessionStarted:
        return Icons.play_circle_outline;
      case NotificationPreferenceType.sessionResumed:
        return Icons.play_arrow_outlined;
      case NotificationPreferenceType.sessionPaused:
        return Icons.pause_circle_outline;
      case NotificationPreferenceType.sessionReset:
        return Icons.restart_alt_outlined;
      case NotificationPreferenceType.sessionCompleted:
        return Icons.verified_outlined;
      case NotificationPreferenceType.sessionInterrupted:
        return Icons.warning_amber_rounded;
    }
  }

  Future<void> _onSensitivityChanged(FocusSensitivityMode mode) async {
    if (_localSensitivityMode == mode) {
      return;
    }

    setState(() {
      _localSensitivityMode = mode;
    });
    await widget.onUpdateSensitivityMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Cambiar a modo claro'
                : 'Cambiar a modo oscuro',
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Términos de uso (ToS)'),
              subtitle: Text(
                widget.tosAccepted
                    ? 'Aceptados. Puedes revisarlos cuando quieras.'
                    : 'Obligatorio para usar FocusGuard.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              trailing: FilledButton(
                onPressed: () => _onTosTap(context),
                child: const Text('Revisar'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sensibilidad de deteccion',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajusta que tan facil se interrumpe la sesion cuando detectamos movimiento.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: FocusSensitivityMode.values
                        .map(
                          (FocusSensitivityMode mode) => ChoiceChip(
                            label: Text(mode.label),
                            selected: _localSensitivityMode == mode,
                            onSelected: (_) {
                              _onSensitivityChanged(mode);
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _localSensitivityMode.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Controla que alertas quieres recibir durante el ciclo de sesion.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Activar todas'),
                  subtitle: Text(
                    'Habilita o deshabilita todas las notificaciones de sesion.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  value: _allNotificationsEnabled,
                  onChanged: _isUpdatingAll ? null : _onToggleAllNotifications,
                ),
                const Divider(height: 1),
                ..._notificationTypes.map(
                  (NotificationPreferenceType type) => ListTile(
                    leading: Icon(_iconForType(type), color: cs.primary),
                    title: Text(_labelForType(type)),
                    subtitle: Text(
                      _subtitleForType(type),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    trailing: Switch.adaptive(
                      value: _localPreferences.valueFor(type),
                      onChanged: (bool enabled) {
                        _onNotificationToggle(type, enabled);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isUpdatingAll)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: LinearProgressIndicator(minHeight: 3),
            ),
          if (_isUpdatingAll)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Guardando configuracion global...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
