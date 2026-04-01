import 'package:flutter/material.dart';

import '../../viewmodel/focus_viewmodel.dart';

class FocusPage extends StatelessWidget {
  final FocusViewModel viewModel;

  const FocusPage({
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
            title: const Text('Sesion de Foco'),
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
                  items: const [5, 10, 15, 25, 45, 60]
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          'Tiempo restante',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          viewModel.formatRemainingTime(),
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Combo actual: ${viewModel.stats.currentCombo}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (viewModel.mode.name == 'completed')
                  const Text(
                    'Sesion completada. Combo +1',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (viewModel.phoneTurned)
                  const Text(
                    'Telefono girado detectado. Sesion interrumpida y combo reiniciado.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const Spacer(),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: viewModel.isRunning ? null : viewModel.startSession,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(viewModel.isPaused ? 'Reanudar' : 'Iniciar'),
                    ),
                    ElevatedButton.icon(
                      onPressed: viewModel.isRunning ? viewModel.pauseSession : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pausar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: viewModel.resetSession,
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reiniciar'),
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
