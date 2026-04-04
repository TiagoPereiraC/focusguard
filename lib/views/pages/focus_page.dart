import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../viewmodel/focus_viewmodel.dart';

class FocusPage extends StatelessWidget {
  final FocusViewModel viewModel;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const FocusPage({
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
        final Set<int> minuteOptions = <int>{5, 10, 15, 25, 45, 60, viewModel.selectedMinutes};
        final List<int> sortedMinuteOptions = minuteOptions.toList()..sort();
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Sesion de Foco'),
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
                DropdownButtonFormField<int>(
                  initialValue: viewModel.selectedMinutes,
                  decoration: const InputDecoration(
                    labelText: 'Duracion',
                    border: OutlineInputBorder(),
                  ),
                  items: sortedMinuteOptions
                      .map(
                        (int minutes) => DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes minutos'),
                        ),
                      )
                      .toList(),
                  onChanged: (int? value) {
                    if (value != null) {
                      viewModel.selectMinutes(value);
                    }
                  },
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHigh
                        : colorScheme.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Tiempo restante',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.formatRemainingTime(),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Combo actual: ${viewModel.stats.currentCombo}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (viewModel.mode.name == 'completed')
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? CPalette.c4.withValues(alpha: 0.28)
                          : CPalette.c6.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? CPalette.c6.withValues(alpha: 0.55)
                            : CPalette.c3.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Text(
                      'Sesion completada. Combo +1',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? CPalette.c8 : CPalette.c2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (viewModel.phoneTurned)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? CPalette.c1.withValues(alpha: 0.92)
                          : CPalette.c8.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? CPalette.c5.withValues(alpha: 0.45)
                            : CPalette.c4.withValues(alpha: 0.42),
                      ),
                    ),
                    child: Text(
                      'Telefono girado detectado. Sesion interrumpida y combo reiniciado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark ? CPalette.c7 : CPalette.c2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isRunning ? null : viewModel.startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: Text(viewModel.isPaused ? 'Seguir' : 'Iniciar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isRunning ? viewModel.pauseSession : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.pause, size: 18),
                        label: const Text('Pausar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: viewModel.resetSession,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 1.6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.restart_alt, size: 18),
                        label: const Text('Reiniciar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
