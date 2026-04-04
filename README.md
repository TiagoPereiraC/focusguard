# FocusGuard

## Capítulo 1 - Descripción General del Sistema

### Descripción del sistema
FocusGuard es una aplicación móvil para Android orientada a mejorar la concentración durante sesiones de estudio o trabajo. Su propuesta principal es detectar, mediante el giroscopio del dispositivo, movimientos que indiquen manipulación del teléfono durante una sesión de foco y usar ese evento para romper el combo o racha de concentración.

### Objetivos del sistema
El sistema debe permitir:
- Registrar sesiones de foco.
- Detectar giros mediante giroscopio.
- Mantener sesiones activas con foreground service.
- Gestionar combos y rachas.
- Mostrar estadísticas locales.
- Emitir notificaciones al finalizar sesiones.

### Alcance del sistema
FocusGuard permitirá:
- Iniciar y finalizar sesiones de foco.
- Detectar giros mediante giroscopio.
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

### RF-01 - Registrar sesión de foco
Caso de uso: Iniciar Sesión de Foco
- Actor: Usuario
- Prioridad: Esencial
- Entradas: Duración de sesión
- Salida: Sesión iniciada y timer activo

Flujo principal:
1. Usuario selecciona Iniciar foco.
2. Configura duración (o usa predeterminada).
3. Sistema activa timer y giroscopio.
4. Interfaz muestra tiempo restante y combo.

Flujo de excepción:
1. Duración inválida.
2. Sistema muestra alerta.

### RF-02 - Finalizar sesión
- Actor: Usuario o Sistema

Flujo principal:
1. Usuario presiona Finalizar o el timer llega a cero.
2. Sistema detiene giroscopio.
3. Sistema registra sesión completada.
4. Sistema emite notificación local.

### RF-03 - Detectar movimiento
- Actor: Sistema
- Prioridad: Esencial

Flujo principal:
1. Durante sesión activa, sistema recibe eventos del giroscopio.
2. Evalúa movimiento según umbral configurado.
3. Si supera umbral, dispara ruptura de combo.

### RF-04 - Ruptura de combo
- Actor: Sistema

Flujo principal:
1. Giroscopio detecta rotación o manipulación inválida.
2. Sistema rompe combo actual (currentCombo = 0).
3. Sistema registra motivo Movimiento detectado.
4. Actualiza interfaz.

### RF-05 - Gestión de combos
- Actor: Sistema

Flujo principal:
1. Sesión completada sin ruptura: combo++.
2. Sesión interrumpida: combo = 0.
3. Guardar mejor combo histórico.

### RF-06 - Estadísticas básicas
- Actor: Usuario
- Salida: Tiempo total, sesiones completadas, mejor combo.

### RF-07 - Configuración
- Entradas: Duración foco, sensibilidad del sensor, notificaciones.

### RF-08 - Notificaciones locales
- Actor: Sistema
- Salida: Alertas de fin de sesión o pausa.
- Tecnología prevista: flutter_local_notifications.

### RF-09 - Foreground service
- Actor: Sistema
- Objetivo: Mantener sesión activa en Android.
- Tecnología prevista: flutter_foreground_task.

### RF-10 - Compras integradas
- Actor: Usuario
- Objetivo: Desbloquear temas o sonidos.
- Tecnologia prevista: in_app_purchase.

### RF-11 - Modo estandar y modo estricto
- Actor: Usuario

Modo estándar:
- Usuario puede seguir usando el celular.
- App detecta manipulación mediante giroscopio durante sesión.
- Si hay manipulación no permitida, rompe combo.

Modo estricto:
- App restringe al máximo la interacción con el celular.
- Usuario no debe salir ni cambiar a otras apps hasta finalizar tiempo o usar salida autorizada.
- Sistema debe impedir volver a inicio, abrir recientes o cambiar de app dentro de lo permitido por Android (LockTask/kiosk mode).

---

## Capítulo 3 - Requisitos No Funcionales

### RNF generales
- RNF-01 Plataforma: Android.
- RNF-02 Rendimiento: timer fluido y sensor responsive.
- RNF-03 Mantenibilidad: arquitectura MVVM obligatoria.
- RNF-04 Usabilidad: interfaz simple y clara.
- RNF-05 Persistencia: local offline (SQLite/Hive).
- RNF-06 Sensores: validar disponibilidad del giroscopio.
- RNF-07 Android: permisos y configuración correctos.

### RNF normativos - Uruguay y Brasil

#### Uruguay - Ley N. 18.331
- RNF-URU-01 Consentimiento explícito: obtener consentimiento expreso antes de acceder al giroscopio.
- RNF-URU-02 Finalidad específica: uso exclusivo para detectar rupturas de foco.
- RNF-URU-03 Derecho ARCO: acceso, rectificación, cancelación y oposición de datos.
- RNF-URU-04 Seguridad: cifrado y medidas razonables para datos locales.
- RNF-URU-05 Información clara: explicar uso del giroscopio en onboarding.

#### Brasil - LGPD (Ley 13.709/2018)
- RNF-BRA-01 Consentimiento LGPD: específico, informado, inequívoco y granular.
- RNF-BRA-02 Compliance ANPD: identificar responsable del tratamiento.
- RNF-BRA-03 Datos sensibles: base legal explícita para hábitos personales.
- RNF-BRA-04 Prohibición de espionaje: detener giroscopio cuando no corresponda.
- RNF-BRA-05 Portabilidad y olvido: exportar datos y borrar datos.

#### RNF comunes Uruguay/Brasil
- RNF-INT-01 Política de privacidad visible.
- RNF-INT-02 Permisos Android solo cuando sean necesarios.
- RNF-INT-03 No compartir datos con terceros.
- RNF-INT-04 Menores: requerir autorización parental cuando aplique.
- RNF-INT-05 Informar cambios de política de privacidad.

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
- Detección de movimiento durante sesión activa.

Pendiente o parcial respecto al documento:
- Foreground service en Android.
- Notificaciones locales.
- Modo estricto con LockTask.
- Compras integradas.
- Consentimiento normativo y política de privacidad en onboarding.
- Exportación y borrado total de datos desde UI.

## Nota
Requisito obligatorio de la ementa:
- La integración de sensores con la interfaz se evidencia en RF-03 (detectar movimiento) y RF-04 (ruptura de combo).
- En estas funcionalidades, los eventos del giroscopio cambian en tiempo real el estado de la sesión, el combo y la UI.
