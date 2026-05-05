# FocusGuard — Funcionalidades y tratamiento de errores

Aplicacion Flutter para sesiones de concentracion. Monitorea el movimiento del telefono con sensores y detecta cuando el usuario abandona la sesion.

---

## Funcionalidades implementadas

| Area | Que hace |
|---|---|
| Sesion de foco | Iniciar, pausar, reanudar, reiniciar y completar sesiones temporizadas |
| Duracion | Selector personalizado + opciones predefinidas (5, 10, 15, 25, 45, 60 min) |
| Deteccion por sensores | Fusion de acelerometro, giroscopio y aceleracion lineal para detectar giro del telefono |
| Sensibilidad | 4 niveles: baja, equilibrada, alta, extrema |
| Estadisticas | Sesiones totales, tiempo acumulado, combo actual y mejor combo — guardados en SQLite |
| Notificaciones | Alertas locales por evento: inicio, pausa, reanudacion, reinicio, completado, interrupcion |
| Vibracion | Patron de alerta al interrumpir la sesion |
| Preferencias | Cada tipo de notificacion activable individualmente, persistido en SharedPreferences |
| Tema | Claro y oscuro, con persistencia y deteccion automatica del sistema |
| Terminos de uso | Dialogo obligatorio en primer uso; cierra la app si se rechaza |

---

## Tratamiento de errores — lo que esta bien

- **Giroscopio no disponible**: se valida con timeout al inicializar. Si falla, bloquea el inicio de sesion y muestra mensaje de error.
- **Carga de estadisticas**: envuelta en `try/catch`. Si falla la BD, muestra mensaje y la app sigue usable.
- **Guardado de estadisticas**: tambien con `try/catch`. Captura fallos sin romper el flujo.
- **Protecciones de estado**: no permite iniciar si ya esta corriendo, no pausa si no esta activo, no edita duracion durante sesion.
- **Sensor invalido**: descarta lecturas del acelerometro cuando el vector base tiene magnitud casi cero, evitando calculos inestables.

---

## Tratamiento de errores | lo que falta o esta debil (Con ayuda de IA para evitar errores más grandes)

| Zona debil | Riesgo concreto |
|---|---|
| `main()` no protege la init de notificaciones | Si el plugin falla, la app puede no arrancar |
| Lectura y escritura de `SharedPreferences` sin `try/catch` | Un fallo silencioso pierde la configuracion del usuario |
| Streams de sensores sin `onError` | Si el sensor se cae durante una sesion, la deteccion queda rota sin aviso |
| Notificaciones sin manejo de errores | Errores de permisos o plataforma pasan sin retroalimentacion al usuario |
| Errores mostrados solo en pantalla de estadisticas | No hay estrategia uniforme en toda la UI |
| Todos los `catch` son genericos `catch (_)` | Pierde contexto tecnico, complica depuracion |

---

## Conclusion

El nucleo funcional esta completo y usable. El manejo de errores cubre las zonas criticas del flujo principal (sensores y base de datos), pero quedan expuestos el arranque de la app, la persistencia de preferencias y los servicios de plataforma. El siguiente paso tecnico es blindar esas tres areas.
