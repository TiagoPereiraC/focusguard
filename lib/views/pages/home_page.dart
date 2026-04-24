import 'package:flutter/material.dart';

import '../../model/focus_sensitivity_mode.dart';
import '../../model/notification_preferences.dart';
import '../../theme/app_palette.dart';
import '../../viewmodel/focus_viewmodel.dart';
import 'focus_page.dart';
import 'settings_page.dart';
import 'stats_page.dart';

class HomePage extends StatefulWidget {
  final FocusViewModel viewModel;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool tosAccepted;
  final ValueChanged<bool> onSetTosAccepted;
  final NotificationPreferences notificationPreferences;
  final Future<void> Function(NotificationPreferenceType, bool)
  onUpdateNotificationPreference;
  final FocusSensitivityMode sensitivityMode;
  final Future<void> Function(FocusSensitivityMode) onUpdateSensitivityMode;

  const HomePage({
    super.key,
    required this.viewModel,
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
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _minutesController;
  late final FocusNode _minutesFocusNode;

  @override
  void initState() {
    super.initState();
    _minutesController = TextEditingController(text: widget.viewModel.selectedMinutes.toString());
    _minutesFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.initialize();
    });
  }

  @override
  void dispose() {
    _minutesController.dispose();
    _minutesFocusNode.dispose();
    super.dispose();
  }

  void _applyCustomMinutes(String value) {
    final int? minutes = int.tryParse(value.trim());
    if (minutes != null && minutes > 0 && minutes <= 999) {
      widget.viewModel.selectMinutes(minutes);
      _minutesController.text = minutes.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.viewModel,
      builder: (BuildContext context, Widget? child) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color statsStart = colorScheme.tertiaryContainer;
        final Color statsEnd = colorScheme.secondaryContainer;
        final Color timerStart = isDark ? CPalette.c2 : CPalette.c4;
        final Color timerEnd = isDark ? CPalette.c3 : CPalette.c5;

        if (!_minutesFocusNode.hasFocus) {
          final String selectedValue = widget.viewModel.selectedMinutes.toString();
          if (_minutesController.text != selectedValue) {
            _minutesController.text = selectedValue;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'FocusGuard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            elevation: 0,
            actions: [
              IconButton(
                onPressed: widget.onToggleTheme,
                tooltip: widget.isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                icon: Icon(
                  widget.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              _applyCustomMinutes(_minutesController.text);
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Bienvenido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mejora tu concentración detectando cuando abandonas tu sesión',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 40),

                // Tiempo restante cuando hay sesión activa
                if (widget.viewModel.isRunning)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [timerStart, timerEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: CPalette.c2.withValues(alpha: 0.32),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Tiempo grande a la derecha
                          Text(
                            _formatTime(widget.viewModel.remainingSeconds),
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Monospace',
                            ),
                          ),
                          // Información a la izquierda
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tiempo restante',
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: const Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 12,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sesión: ${widget.viewModel.selectedMinutes} min',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: const Color.fromARGB(255, 255, 255, 255)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (widget.viewModel.isRunning) const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statsStart,
                        statsEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Sesiones',
                        value: widget.viewModel.stats.totalSessions.toString(),
                        accentColor: isDark ? CPalette.c9 : CPalette.c1,
                      ),
                      _StatItem(
                        label: 'Combo actual',
                        value: widget.viewModel.stats.currentCombo.toString(),
                        accentColor: isDark ? CPalette.c8 : CPalette.c2,
                      ),
                      _StatItem(
                        label: 'Tiempo total',
                        value: widget.viewModel.formatTotalFocusTime(),
                        accentColor: isDark ? CPalette.c7 : CPalette.c3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Selector de duración
                Text(
                  'Duración de sesión (minutos)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                // Input de tiempo personalizado
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.primaryContainer.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outline
                          : colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minutesController,
                          focusNode: _minutesFocusNode,
                          enabled: widget.viewModel.canStart,
                          style: TextStyle(
                            color: isDark ? colorScheme.onSurface : Colors.black,
                          ),
                          keyboardType: TextInputType.number,
                          onTapOutside: (_) {
                            _applyCustomMinutes(_minutesController.text);
                            FocusScope.of(context).unfocus();
                          },
                          decoration: InputDecoration(
                            labelText: 'Minutos de enfoque',
                            helperText: 'Escribe cuánto tiempo quieres concentrarte',
                            hintText: 'Ejemplo: 25',
                            labelStyle: TextStyle(
                              color: isDark ? colorScheme.onSurfaceVariant : Colors.black,
                            ),
                            helperStyle: TextStyle(
                              color: isDark ? colorScheme.onSurfaceVariant : Colors.black87,
                            ),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.75)
                                  : Colors.black54,
                            ),
                            filled: true,
                            fillColor: isDark
                              ? colorScheme.surfaceContainerLow
                              : colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            suffixText: 'min',
                            suffixStyle: TextStyle(
                              color: isDark ? colorScheme.onSurfaceVariant : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onSubmitted: (value) {
                            _applyCustomMinutes(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Opciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _MenuCard(
                        title: 'Iniciar Foco',
                        icon: Icons.play_circle_outline,
                        color: isDark ? Colors.lightGreenAccent : Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FocusPage(
                                viewModel: widget.viewModel,
                                isDarkMode: widget.isDarkMode,
                                onToggleTheme: widget.onToggleTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'Estadísticas',
                        icon: Icons.bar_chart_outlined,
                        color: isDark ? Colors.cyanAccent : Colors.lightBlue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StatsPage(
                                viewModel: widget.viewModel,
                                isDarkMode: widget.isDarkMode,
                                onToggleTheme: widget.onToggleTheme,
                              ),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'Ajustes',
                        icon: Icons.settings_outlined,
                        color: isDark ? Colors.orangeAccent : Colors.orange,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => SettingsPage(
                                isDarkMode: widget.isDarkMode,
                                onToggleTheme: widget.onToggleTheme,
                                tosAccepted: widget.tosAccepted,
                                onSetTosAccepted: widget.onSetTosAccepted,
                                notificationPreferences:
                                    widget.notificationPreferences,
                                onUpdateNotificationPreference:
                                    widget.onUpdateNotificationPreference,
                                sensitivityMode: widget.sensitivityMode,
                                onUpdateSensitivityMode:
                                  widget.onUpdateSensitivityMode,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (widget.viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: accentColor.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}
