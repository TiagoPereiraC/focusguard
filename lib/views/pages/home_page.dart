import 'package:flutter/material.dart';

import '../../viewmodel/focus_viewmodel.dart';
import 'focus_page.dart';
import 'stats_page.dart';

class HomePage extends StatelessWidget {
  final FocusViewModel viewModel;

  const HomePage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'FocusGuard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Hola, bienvenido',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mejora tu concentración detectando cuando abandonas tu sesión',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // Tiempo restante cuando hay sesión activa
                if (viewModel.isRunning)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
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
                            _formatTime(viewModel.remainingSeconds),
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
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Sesión: ${viewModel.selectedMinutes} min',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (viewModel.isRunning) const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Sesiones',
                        value: viewModel.stats.totalSessions.toString(),
                      ),
                      _StatItem(
                        label: 'Combo actual',
                        value: viewModel.stats.currentCombo.toString(),
                      ),
                      _StatItem(
                        label: 'Tiempo total',
                        value: viewModel.formatTotalFocusTime(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Selector de duración
                Text(
                  'Duración de sesión',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),

                // Botones predeterminados
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [25, 30, 45, 60].map((minutes) {
                    return FilterChip(
                      label: Text('$minutes min'),
                      selected: viewModel.selectedMinutes == minutes,
                      onSelected: (selected) {
                        if (selected && (viewModel.canStart)) {
                          viewModel.selectMinutes(minutes);
                        }
                      },
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: viewModel.selectedMinutes == minutes
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Input de tiempo personalizado
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: viewModel.canStart,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          suffixText: 'min',
                        ),
                        onSubmitted: (value) {
                          final int? minutes = int.tryParse(value);
                          if (minutes != null &&
                              minutes > 0 &&
                              minutes <= 999) {
                            viewModel.selectMinutes(minutes);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Text(
                  'Opciones',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
                        color: Colors.blue,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FocusPage(viewModel: viewModel),
                            ),
                          );
                        },
                      ),
                      _MenuCard(
                        title: 'Estadísticas',
                        icon: Icons.bar_chart_outlined,
                        color: Colors.green,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StatsPage(viewModel: viewModel),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
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
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
