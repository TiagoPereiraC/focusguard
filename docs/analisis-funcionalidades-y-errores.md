# FocusGuard — Funcionalidades y tratamiento de errores

Aplicacion Flutter para sesiones de concentracion. Monitorea el movimiento del telefono con sensores y detecta cuando el usuario abandona la sesion.

---

## Funcionalidades implementadas

| Area | Clase / Metodo | Archivo | Linea |
|---|---|---|---|
| Iniciar sesion | `FocusViewModel.startSession()` | focus_viewmodel.dart | 263 |
| Pausar sesion | `FocusViewModel.pauseSession()` | focus_viewmodel.dart | 312 |
| Reiniciar sesion | `FocusViewModel.resetSession()` | focus_viewmodel.dart | 331 |
| Completar sesion | `FocusViewModel._completeSession()` | focus_viewmodel.dart | 352 |
| Interrumpir por giro | `FocusViewModel._interruptSessionByRotation()` | focus_viewmodel.dart | 377 |
| Duracion personalizada | `FocusViewModel.selectMinutes()` | focus_viewmodel.dart | 251 |
| Deteccion de movimiento (sensores) | `FocusViewModel._startRotationDetection()` | focus_viewmodel.dart | 413 |
| Sensibilidad por nivel | `FocusViewModel._accelAngleThreshold` y otros getters | focus_viewmodel.dart | 88-217 |
| Persistencia de stats | `StatsRepository.saveStats()` | stats_repository.dart | 77 |
| Carga de stats | `StatsRepository.loadStats()` | stats_repository.dart | 48 |
| Inicializacion de BD | `StatsRepository._getDatabase()` | stats_repository.dart | 13 |
| Notificaciones | `NotificationService.showNotification()` | notification_service.dart | 45 |
| Init de notificaciones | `NotificationService.initialize()` | notification_service.dart | 17 |
| Vibracion de alerta | `NotificationService.vibrateInterruptionAlert()` | notification_service.dart | 91 |
| Carga de preferencias | `_FocusGuardAppState._loadInitialPreferences()` | main.dart | 78 |
| Cambio de tema | `_FocusGuardAppState._toggleTheme()` | main.dart | 157 |
| Aceptacion de ToS | `_FocusGuardAppState._checkToS()` | main.dart | 129 |
| Guardar ToS aceptado | `_FocusGuardAppState._setTosAccepted()` | main.dart | 144 |
| Toggle notificacion individual | `_FocusGuardAppState._updateNotificationPreference()` | main.dart | 187 |
| Cambio de sensibilidad | `_FocusGuardAppState._updateSensitivityMode()` | main.dart | 203 |

---

## Tratamiento de errores — lo que esta bien

| Que cubre | Clase / Metodo | Archivo | Linea |
|---|---|---|---|
| Giroscopio no disponible — timeout + catch | `FocusViewModel._validateGyroscopeAvailability()` | focus_viewmodel.dart | 225-236 |
| Fallo al cargar stats desde BD | `FocusViewModel._loadStats()` — `catch (_)` | focus_viewmodel.dart | 238-249 (catch en 243) |
| Fallo al guardar stats en BD | `FocusViewModel._persistStats()` — `catch (_)` | focus_viewmodel.dart | 404-411 (catch en 408) |
| Bloqueo si ya esta corriendo | `FocusViewModel.startSession()` — guard `if (isRunning)` | focus_viewmodel.dart | 264 |
| Bloqueo si no esta corriendo | `FocusViewModel.pauseSession()` — guard `if (!isRunning)` | focus_viewmodel.dart | 313 |
| Bloqueo de edicion en sesion activa | `FocusViewModel.selectMinutes()` — guard `if (isRunning || isPaused)` | focus_viewmodel.dart | 252 |
| Vector sensor casi cero | `_startRotationDetection()` — `if (magnitude < 0.1)` | focus_viewmodel.dart | ~445 |
| Sin reentrada en interrupcion | `_interruptSessionByRotation()` — `if (_interruptionInProgress)` | focus_viewmodel.dart | 378 |

---

## Tratamiento de errores — lo que falta o esta debil

| Zona debil | Clase / Metodo | Archivo | Linea | Riesgo |
|---|---|---|---|---|
| `initialize()` sin `try/catch` | `main()` — llamada directa | main.dart | 27 | Si el plugin de notificaciones falla, la app no arranca |
| `_loadInitialPreferences()` sin proteccion | `_FocusGuardAppState._loadInitialPreferences()` | main.dart | 78 | Fallo de IO deja la app en estado inconsistente |
| `_toggleTheme()` sin `try/catch` | `_FocusGuardAppState._toggleTheme()` | main.dart | 157 | Cambio visible pero no persistido si falla SharedPreferences |
| `_updateNotificationPreference()` sin `try/catch` | `_FocusGuardAppState._updateNotificationPreference()` | main.dart | 187 | Preferencia se pierde al reiniciar |
| `_updateSensitivityMode()` sin `try/catch` | `_FocusGuardAppState._updateSensitivityMode()` | main.dart | 203 | Idem |
| `_setTosAccepted()` sin `try/catch` | `_FocusGuardAppState._setTosAccepted()` | main.dart | 144 | Podria volver a pedir ToS en proximo arranque |
| `showNotification()` sin `try/catch` | `NotificationService.showNotification()` | notification_service.dart | 45 | Error de permisos o plugin pasa sin aviso |
| `vibrateInterruptionAlert()` sin `try/catch` | `NotificationService.vibrateInterruptionAlert()` | notification_service.dart | 91 | Excepcion silenciosa en dispositivos sin soporte |
| Streams sin `onError` | `FocusViewModel._startRotationDetection()` — 3 suscripciones | focus_viewmodel.dart | 430, 461, 485 | Si un stream falla, la deteccion queda rota sin aviso |
| `catch (_)` generico — pierde contexto | `_loadStats`, `_validateGyroscopeAvailability`, `_persistStats` | focus_viewmodel.dart | 232, 243, 408 | Imposible distinguir tipo de fallo en depuracion |

---

## Conclusion

El nucleo funcional esta completo y usable. El manejo de errores cubre la carga/guardado de estadisticas y la validacion del giroscopio, pero el arranque de la app, la persistencia de preferencias y los servicios de plataforma siguen sin proteccion. El siguiente paso tecnico es blindar esas tres areas con `try/catch` y una estrategia uniforme de mensajes de error en UI.