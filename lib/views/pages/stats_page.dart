import 'package:flutter/material.dart';

import '../../viewmodel/focus_viewmodel.dart';

class StatsPage extends StatelessWidget {
  final FocusViewModel viewModel;

  const StatsPage({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (BuildContext context, Widget? child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Estadisticas'),
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
                ),
                _StatTile(
                  title: 'Combo actual',
                  value: viewModel.stats.currentCombo.toString(),
                  icon: Icons.local_fire_department_outlined,
                ),
                _StatTile(
                  title: 'Mejor combo',
                  value: viewModel.stats.bestCombo.toString(),
                  icon: Icons.emoji_events_outlined,
                ),
                _StatTile(
                  title: 'Tiempo total de foco',
                  value: viewModel.formatTotalFocusTime(),
                  icon: Icons.timer_outlined,
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

  const _StatTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
