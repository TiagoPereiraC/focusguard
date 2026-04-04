import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../viewmodel/focus_viewmodel.dart';

class StatsPage extends StatelessWidget {
  final FocusViewModel viewModel;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const StatsPage({
    super.key,
    required this.viewModel,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Estadisticas'),
            actions: [
              IconButton(
                onPressed: onToggleTheme,
                tooltip: isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
                icon: Icon(
                  isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatTile(
                  title: 'Sesiones completadas',
                  value: viewModel.stats.totalSessions.toString(),
                  icon: Icons.check_circle_outline,
                  accentColor: CPalette.c3,
                ),
                _StatTile(
                  title: 'Combo actual',
                  value: viewModel.stats.currentCombo.toString(),
                  icon: Icons.local_fire_department_outlined,
                  accentColor: CPalette.c4,
                ),
                _StatTile(
                  title: 'Mejor combo',
                  value: viewModel.stats.bestCombo.toString(),
                  icon: Icons.emoji_events_outlined,
                  accentColor: CPalette.c5,
                ),
                _StatTile(
                  title: 'Tiempo total de foco',
                  value: viewModel.formatTotalFocusTime(),
                  icon: Icons.timer_outlined,
                  accentColor: CPalette.c6,
                ),
                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color effectiveAccent = isDark
        ? Color.lerp(accentColor, CPalette.c8, 0.35)!
        : accentColor;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color tileColor = isDark
        ? colorScheme.surfaceContainerHigh
        : accentColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: effectiveAccent),
        title: Text(title),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: effectiveAccent,
          ),
        ),
      ),
    );
  }
}
