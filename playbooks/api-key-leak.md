# Playbook Táctico de IR: Filtración de Claves de API (API Key Leak)

**Clasificación del Incidente:** Exposición de credenciales de alto valor (Claves de AWS, Azure, GCP o tokens de servicios SaaS) 

**Severidad Clasificada:** CRÍTICA 

**Tiempo Objetivo de Contención:** $< 10$ minutos (Revocación verificada) 

**Documentos Vinculados:** Guía de Gestión de Secretos (S1-T07), Política de Gestión de Activos (T-02).

## 1.0 Protocolo de Respuesta Estratégica (Fase I: Contención)

**Objetivo:** Invalidar el activo comprometido en el menor tiempo posible para detener el acceso malicioso.

### 1.1 Tarea Crítica: Revocación Inmediata en Proveedor Cloud/SaaS (0-5 minutos)

|Tarea|Procedimiento Operacional|
|---|---|
|**Identificación:**|Determinar el tipo y el servicio afectado (IAM Role, API Key de Stripe, Credencial de Azure Key Vault).|
|**Revocación en el Origen:**|**Máxima Prioridad.** Ejecutar la revocación mediante la **CLI/Consola del Proveedor Cloud**. (Ej. `aws iam delete-access-key` o equivalente en Azure/GCP).|
|**Invalidez de Sesión:**|Si es un token de servicio, invalidar todas las sesiones activas del rol de servicio afectado.|
|**Verificación de Contención:**|Intentar usar la clave revocada (ejecutando un comando simple) para confirmar el error de autenticación (`HTTP 401`).|
|**Notificación Formal:**|Notificar al canal de incidentes (Slack/Teams) indicando el **Servicio Cloud** afectado y la hora exacta de la revocación.|

## 2.0 Análisis Forense Táctico (Fase II: Detección y Análisis)

**Objetivo:** Determinar DÓNDE (origen de la filtración) y CÓMO (Root Cause) fue expuesto el secreto, y verificar si fue utilizado.

### 2.1 Análisis de Logs del Proveedor Cloud/SaaS

|Tarea|Procedimiento de Análisis (Log Forense)|
|---|---|
|**Auditoría de Detección (Commit ID):**|Revisar las alertas de **Secret Scanning** para obtener el _commit ID_, autor, y _timestamp_ de la filtración.|
|**Auditoría de Logs de Acceso del Atacante:**|**CRÍTICO.** Revisar los logs de auditoría del proveedor (AWS CloudTrail, GCP Audit Logs, Azure Activity Log) del servicio comprometido _antes_ de la revocación.|
|**Indicadores de Compromiso (IoCs):**|* **Movimiento Lateral:** Llamadas a la API de creación/modificación de usuarios IAM (`iam:CreateUser`, `iam:AttachRolePolicy`). * **Exfiltración de Datos:** Accesos a servicios de almacenamiento (S3, Blobs) o bases de datos (RDS). * **Actividad Anómala:** Accesos desde IPs/regiones geográficamente inusuales.|
|**Revisión de Historial Git Profundo:**|Utilizar herramientas forenses de Git para rastrear la credencial en ramas antiguas o historial reescrito.|
|**Documentación:**|Registrar el **Commit ID**, **Ruta del Archivo** y el **Vector Inicial de Fuga** en la plantilla de Post-Mortem.|

### 2.2 Cuantificación del Impacto

- **Auditoría de Acciones:** Determinar si la clave fue utilizada para crear, modificar o eliminar recursos (acciones de Nivel Alto).
    
- **Exposición de Datos:** Confirmar la lectura o exfiltración de datos clasificados como **Restringidos** (PII/KYC/Secretos) del Gestor de Secretos o bases de datos.
    
- **Impacto Financiero:** Cuantificar el costo de las llamadas a la API o transacciones fraudulentas antes de la revocación.
    

## 3.0 Remediación Permanente y Fortalecimiento (Fase III: Remediación)

**Objetivo:** Eliminar la credencial expuesta de forma irrecuperable y asegurar la no recurrencia.

### 3.1 Tarea Crítica: Purga y Rotación

|Tarea|Procedimiento de Remediación|
|---|---|
|**Purga de Repositorio:**|**CRÍTICO (Prevención de Recurrencia).** Utilizar **BFG Repo-Cleaner** o `git filter-repo` para purgar la credencial de **TODO** el historial de Git. Esta acción requiere un `git push --force`.|
|**Generación Segura y Almacenamiento:**|Generar una nueva clave de alta entropía y almacenarla en el **Gestor de Secretos Dedicado** (Vault), aplicando políticas de acceso Mínimo Privilegio.|
|**Implementación Preventiva:**|Habilitar la función de **Push Protection** en GitHub para el repositorio afectado, bloqueando futuros _commits_ que contengan patrones de secretos (Vinculado a SAST T-12).|

### 3.2 Cierre Formal y Análisis de Vulnerabilidad

|Tarea|Procedimiento de Documentación|
|---|---|
|**Post-Mortem:**|Documentar el incidente en la **Plantilla de Post-Mortem** detallando la Causa Raíz (RCA), las Lecciones Aprendidas y las acciones correctivas permanentes.|
|**Cierre Formal:**|Cerrar el ticket de incidente, registrar las lecciones aprendidas en el sistema de gestión de riesgos y obtener la aprobación del CISO/Tech Lead para el cierre.|

## 4.0 Plantilla de Post-Mortem y Referencias Tácticas

_(Esta sección se adjunta como evidencia de cierre del incidente para el reporte ejecutivo)_

**4.1 Plantilla de Post-Mortem (Estructura Requerida)** _Incluir la Plantilla de Post-Mortem con las secciones: Resumen Ejecutivo, Línea de Tiempo Detallada, Causa Raíz, Impacto Cuantificado y Acciones Correctivas Permanentes._

###  Referencias Tácticas Clave

- **Protocolo de Prevención:** Guía de Gestión de Secretos (S1-T07).
    
- **Hardening:** Guía Hardening de Bases de Datos (T-16) (para la rotación de credenciales DB).
    
- **Herramientas Forenses:** BFG Repo-Cleaner, `git-filter-repo`

