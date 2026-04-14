import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';

Future<bool?> showToSDialog(
  BuildContext context, {
  required bool canDismiss,
  bool requireAcceptance = false,
}) {
  bool acceptedSensorUse = !requireAcceptance;
  bool acceptedPrivacyRead = !requireAcceptance;

  return showDialog<bool>(
    context: context,
    barrierDismissible: canDismiss,
    builder: (BuildContext ctx) {
      return StatefulBuilder(
        builder: (BuildContext _, StateSetter setStateDialog) {
          final bool isDark = Theme.of(ctx).brightness == Brightness.dark;
          final Color bg = isDark ? CPalette.c1 : Colors.white;
          final Color title = isDark ? CPalette.c9 : CPalette.c1;
          final Color body = isDark ? CPalette.c8 : CPalette.c2;
          final Color border = isDark ? CPalette.c4 : CPalette.c7;
            final bool canAccept =
              !requireAcceptance || (acceptedSensorUse && acceptedPrivacyRead);

          return AlertDialog(
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: border),
            ),
            title: Text(
              'Términos de uso y privacidad',
              style: TextStyle(color: title, fontWeight: FontWeight.w700),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Para usar FocusGuard debes aceptar estos términos y la política de privacidad.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Responsable del tratamiento: equipo de FocusGuard.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: title,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Datos tratados: movimientos del dispositivo mediante giroscopio.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Finalidad: detectar rupturas de foco durante sesiones activas.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alcance de uso del sensor: solo durante sesiones de enfoque activas.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Almacenamiento: local en el dispositivo. No se comparten datos con terceros.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tus derechos: acceder, rectificar, cancelar, oponerte, exportar y eliminar tus datos desde la app.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menores: cuando aplique, se requiere autorización parental.',
                    style: TextStyle(color: body),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Si esta política cambia, se informará dentro de la aplicación.',
                    style: TextStyle(color: body),
                  ),
                  if (requireAcceptance) ...[
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: acceptedSensorUse,
                      title: Text(
                        'Acepto que FocusGuard use mi giroscopio solo para detectar distracciones durante sesiones activas.',
                        style: TextStyle(color: body),
                      ),
                      onChanged: (bool? value) {
                        setStateDialog(() => acceptedSensorUse = value ?? false);
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      value: acceptedPrivacyRead,
                      title: Text(
                        'He leído la política de privacidad.',
                        style: TextStyle(color: body),
                      ),
                      onChanged: (bool? value) {
                        setStateDialog(() => acceptedPrivacyRead = value ?? false);
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (requireAcceptance)
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: body),
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Rechazar'),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: isDark ? CPalette.c6 : CPalette.c4,
                  foregroundColor: isDark ? CPalette.c1 : Colors.white,
                ),
                onPressed: canAccept ? () => Navigator.of(ctx).pop(true) : null,
                child: Text(requireAcceptance ? 'Aceptar' : 'Cerrar'),
              ),
            ],
          );
        },
      );
    },
  );
}
