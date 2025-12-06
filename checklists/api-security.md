# Audit Framework: Seguridad en APIs (OWASP API Security Top 10)

 **Versión:** 1.0 
 
 **Base:** OWASP API Security Top 10 (2023) 
 
 **Propósito:** Instrumento de verificación binaria para evaluar el riesgo de la superficie de ataque de las APIs (RESTful/GraphQL) contra fallos de autorización y lógica de negocio.

**Fecha de Auditoría:** **___** **API Auditada:** **___** **Tipo:** [ ] RESTful [ ] GraphQL

## 1. Controles Críticos de Autorización y Fraude (High Risk)

Estos controles son obligatorios para mitigar el riesgo de fraude financiero y exposición de datos PII/KYC.

### API1: Broken Object Level Authorization (BOLA)

|Estado|Verificación Técnica (Mitigación de Acceso a Recursos Ajeno)|
|---|---|
|[ ]|**Validación de Relación:** ¿El servidor valida la propiedad (`ownership`) del recurso (`ID`) contra la identidad del usuario autenticado (token)?|
|[ ]|**IDs No Secuenciales:** ¿Se utiliza UUIDs, IDs _hash_ o identificadores de alta entropía para prevenir la enumeración predecible de recursos?|
|[ ]|**Pruebas de Acceso:** ¿Se ha ejecutado testing con tokens válidos ajenos (`IDOR testing`) para verificar la defensa del endpoint?|

### API2: Broken Authentication (Gestión de Sesiones)

|Estado|Verificación Técnica (Manejo de Tokens y Sesiones)|
|---|---|
|[ ]|**Validación del JWT:** ¿Se valida la firma, la expiración (`exp`) y el emisor (`iss`) del JSON Web Token en cada petición?|
|[ ]|**Estándar de Transmisión:** ¿Se emplea el encabezado `Authorization: Bearer` o cookies `HttpOnly` y `Secure`? (Tokens en URL están prohibidos).|
|[ ]|**Revocación de Tokens:** ¿Existe un mecanismo eficiente (blacklist/lista de revocación) para invalidar tokens comprometidos **antes** de su expiración?|

### API3: Broken Object Property Level Authorization (Mass Assignment)

|Estado|Verificación Técnica (Protección de Atributos Internos)|
|---|---|
|[ ]|**Whitelisting de Inputs:** ¿La capa de la API/servicio ignora o rechaza explícitamente los campos de entrada que no son necesarios para la operación (ej. `role`, `balance`, `is_admin`)?|
|[ ]|**Inmutabilidad:** ¿Los atributos sensibles de la entidad (ej. datos de cumplimiento) están bloqueados para modificación directa desde cualquier petición del cliente?|
|[ ]|**Esquemas Rígidos:** ¿Los esquemas de entrada (validadores DTO/Pydantic/GraphQL) están definidos rígidamente para exponer solo los campos escribibles?|

## 2. Controles de Resiliencia y Detección (High/Medium Risk)

### API4: Unrestricted Resource Consumption (Rate Limiting)

|Estado|Verificación Técnica (Prevención de DoS y Fuerza Bruta)|
|---|---|
|[ ]|**Límites Globales/Por Usuario:** ¿Existe un límite de peticiones (Rate Limiting) configurado (ej. 100 req/min) aplicado en la capa de Gateway/Load Balancer?|
|[ ]|**Paginación Forzada:** ¿Los _endpoints_ que devuelven colecciones de datos tienen paginación obligatoria y un límite máximo de resultados por página (`limit` y `offset`)?|
|[ ]|**Timeouts y Recursos:** ¿Existen tiempos de espera (timeouts) configurados para operaciones pesadas que eviten el bloqueo del hilo de ejecución del servidor?|

### API5: Broken Function Level Authorization (BFLA)

|Estado|Verificación Técnica (Segregación de Privilegios)|
|---|---|
|[ ]|**Validación de Rol:** ¿Se verifica el rol del usuario (ej. `Analyst` vs. `Client`) en el servidor para el acceso a cualquier _endpoint_ administrativo o de auditoría?|
|[ ]|**Separación Lógica:** ¿Las funciones administrativas están separadas lógicamente de las funciones de usuario regular a nivel de código o servicio?|

### API7: Server Side Request Forgery (SSRF)

|Estado|Verificación Técnica (Protección de la Red Interna)|
|---|---|
|[ ]|**Filtrado de Inputs de URL:** Si la API acepta una URL como parámetro, ¿se utiliza un mecanismo de validación de lista blanca para asegurar que la URL no apunte a direcciones IP internas (ej. `127.0.0.1`, metadata de Cloud, subredes privadas)?|

## 3. Controles de Hardening, Logging y Lógica de Negocio (Medium/Bajo Riesgo)

### API8: Configuración Insegura

|Estado|Verificación Técnica|
|---|---|
|[ ]|**Política de CORS:** ¿La política de CORS es restrictiva y no utiliza `Access-Control-Allow-Origin: *` en entornos de producción?|
|[ ]|**Mensajes de Error:** ¿Los mensajes de error son genéricos y evitan filtrar detalles técnicos sensibles (ej. _stack traces_, versiones de lenguaje/framework)?|
|[ ]|**Forzar HTTPS (HSTS):** ¿El tráfico está forzado a través de TLS/HTTPS, y se utiliza HTTP Strict Transport Security (HSTS) para mitigar _downgrade attacks_?|

### API10: Logging y Monitoreo (Detección)

|Estado|Verificación Técnica|
|---|---|
|[ ]|**Logs de Transacciones:** ¿Se registran logs inmutables de transacciones sensibles (ej. transferencias de dinero, cambios de contraseña) con marcas de tiempo correctas?|
|[ ]|**Detección de Fallos de Auth:** ¿Existe un monitoreo configurado para alertar sobre picos inusuales en intentos fallidos de autenticación (fuerza bruta)?|

### Lógica de Negocio y Validación

|Estado|Verificación Técnica|
|---|---|
|[ ]|**Validación de Lógica de Negocio:** ¿Se aplican validaciones de negocio estrictas (ej. No se puede transferir un monto negativo, límites de tiempo en OTPs) para prevenir abusos del flujo?|
|[ ]|**Validación de Tipo/Formato:** ¿Se valida el tipo de dato y la longitud de todos los _inputs_ (ej. un campo numérico solo acepta números)?|

**Auditor (Revisión Final):** **___** **Fecha de Revisión:** **___**
