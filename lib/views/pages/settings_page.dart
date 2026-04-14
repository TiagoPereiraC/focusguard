import 'package:flutter/material.dart';

import 'tos_dialog.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;
  final bool tosAccepted;
  final ValueChanged<bool> onSetTosAccepted;

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.tosAccepted,
    required this.onSetTosAccepted,
  });

  Future<void> _onTosTap(BuildContext context) async {
    await showToSDialog(context, canDismiss: true, requireAcceptance: false);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Términos de uso (ToS)'),
              subtitle: Text(
                tosAccepted
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
        ],
      ),
    );
  }
}
