# Playbook: Filtración de Credenciales (Credential Leak)

**Clasificación del Incidente:** Exposición de credenciales de alto valor (API keys, tokens de acceso, secretos de DB) 

**Severidad Clasificada:** CRÍTICA (Potencial de escalada de privilegios y fuga de datos) 

**Tiempo Objetivo de Respuesta (TTR):** < 15 minutos (Desde la detección hasta el inicio de la contención) **Tiempo Objetivo de Contención:** < 30 minutos (Revocación verificada) 

**Documentos Vinculados:** Guía de Gestión de Secretos (S1-T07), Política de Gestión de Activos (T-02).

## 0.0 Preparación y Requisitos (Pre-Incidente)

Esta fase asegura que los mecanismos de detección y las herramientas forenses estén disponibles.

|Requisito|Justificación Técnica|Estado|
|---|---|---|
|[ ] **Herramientas de Scanning**|El sistema de Secret Scanning (GitHub, GitGuardian) está habilitado y monitoreando todos los repositorios (incluyendo _branches_ antiguas).|[ ]|
|[ ] **Acceso IAM/Key Vault**|El equipo de IR tiene credenciales de emergencia separadas (Break Glass Access) con MFA habilitado para acceder y revocar secretos críticos en el Gestor de Secretos/Cloud.|[ ]|
|[ ] **Integridad del Log**|Los logs de autenticación (CloudTrail, IAM, Servidor de Aplicaciones) están centralizados en el SIEM y son inmutables (no pueden ser modificados por un atacante).|[ ]|
|[ ] **Backup de Código Base**|Existe un _backup_ reciente y verificado del repositorio limpio para comparaciones forenses.|[ ]|

## 1.0 Protocolo de Respuesta Estratégica (Fase I: Contención)

**Objetivo:** Neutralizar inmediatamente el secreto comprometido antes de cualquier análisis profundo.

### 1.1 Tarea Crítica: Revocación Inmediata de Credenciales (0-5 minutos)

|Tarea|Procedimiento Operacional|
|---|---|
|[ ] **Identificación:**|Determinar el tipo de credencial y el servicio afectado (ej. AWS Access Key para S3, Credencial de PostgreSQL, o Token de Stripe).|
|[ ] **Revocación en el Origen:**|**Máxima Prioridad.** Ejecutar el comando de revocación en la API del proveedor (ej. `aws iam delete-access-key`) o invalidar el secreto en el Gestor de Secretos.|
|[ ] **Invalidez de Sesión:**|Si es un token JWT, forzar el _logout_ del usuario asociado (si es posible) y agregar el token al servicio de lista de revocación (blacklist).|
|[ ] **Verificación de Contención:**|Intentar usar la credencial revocada inmediatamente para confirmar que el acceso arroja un código de error de autenticación (ej. HTTP 401).|
|[ ] **Notificación Formal:**|Notificar al canal de incidentes (Slack/Teams) indicando el servicio, la hora exacta de la revocación y el _estado inicial_ del incidente.|

## 2.0 Análisis Forense Táctico (Fase II: Detección y Análisis)

**Objetivo:** Determinar DÓNDE (origen de la filtración) y CÓMO (Root Cause) fue expuesto el secreto, y verificar si fue utilizado.

### 2.1 Análisis de la Fuente de Exposición

|Tarea|Procedimiento de Análisis|
|---|---|
|[ ] **Auditoría de Secret Scanning:**|Revisar la alerta del sistema de detección para obtener el _commit ID_, autor, y _timestamp_ de la filtración. **CRÍTICO:** Determinar si la filtración fue en un _branch_ de desarrollo o en `main`.|
|[ ] **Revisión de Historial Git Profundo:**|Utilizar herramientas forenses de Git (ej. `git grep -i <clave_parcial> $(git rev-list --all)`) para rastrear la credencial en todo el historial, incluyendo _commits_ eliminados o no _mergeados_.|
|[ ] **Auditoría de Logs de Acceso del Atacante:**|**CRÍTICO.** Revisar los logs de acceso (AWS CloudTrail, IAM Audit Logs) del servicio comprometido _antes_ de la hora de revocación para detectar **Indicadores de Compromiso (IoCs):**|

```
* Accesos desde IPs geográficamente anómalas.
* Llamadas a la API de **creación/modificación de recursos** (Ej. `iam:CreateUser`, `s3:GetObject`). | 
```

| [ ] **Documentación:** | Registrar el **Commit ID**, **Ruta del Archivo** y el **Vector Inicial de Fuga** (ej. commit, Pastebin) en la plantilla de Post-Mortem. |

### 2.2 Cuantificación del Impacto

- **Auditoría de Acciones:** Determinar si la clave fue utilizada para crear, modificar o eliminar recursos (acciones de Nivel Alto).
    
- **Exposición de Datos:** Confirmar la lectura o exfiltración de datos clasificados como **Restringidos** (PII/KYC/Secretos) del Gestor de Secretos o bases de datos.
    
- **Impacto Financiero:** Cuantificar el costo de las llamadas a la API o transacciones fraudulentas antes de la revocación.
    

## 3.0 Remediación Permanente y Fortalecimiento (Fase III: Remediación)

**Objetivo:** Eliminar la credencial expuesta de forma irrecuperable y asegurar la no recurrencia.

### 3.1 Tarea Crítica: Purga y Rotación

|Tarea|Procedimiento de Remediación|
|---|---|
|[ ] **Purga de Repositorio:**|**CRÍTICO (Prevención de Recurrencia).** Utilizar **BFG Repo-Cleaner** o `git filter-repo` para purgar la credencial de **TODO** el historial de Git. Esta acción debe ser coordinada con el equipo de DevOps y requiere un `git push --force`.|
|[ ] **Generación Segura y Almacenamiento:**|Generar una nueva credencial de alta entropía y almacenarla en el **Gestor de Secretos Dedicado** (Vault), con la aplicación de políticas de acceso Mínimo Privilegio.|
|[ ] **Implementación Preventiva:**|Habilitar la función de **Push Protection** en GitHub para el repositorio afectado, bloqueando futuros _commits_ que contengan patrones de secretos (Vinculado a SAST T-12).|

### 3.2 Cierre Formal y Análisis de Vulnerabilidad

|Tarea|Procedimiento de Documentación|
|---|---|
|[ ] **Post-Mortem:**|Documentar el incidente en la **Plantilla de Post-Mortem** detallando la Causa Raíz (RCA), las Lecciones Aprendidas y las acciones correctivas permanentes.|
|[ ] **Cierre Formal:**|Cerrar el ticket de incidente, registrar las lecciones aprendidas en el sistema de gestión de riesgos y obtener la aprobación del CISO/Tech Lead para el cierre.|

## 4.0 Plantilla de Post-Mortem y Referencias Tácticas

_(Esta sección se adjunta como evidencia de cierre del incidente para el reporte ejecutivo)_

**4.1 Plantilla de Post-Mortem (Estructura Requerida)** _Incluir la Plantilla de Post-Mortem con las secciones: Resumen Ejecutivo, Línea de Tiempo Detallada, Causa Raíz (Ej. Error Humano, Configuración de CI/CD), Impacto Cuantificado y Acciones Correctivas Permanentes._

###  Referencias Tácticas Clave

- **Protocolo de Prevención:** Guía de Gestión de Secretos (S1-T07).
    
- **Hardening:** Guía Hardening de Bases de Datos (T-16) (para la rotación de credenciales DB).
    
- **Herramientas Forenses:** BFG Repo-Cleaner, `git-filter-repo`.
