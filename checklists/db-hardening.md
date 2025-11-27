# Hardening de Bases de Datos (PostgreSQL)

**Referencia:** T-16 (Guía de Implementación Final) 

**Versión:** 1.0 

**Propósito:** Establecer una configuración de seguridad de línea base (Baseline Security Configuration) para PostgreSQL, asegurando la **Confidencialidad, Integridad y Disponibilidad (CID)** de los datos sensibles (PII/KYC) y mitigando vectores de ataque de escalada de privilegios y fuga de información.

**Base Normativa:** ISO/IEC 27001 (A.5.14, A.8.19), PCI DSS (Requisito 3.2), OWASP Data Security.

## 1. Autenticación, Roles y Segregación de Privilegios (RBAC)

El control de acceso basado en roles (RBAC) es la defensa más importante contra la fuga de datos interna.

|ID|Control|Requisito de Implementación y Justificación Técnica|Verificación|Estado|
|---|---|---|---|---|
|**D-1.1**|**Restricción del Superusuario**|**CRÍTICO.** El rol predeterminado `postgres` debe ser renombrado, su contraseña cambiada a una clave de alta entropía y su uso debe limitarse **estrictamente a tareas de mantenimiento del sistema (DBA)**. **Prohibido** su uso por la aplicación o microservicios.|Verificar `pg_hba.conf` y el catálogo de roles.|[ ]|
|**D-1.2**|**Modelo de Cuentas de Servicio (Least Privilege)**|**CRÍTICO.** Cada aplicación, microservicio o función debe utilizar un rol de base de datos dedicado (ej. `app_transferencias`). El rol solo debe tener los permisos **mínimos necesarios** (SELECT/INSERT/UPDATE) y ningún permiso DDL (CREATE/DROP/ALTER) en esquemas de producción.|Ejecutar consulta para auditar `role_has_privilege()` y `GRANT` statements.|[ ]|
|**D-1.3**|**Asegurar Autenticación (pg_hba.conf)**|El archivo `pg_hba.conf` debe configurarse para aceptar **solo** métodos de autenticación seguros (`scram-sha-256`, `cert`, o `ldap/kerberos`). Los métodos `trust` y `password` (no cifrado) están prohibidos.|Auditar `pg_hba.conf` para asegurar `scram-sha-256` como método principal para todos los hosts confiables.|[ ]|
|**D-1.4**|**Restricción de Conexiones por Red**|Limitar las direcciones IP o subredes desde las cuales se permite la conexión a la base de datos de producción. La conexión debe provenir únicamente de las capas de aplicación o de servicios de red interna (VPC/VNet).|Auditar `pg_hba.conf` y reglas del _Security Group_ Cloud.|[ ]|
|**D-1.5**|**Hardening del Nivel de Esquema**|Los roles de aplicación **no deben** tener permisos en los esquemas donde se almacena información de log o configuración interna. Usar `REVOKE ALL ON SCHEMA public FROM public;`.|Verificar que el esquema público no tenga permisos predeterminados.|[ ]|

## 2. Cifrado de Datos (A.8.19 y Requisito PCI)

El cifrado debe aplicarse en todo el ciclo de vida del dato: en reposo (storage), en tránsito (network) y, si es necesario, a nivel de columna (aplicación).

|ID|Control|Requisito de Implementación y Justificación Técnica|Verificación|Estado|
|---|---|---|---|---|
|**D-2.1**|**Cifrado en Tránsito (SSL/TLS Forzado)**|**CRÍTICO (PCI).** Forzar todas las conexiones de cliente-servidor a usar cifrado TLS 1.2 o superior. Configurar el servidor para rechazar conexiones no cifradas.|Configurar `ssl = on` y `ssl_ciphers = 'HIGH:!aNULL:!MD5'` en `postgresql.conf`.|[ ]|
|**D-2.2**|**Cifrado en Reposo (At Rest Encryption)**|**CRÍTICO (ISO A.8.19).** El volumen de almacenamiento donde residen los datos y logs debe estar cifrado de forma transparente mediante el proveedor Cloud (ej. AWS KMS/EBS Encryption, Azure Key Vault).|Verificar configuración de volúmenes (EBS, discos VM) en el proveedor Cloud.|[ ]|
|**D-2.3**|**Gestión y Ciclo de Vida del Certificado TLS**|El certificado SSL/TLS de la base de datos debe ser generado por una CA válida (o interna) y debe gestionarse su rotación automática y revocación (A.6.6).|Auditar `ssl_cert_file`, `ssl_key_file` y el servicio de rotación (ej. Certbot, AWS Certificate Manager).|[ ]|
|**D-2.4**|**Cifrado a Nivel de Aplicación/Columna**|Para información **Restringida** que requiere protección adicional (ej. números de cuenta parciales) se debe utilizar **PGP** o la extensión **pgcrypto** para cifrar datos a nivel de aplicación antes de que sean escritos al disco.|Auditar el uso de funciones criptográficas y las claves de cifrado (que no deben residir en la DB).|[ ]|

## 3. Hardening de Configuración y Ejecución (Anti-Escalada)

Mitigación de ataques de persistencia y escalada de privilegios a nivel de OS.

|ID|Control|Requisito de Implementación y Justificación Técnica|Verificación|Estado|
|---|---|---|---|---|
|**D-3.1**|**Deshabilitar Funciones de Ejecución de Shell**|**CRÍTICO.** Deshabilitar módulos y funciones que permiten la ejecución de código de sistema operativo (`shell`) desde comandos SQL (ej. `plpythonu`, `plperl`). Estas extensiones deben ser instaladas solo si son absolutamente necesarias.|Verificar que `plpythonu` y `plperl` estén deshabilitadas si no se utilizan activamente.|[ ]|
|**D-3.2**|**Limitar Alcance de Errores y Versiones**|Configurar el _logging_ de errores para **no revelar** información sensible sobre el esquema de la base de datos, versiones de software o _stack traces_ al cliente final o al sistema de la aplicación.|Ajustar `log_min_error_statement` y `client_min_messages` en `postgresql.conf`.|[ ]|
|**D-3.3**|**Restricción de Extensiones (Whitelisting)**|Solo las extensiones **aprobadas por el equipo de seguridad** deben estar permitidas en `shared_preload_libraries`. Deshabilitar cualquier extensión que aumente la superficie de ataque del servidor.|Auditar la lista de `shared_preload_libraries` en `postgresql.conf`.|[ ]|
|**D-3.4**|**Límites de Recursos y Conexiones**|Configurar `max_connections` y `work_mem` para evitar ataques de Denegación de Servicio (DoS) o el agotamiento de memoria del sistema operativo (OOM Kill).|Ajustar parámetros de memoria y límites de conexión según el tamaño del servidor.|[ ]|
|**D-3.5**|**Actualización de `TimescaleDB` / `PostGIS`**|Si se utilizan extensiones de terceros, deben mantenerse con el mismo ciclo de parches de seguridad que el motor principal de PostgreSQL para evitar vulnerabilidades heredadas.|Verificar el número de versión de todas las extensiones instaladas.|[ ]|

## 4. Auditoría, Logging y Detección (Detección)

Los logs inmutables y detallados son esenciales para la fase de **RESPUESTA A INCIDENTES**.

|ID|Control|Requisito de Implementación y Justificación Técnica|Verificación|Estado|
|---|---|---|---|---|
|**D-4.1**|**Auditoría de Sentencias DDL y DML**|**CRÍTICO.** Registrar todas las sentencias DDL (CREATE/ALTER/DROP) y sentencias DML (INSERT/UPDATE/DELETE) para detectar cambios no autorizados en el esquema o datos.|Configurar `log_statement = 'all'` o utilizar **`pgaudit`** para granularidad de sesión y objeto.|[ ]|
|**D-4.2**|**Registro de Autenticación Fallida**|Habilitar el _logging_ de conexiones fallidas, desconexiones y picos de intentos de _login_ para detectar ataques de fuerza bruta.|Ajustar `log_connections`, `log_disconnections`, y verificar la integración con Fail2Ban (T-04).|[ ]|
|**D-4.3**|**Centralización de Logs y la Inmutabilidad**|**CRÍTICO.** Los logs deben ser recolectados por un sistema SIEM centralizado (Splunk, CloudWatch, etc.) y no deben ser modificables localmente.|Verificar la configuración de _forwarding_ y que el directorio de logs local (`/var/log/postgresql`) tenga permisos restringidos.|[ ]|
|**D-4.4**|**Formato de Logs para Análisis (CSV)**|Configurar el formato de logs a `csvlog` para facilitar el _parsing_ y la ingestión automatizada por el SIEM.|Establecer `logging_collector = on` y `log_destination = 'csvlog'`.|[ ]|

## 5. Mantenimiento, Parcheo y Respaldo Seguro (Mantenimiento)

|ID|Control|Requisito de Implementación y Justificación Técnica|Verificación|Estado|
|---|---|---|---|---|
|**D-5.1**|**Parcheo y Actualización**|Mantener la versión de PostgreSQL con parches de seguridad activos (evitar versiones EOL). Aplicar actualizaciones de seguridad del SO de forma desatendida.|Documentar la versión actual y el ciclo de parches.|[ ]|
|**D-5.2**|**Seguridad del Respaldo (Backup)**|Los archivos de respaldo deben estar cifrados de forma independiente de la base de datos de producción y su acceso debe ser restringido solo a los roles de recuperación.|Verificar las políticas de cifrado y retención de los _backup buckets_.|[ ]|
|**D-5.3**|**Segregación de Ambientes**|Las credenciales, datos y configuraciones de los ambientes de **Producción** deben estar totalmente segregadas de los ambientes de Staging, QA y Desarrollo.|Verificar que no haya conectividad de _staging_ a producción o uso compartido de credenciales.|[ ]|
