# FocusGuard

## Capítulo 1 - Descripción General del Sistema

### Descripción del sistema
FocusGuard es una aplicación móvil para Android orientada a mejorar la concentración durante sesiones de estudio o trabajo. Su propuesta principal es detectar, mediante fusión de sensores (acelerómetro, giroscopio y acelerómetro lineal), movimientos que indiquen manipulación del teléfono durante una sesión de foco y usar ese evento para romper el combo o racha de concentración.

### Objetivos del sistema
El sistema debe permitir:
- Registrar sesiones de foco.
- Detectar manipulación con fusión de sensores.
- Mantener sesiones activas con foreground service.
- Gestionar combos y rachas.
- Mostrar estadísticas locales.
- Emitir notificaciones durante el ciclo de sesión.

### Alcance del sistema
FocusGuard permitirá:
- Iniciar y finalizar sesiones de foco.
- Detectar manipulación con fusión de sensores.
- Mantener sesiones mediante servicio en primer plano.
- Registrar sesiones localmente.
- Configurar sensibilidad del sensor.
- Gestionar notificaciones locales.
- Ofrecer compras integradas opcionales.

### Descripción de usuarios
Usuario principal: estudiantes y trabajadores que buscan mejorar su concentración.

Responsabilidades del usuario:
- Iniciar y finalizar sesiones de foco.
- Configurar duración y sensibilidad.
- Consultar estadísticas personales.
- Adquirir temas premium opcionales.

---
## Capítulo 2 - Requisitos Funcionales

Especificación consolidada para un desarrollo individual en 2 meses.

Total de requisitos funcionales definidos: 18
Estado:
- ✅ Implementado
- 🟡 Parcial
- ⬜ No implementado

### MVP (obligatorios para entrega)

### RF-01 - Inicio de sesión de foco
- Código: RF-01
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Usuario
- Descripción: El usuario inicia una sesión seleccionando una duración válida.
- Entradas: duración de sesión, acción Iniciar.
- Resultado esperado: temporizador activo y sesión en estado En curso.

### RF-02 - Monitoreo del giroscopio en sesión activa
- Código: RF-02
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema
- Descripción: El sistema procesa eventos del giroscopio solo cuando existe una sesión activa.
- Entradas: eventos del sensor, estado de sesión.
- Resultado esperado: flujo de eventos listo para evaluar distracciones.

### RF-03 - Detección de distracción por umbral
- Código: RF-03
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema
- Descripción: El sistema detecta manipulación cuando la señal del sensor supera el umbral configurado.
- Entradas: eventos del giroscopio, umbral de sensibilidad.
- Resultado esperado: evento de distracción registrado en la sesión.

### RF-04 - Finalización manual y automática
- Código: RF-04
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Usuario / Sistema
- Descripción: La sesión puede finalizar por acción del usuario o por llegada del temporizador a cero.
- Entradas: acción Finalizar, vencimiento de tiempo.
- Resultado esperado: sesión cerrada con resultado y motivo.

### RF-05 - Gestión de racha y mejor racha
- Código: RF-05
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema
- Descripción: El sistema calcula y mantiene racha actual y mejor racha histórica.
- Entradas: resultado de sesión (completada/interrumpida).
- Resultado esperado: métricas de racha actualizadas de forma consistente.

### RF-06 - Registro de historial de sesiones
- Código: RF-06
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema
- Descripción: Cada sesión finalizada se almacena con fecha, duración y estado.
- Entradas: datos de sesión al finalizar.
- Resultado esperado: historial local consultable por el usuario.

### RF-07 - Estadísticas acumuladas
- Código: RF-07
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema / Usuario
- Descripción: La app muestra tiempo total, sesiones completadas, racha actual y mejor racha.
- Entradas: historial de sesiones.
- Resultado esperado: panel de estadísticas actualizado.

### RF-08 - Configuración de duración por defecto
- Código: RF-08
- Prioridad: Media
- Estado: ✅ Implementado
- Actor: Usuario
- Descripción: El usuario define una duración predeterminada para nuevas sesiones.
- Entradas: valor de duración en Ajustes.
- Resultado esperado: nuevas sesiones utilizan la duración configurada.

### RF-09 - Configuración de sensibilidad del sensor
- Código: RF-09
- Prioridad: Media
- Estado: ✅ Implementado
- Actor: Usuario
- Descripción: El usuario ajusta la sensibilidad de detección del movimiento entre 4 niveles (Low, Balanced, High, Extreme).
- Entradas: nivel/valor de sensibilidad.
- Resultado esperado: umbrales y ventanas de evidencia aplicados en tiempo real para la detección de distracciones.

### RF-10 - Notificaciones locales de ciclo de sesión
- Código: RF-10
- Prioridad: Media
- Estado: ✅ Implementado
- Actor: Sistema
- Descripción: El sistema envía notificaciones al iniciar, reanudar, pausar, reiniciar, completar e interrumpir sesión según configuración.
- Entradas: estado de sesión, preferencias de notificación.
- Resultado esperado: notificaciones emitidas en los momentos definidos.

### RF-11 - Onboarding y consentimiento explícito
- Código: RF-11
- Prioridad: Alta
- Estado: ✅ Implementado
- Actor: Sistema / Usuario
- Descripción: La app solicita consentimiento explícito para uso del giroscopio y aceptación de política de privacidad.
- Entradas: aceptación del usuario en onboarding.
- Resultado esperado: consentimiento almacenado antes del uso completo de la app.

### RF-12 - Exportación de datos en JSON
- Código: RF-12
- Prioridad: Alta
- Estado: ⬜ No implementado
- Actor: Usuario
- Descripción: El usuario puede exportar sus datos de sesión y estadísticas en formato JSON.
- Entradas: acción Exportar datos.
- Resultado esperado: archivo JSON válido generado localmente.

### RF-13 - Eliminación total de datos
- Código: RF-13
- Prioridad: Alta
- Estado: ⬜ No implementado
- Actor: Usuario
- Descripción: El usuario puede borrar toda su información local desde Ajustes.
- Entradas: acción Eliminar datos, confirmación del usuario.
- Resultado esperado: base local limpia y estado reiniciado.

### RF-14 - Continuidad en segundo plano Android
- Código: RF-14
- Prioridad: Media
- Estado: ⬜ No implementado
- Actor: Sistema
- Descripción: La sesión de foco continúa correctamente cuando la app pasa a segundo plano.
- Entradas: transición foreground/background.
- Resultado esperado: temporizador y estado de sesión consistentes.

### RF-15 - Modo estándar de enfoque
- Código: RF-15
- Prioridad: Media
- Estado: ✅ Implementado
- Actor: Usuario
- Descripción: En modo estándar el usuario puede usar el dispositivo mientras la app detecta distracciones.
- Entradas: selección de modo estándar.
- Resultado esperado: sesión activa con control por giroscopio sin restricciones adicionales.

### RF-16 - Modo estricto de enfoque
- Código: RF-16
- Prioridad: Media
- Estado: ⬜ No implementado
- Actor: Usuario / Sistema
- Descripción: En modo estricto se aplican restricciones adicionales compatibles con Android.
- Entradas: selección de modo estricto.
- Resultado esperado: sesión con menor posibilidad de abandono o multitarea.

### Post-MVP (si hay tiempo)

### RF-17 - Personalización visual y acústica
- Código: RF-17
- Prioridad: Baja
- Estado: ⬜ No implementado
- Actor: Usuario
- Descripción: El usuario personaliza fondos y componentes sonoros de la experiencia.
- Entradas: selección de recursos visuales y de alerta.
- Resultado esperado: interfaz y alertas adaptadas a preferencias del usuario.

### RF-18 - Funcionalidades avanzadas
- Código: RF-18
- Prioridad: Baja
- Estado: ⬜ No implementado
- Actor: Usuario / Sistema
- Descripción: La app incorpora metas, logros, programación de sesiones, perfiles, internacionalización y compras integradas.
- Entradas: configuración y acciones avanzadas del usuario.
- Resultado esperado: ampliación de alcance sin afectar el núcleo del MVP.

---

## Capítulo 3 - Requisitos No Funcionales

Estado:
- ✅ Implementado
- 🟡 Parcial
- ⬜ No implementado

### RNF generales

- RNF-01 ✅ Plataforma: Android.
- RNF-02 ✅ Rendimiento: timer fluido y sensor responsive.
- RNF-03 ✅ Mantenibilidad: arquitectura MVVM obligatoria.
- RNF-04 ✅ Usabilidad: interfaz simple y clara.
- RNF-05 ✅ Persistencia: local offline (SQLite/Hive).
- RNF-06 ✅ Sensores: validar disponibilidad del giroscopio.
- RNF-07 ⬜ Android: permisos y configuración correctos.

### RNF normativos - Uruguay y Brasil

#### Uruguay - Ley N. 18.331
- RNF-URU-01 ✅ Consentimiento explícito: obtener consentimiento expreso antes de acceder al giroscopio.
- RNF-URU-02 ✅ Finalidad específica: uso exclusivo para detectar rupturas de foco.
- RNF-URU-03 🟡 Derecho ARCO: acceso, rectificación, cancelación y oposición de datos.
- RNF-URU-04 ⬜ Seguridad: cifrado y medidas razonables para datos locales.
- RNF-URU-05 ✅ Información clara: explicar uso del giroscopio en onboarding.

#### Brasil - LGPD (Ley 13.709/2018)
- RNF-BRA-01 ✅ Consentimiento LGPD: específico, informado, inequívoco y granular.
- RNF-BRA-02 🟡 Compliance ANPD: identificar responsable del tratamiento.
- RNF-BRA-03 ✅ Datos sensibles: base legal explícita para hábitos personales.
- RNF-BRA-04 ⬜ Prohibición de espionaje: detener giroscopio cuando no corresponda.
- RNF-BRA-05 🟡 Portabilidad y olvido: exportar datos y borrar datos.

#### RNF comunes Uruguay/Brasil
- RNF-INT-01 ✅ Política de privacidad visible.
- RNF-INT-02 🟡 Permisos Android solo cuando sean necesarios.
- RNF-INT-03 ✅ No compartir datos con terceros.
- RNF-INT-04 ⬜ Menores: requerir autorización parental cuando aplique.
- RNF-INT-05 ⬜ Informar cambios de política de privacidad.

### Implementación práctica obligatoria

Onboarding:
- [ ] Acepto que FocusGuard use mi giroscopio SOLO para detectar distracciones durante sesiones activas.
- [ ] He leído la Política de Privacidad.

Botones obligatorios:
- Ajustes > Eliminar todos mis datos.
- Estadísticas > Exportar datos (JSON).

Política de privacidad mínima:
- Responsable: [Nombre].
- Datos: movimientos del dispositivo (giroscopio).
- Finalidad: detectar rupturas de foco.
- Almacenamiento: local en dispositivo.
- Terceros: ninguno.
- Derechos: acceder/eliminar desde ajustes.

---

## Estado actual del proyecto

Implementado en esta base:
- Flutter con arquitectura por capas MVVM.
- Persistencia local con SQLite.
- Registro de sesiones, combo actual y mejor combo.
- Detección de movimiento durante sesión activa con fusión de sensores.
- Validación de disponibilidad de giroscopio al inicializar la app.
- Sensibilidad configurable en 4 niveles.
- Notificaciones locales por evento de sesión con preferencias granulares.

Pendiente o parcial respecto al documento:
- Foreground service en Android.
- Modo estricto con LockTask.
- Compras integradas.
- Exportación y borrado total de datos desde UI.

## Nota
Requisito obligatorio de la ementa:
- La integración de sensores con la interfaz se evidencia en RF-02 (monitoreo de sensores y ruptura de foco).
- En estas funcionalidades, los eventos de acelerómetro, giroscopio y acelerómetro lineal cambian en tiempo real el estado de la sesión, el combo y la UI.
