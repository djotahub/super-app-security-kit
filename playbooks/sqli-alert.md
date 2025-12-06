# Playbook: Intento de Inyección SQL (SQLi)

**Clasificación del Incidente:** Intento de Inyección de Código (SQLi) **Severidad Clasificada:** CRÍTICA **Tiempo Objetivo de Respuesta:** $< 10$ minutos (detección y notificación) **Tiempo Objetivo de Contención:** $< 30$ minutos (bloqueo en WAF/Firewall) **Documento Vinculado:** Checklist de Hardening de Bases de Datos (T-16)

## 1.0 Protocolo de Respuesta Estratégica (Fase I: Contención)

**Objetivo:** Mitigar el riesgo en curso mediante el bloqueo de la IP de origen y la prevención de futuras peticiones maliciosas.

### 1.1 Tarea Crítica: Contención Inmediata y Bloqueo de Origen (0-5 minutos)

|Tarea|Procedimiento Operacional|
|---|---|
|**Identificación de Origen**|Determinar la IP de origen, el _endpoint_ y la carga útil (_payload_) a partir de las alertas del WAF/IDS. Registrar las variables clave: `ATTACKER_IP`, `ENDPOINT`, `TIMESTAMP`.|
|**Bloqueo Perimetral (WAF/Firewall)**|Agregar el `ATTACKER_IP` a la lista de denegación (Block List) del servicio de protección perimetral (AWS WAF, Cloudflare, Nginx ModSecurity). Aplicar el bloqueo a nivel de Capa 3/4 y Capa 7 (WAF).|
|**Verificación de Bloqueo**|Validar inmediatamente la efectividad del bloqueo intentando acceder al _endpoint_ comprometido desde el `ATTACKER_IP`. El resultado esperado es un `403 Forbidden` o _timeout_.|
|**Notificación Formal**|Notificar al canal de incidentes (Slack/Teams) indicando la IP, el _endpoint_ y confirmando que la contención perimetral ha sido **ejecutada**.|

## 2.0 Análisis de Impacto y Determinación de Éxito (Fase II)

**Objetivo:** Determinar si el ataque penetró la aplicación y obtuvo acceso no autorizado a los datos.

### 2.1 Análisis Forense del Payload

|Tarea|Procedimiento de Análisis|
|---|---|
|**Clasificación del Payload**|Decodificar la carga útil (`payload`) (URL/Base64) e identificar el tipo de SQLi (ej. Union-based, Time-based, Destructivo) para enfocar el análisis de riesgo.|
|**Auditoría de Logs de Base de Datos**|Revisar los logs de la Base de Datos (PostgreSQL/MySQL) para detectar cualquier ejecución de consultas anómalas (ej. `UNION SELECT`, `SLEEP()`, comandos DDL).|
|**Verificación de Controles**|Confirmar si el _request_ fue bloqueado por los controles de la aplicación (ej. _Prepared Statements_) o si generó un error de sintaxis en la DB.|
|**Cuantificación del Impacto**|Determinar el número de registros potencialmente accedidos, modificados o eliminados. Registrar el estado de _Authentication Bypass_.|

### 2.2 Indicadores de Compromiso y Escalada

- **Ataque No Exitoso:** WAF bloqueó la petición, o la aplicación usó consultas parametrizadas (Evidencia: Ausencia de _queries_ anómalas en logs de DB).
    
- **Ataque Exitosa:** Ejecución de _queries_ DDL/DML no autorizadas en la base de datos (Ejemplo: `DROP TABLE`, `UPDATE` de datos de usuario).
    

## 3.0 Análisis de Causa Raíz (Root Cause Analysis - RCA)

**Objetivo:** Identificar la línea de código exacta que permitió la vulnerabilidad para aplicar un parche permanente.

### 3.1 Identificación del Vector Vulnerable

|Tarea|Procedimiento de RCA|
|---|---|
|**Revisión del Código Fuente**|Localizar el archivo y la línea de código del _endpoint_ comprometido (`/api/users`).|
|**Identificación de Patrón**|Confirmar la presencia de concatenación de _strings_ con _input_ de usuario para construir la consulta SQL (Ejemplo: `query = "SELECT... WHERE id = " + user_id`).|
|**Documentación Formal**|Documentar la vulnerabilidad: Archivo, Línea, Parámetro Vulnerable, y el identificador **CWE-89** (Improper Neutralization of Special Elements in SQL Command).|

### 3.2 Remediación Inmediata de Código

- **Solución Permanente:** Aplicar consultas **parametrizadas** (Prepared Statements) utilizando el ORM o APIs nativas seguras de la base de datos (ej. `psycopg2` en Python, `mysql2` en Node.js).
    
- **Validación:** Implementar validación de _Input_ robusta (tipo y longitud) antes de que el dato toque la capa de la base de datos.
    
- **Despliegue:** Crear una rama de _hotfix_, aplicar el _commit_ del parche, y desplegar inmediatamente el fix en producción.
    

## 4.0 Fortalecimiento de Defensas y Cierre Formal (Fase IV)

**Objetivo:** Implementar controles preventivos permanentes y documentar el incidente.

### 4.1 Acciones de Refuerzo Perimetral y Código

|Tarea|Protocolo de Fortalecimiento|
|---|---|
|**WAF/IDS Hardening**|Revisar y aplicar reglas de **WAF** más estrictas contra patrones SQLi (ej. OWASP Core Rule Set) a todos los _endpoints_ públicos.|
|**Escaneo Proactivo (SAST)**|Ejecutar el escáner **SAST** (Semgrep, T-12) en todo el código base para identificar **patrones vulnerables similares** (concatenación SQL).|
|**Generación de Ticket**|Crear un ticket de alta prioridad (P0/P1) en el gestor de tareas para la remediación de todas las vulnerabilidades similares encontradas por SAST.|
|**Validación de Parche**|Correr un escaneo DAST (ZAP) contra el _endpoint_ corregido en _staging_ para confirmar que la vulnerabilidad ha sido mitigada exitosamente.|

### 4.2 Cierre y Documentación Formal

- **Post-Mortem:** Completar la **Plantilla de Post-Mortem** (incluida en el Playbook) detallando la línea de tiempo, la causa raíz, las lecciones aprendidas y los costos.
    
- **Notificación Legal:** Comunicar los hallazgos a los _stakeholders_ ejecutivos y legales para asegurar el cumplimiento con las obligaciones de notificación de incidentes de seguridad (GDPR/PCI DSS).
    
- **Capacitación:** Programar una sesión de capacitación para el equipo de desarrollo sobre la prevención de la inyección SQL y el uso de consultas parametrizadas.
    

## 5.0 Matriz de Verificación Post-Incidente

|Verificación Post-Incidente|Estado|
|---|---|
|Código vulnerable identificado y parchado en producción|[ ]|
|Ataque analizado y cuantificado|[ ]|
|WAF y sistemas de seguridad actualizados con la nueva IP/Regla|[ ]|
|Escaneo SAST completado en todo el código base|[ ]|
|Post-Mortem documentado y archivado|[ ]|

### Referencias Técnicas Clave

- **Guía de Prevención:** OWASP SQL Injection Prevention Cheat Sheet.
    
- **Herramienta de Búsqueda:** Semgrep (para búsqueda de patrones vulnerables en el código).
    
- **Hardening de DB:** Checklist Hardening de Bases de Datos (T-16).
