# Playbook: Filtración de Credenciales (Credential Leak)

**Clasificación del Incidente:** Exposición de credenciales (API keys, tokens, certificados) **Severidad Clasificada:** CRÍTICA **Tiempo Objetivo de Contención:** < 30 minutos (Desde la detección) **Documento Vinculado:** Política de Gestión de Secretos (S1-T07)

## 1. Protocolo de Respuesta Inmediata (Fase I: Contención)

**Objetivo:** Invalidar el activo comprometido en el menor tiempo posible para detener el acceso malicioso.

### 1.1. Tarea Crítica: Revocación de la Credencial (0-5 minutos)

**Propósito:** Invalidar el secreto ANTES de iniciar cualquier análisis.

|Acción|Descripción de la Tarea|
|---|---|
|[ ] **Identificación:**|Determinar el tipo y el servicio afectado: API Key de Cloud, Credencial de Base de Datos, o Token de Acceso (JWT).|
|[ ] **Revocación Externa:**|Ejecutar el comando de revocación en la interfaz de gestión del proveedor (AWS IAM, Stripe, GitHub, etc.) o mediante un script de orquestación.|
|[ ] **Revocación Interna:**|Si es un token JWT/OAuth, invalidar la sesión del usuario afectado (ej. Forzar _logout_ o añadir el token al _blacklist_ en Redis/DB).|
|[ ] **Verificación:**|Intentar usar la credencial revocada inmediatamente. El resultado esperado es un código de error de autenticación (ej. HTTP 401).|
|[ ] **Notificación Inicial:**|Notificar al equipo de DevOps/Seguridad en el canal de incidentes (Slack/Teams) con el tipo de credencial y la hora de revocación.|

## 2. Análisis Forense: Identificación de la Fuente de Exposición (Fase II)

**Objetivo:** Determinar DÓNDE (repositorio, log, base de datos) y CÓMO (Commit Hash) se filtró la credencial.

|Tarea|Procedimiento de Análisis y Comandos|
|---|---|
|[ ] **Auditoría de Detección:**|Revisar las alertas del _Secret Scanning_ (GitHub Secret Scanning, GitGuardian) para obtener el commit ID, fecha y autor responsable de la filtración.|
|[ ] **Revisión de Historial Git:**|Buscar en el historial de Git (incluyendo ramas antiguas y _reflog_) la credencial completa o parcial.<br><br>**Comando:** `git grep -i "AKIA\|sk_live" $(git rev-list --all)`|
|[ ] **Revisión de Logs:**|Buscar la credencial en logs de aplicación (últimas 72 horas) o _stack traces_ en el SIEM/CloudWatch, utilizando patrones de expresiones regulares.|
|[ ] **Verificación Pública:**|Buscar la clave expuesta en servicios públicos de archivos (Pastebin, Gist, Repositorios públicos) para evaluar la visibilidad del incidente.|
|[ ] **Documentación:**|Registrar el **Commit ID**, **Ruta del Archivo** y **Fecha de Exposición** en la plantilla de Post-Mortem.|

## 3. Remediación y Despliegue de la Nueva Credencial

**Objetivo:** Eliminar la credencial expuesta de forma irrecuperable y restaurar la funcionalidad del servicio con un nuevo secreto.

|Tarea|Procedimiento de Remediación|
|---|---|
|[ ] **Purga de Repositorio:**|**CRÍTICO.** Utilizar herramientas forenses de reescritura de historial (BFG Repo-Cleaner o `git filter-repo`) para purgar la credencial de **TODOS** los _commits_ y _branches_. **Esto requiere un `git push --force` coordinado.**|
|[ ] **Limpieza de Logs:**|Redactar la credencial expuesta en logs de archivo (si no son inmutables) o eliminar el _log stream_ comprometido en el Cloud. Rotar logs inmediatamente.|
|[ ] **Generación Segura:**|Generar una nueva credencial de alta entropía (mínimo 32 caracteres) utilizando una herramienta criptográfica (`openssl rand`).|
|[ ] **Almacenamiento en Vault:**|Almacenar la nueva credencial en el **Gestor de Secretos Dedicado** (Vault, AWS Secrets Manager) con una política de acceso mínima (Least Privilege).|
|[ ] **Despliegue y Validación:**|Inyectar la nueva credencial en el _runtime_ de la aplicación (Kubernetes/ECS) y validar la funcionalidad del servicio comprometido.|

## 4. Análisis de Impacto y Prevención de Recurrencia (Fase III: Cierre)

**Objetivo:** Cuantificar el impacto del incidente y establecer controles preventivos permanentes.

|Tarea|Procedimiento de Cierre y Lecciones Aprendidas|
|---|---|
|[ ] **Auditoría de Logs:**|Analizar los logs de acceso (CloudTrail, Audit Logs) del servicio comprometido para detectar cualquier **actividad anómala** (accesos desde IPs desconocidas, creación de nuevos usuarios, exfiltración de datos).|
|[ ] **Cuantificación del Impacto:**|Determinar el número de usuarios potencialmente afectados y el costo financiero estimado (ej. API calls fraudulentas).|
|[ ] **Acciones Correctivas:**|Implementar controles preventivos técnicos: **1)** Habilitar _Push Protection_ en GitHub, **2)** Instalar _pre-commit hooks_ (ej. `detect-secrets`) en todos los repositorios, y **3)** Automatizar la rotación periódica de la credencial.|
|[ ] **Cierre Formal:**|Documentar el análisis completo en la **Plantilla de Post-Mortem** (incluida al final del Playbook) y comunicar el resultado a los _stakeholders_ ejecutivos y legales.|

## 5. Plantilla de Post-Mortem y Referencias

**(Esta sección se adjunta como evidencia de cierre del incidente)**

_Incluir aquí la Plantilla de Post-Mortem del Playbook (Resumen, Línea de Tiempo, Causa Raíz, Impacto, Acciones Correctivas)._

### Referencias Técnicas Clave

- **Gestión de Credenciales:** `guides/secret-management-guide.md` (Protocolo de uso de Vault).
    
- **Limpieza Forense:** Herramientas de reescritura de Git (BFG Repo-Cleaner, git-filter-repo).
