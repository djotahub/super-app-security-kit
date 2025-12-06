# Manual Técnico: Checklist de Revisión Manual de Código Seguro (Quality Gate)

 **Versión:** 1.0 
 
  **Propósito:** Definir el **Quality Gate de seguridad** que debe aplicarse antes de la integración de código (Pull Request). Este instrumento guía la revisión manual para la detección proactiva de fallos de diseño y vulnerabilidades de codificación.

**Base:** OWASP Top 10, OWASP Code Review Guide, Principios de Seguridad de Datos (GDPR/PCI DSS).

## 1. Validación Estricta de Entradas (Input Validation)

El principio es la **desconfianza absoluta** en cualquier dato originado fuera del perímetro de confianza (Boundary).

|ID|Área de Control|Verificación Técnica del Revisor|Nivel de Riesgo|Estado|
|---|---|---|---|---|
|**C-1.1**|**Validación de Tipo y Longitud**|¿Todo dato recibido (query params, body JSON, headers) valida estrictamente el tipo (int, float, string) y aplica límites de longitud máxima/mínima?|Alto|[ ]|
|**C-1.2**|**Lista Blanca (Allowlisting)**|¿El código utiliza la técnica de **lista blanca** para validar _inputs_ (ej. solo "A-Z" o "0-9") en lugar de listas negras (_blocklists_) que son fáciles de evadir?|Alto|[ ]|
|**C-1.3**|**Canonización del Input**|¿Se realiza la **canonización/normalización** del input antes de la validación para frustrar técnicas de evasión de _waf_ o _encoding_?|Moderado|[ ]|
|**C-1.4**|**Validación de Lógica de Negocio**|¿Se valida que los valores numéricos o transaccionales cumplan con la lógica de negocio (ej. el monto de transferencia no es negativo, la fecha de expiración de token es futura)?|Crítico|[ ]|

## 2. Prevención de Inyección (Injection Prevention)

La prevención de inyección debe ser verificada en toda interacción entre el código de la aplicación y la capa de persistencia o el sistema operativo subyacente.

|ID|Área de Control|Verificación Técnica del Revisor|Nivel de Riesgo|Estado|
|---|---|---|---|---|
|**C-2.1**|**SQL Injection (Parametrización)**|¿Se utilizan **exclusivamente consultas parametrizadas** (Prepared Statements) para todas las operaciones SQL que involucren _inputs_ de usuario? **La concatenación de** _**strings**_ **para construir SQL está estrictamente prohibida.**|Crítico|[ ]|
|**C-2.2**|**Comandos del Sistema Operativo**|¿Se utilizan APIs de lenguaje seguras (ej. `subprocess.run` con `shell=False` en Python) en lugar de funciones de ejecución de comandos de _shell_ (`os.system`, `exec()`)?|Alto|[ ]|
|**C-2.3**|**Validación de Datos en Cláusulas Especiales**|¿Se aplica validación estricta (o _whitelisting_) al usar _inputs_ de usuario en cláusulas SQL no parametrizables como `ORDER BY`, nombres de tablas o nombres de columnas?|Alto|[ ]|
|**C-2.4**|**Prevención de XSS (Output Encoding)**|¿Se utiliza la codificación de salida (`output encoding`) automática o el _escaping_ contextual (ej. `textContent` en JS, o _frameworks_ como React/Vue) antes de renderizar datos de usuario en HTML?|Alto|[ ]|

## 3. Autorización y Control de Acceso (Authorization Model)

La verificación de permisos debe ser estricta en cada capa, siguiendo el principio de **Fail-Safe Defaults**.

|ID|Área de Control|Verificación Técnica del Revisor|Nivel de Riesgo|Estado|
|---|---|---|---|---|
|**C-3.1**|**Broken Object Level Authorization (BOLA)**|¿Se verifica la **propiedad del recurso** (`ownership`) en el lado del servidor para asegurar que el usuario autenticado solo acceda a sus propios datos, frustrando ataques IDOR?|Crítico|[ ]|
|**C-3.2**|**Broken Function Level Authorization (BFLA)**|¿Se verifica el **rol del usuario (RBAC)** antes de ejecutar cualquier función administrativa o de alto privilegio, incluso si el _endpoint_ está protegido?|Crítico|[ ]|
|**C-3.3**|**Protección contra Mass Assignment**|¿Los modelos de datos o _requests_ de API utilizan **whitelisting** para ignorar atributos sensibles (ej. `role_id`, `balance`) que podrían ser modificados por un atacante?|Alto|[ ]|
|**C-3.4**|**Revisión de Flujos Privilegiados**|¿Las funciones que modifican el estado de las cuentas (ej. cambio de contraseña, restablecimiento de fondos) tienen _logging_ robusto y requerimientos de **re-autenticación**?|Alto|[ ]|

## 4. Gestión de Identidad y Sesiones (Authentication)

La autenticación debe seguir las directrices de **NIST 800-63B** para el manejo de credenciales y tokens.

|ID|Área de Control|Verificación Técnica del Revisor|Nivel de Riesgo|Estado|
|---|---|---|---|---|
|**C-4.1**|**Almacenamiento de Contraseñas**|¿Se utiliza un algoritmo de _hashing_ lento y con _salt_ (Argon2, Bcrypt) en lugar de _hashes_ rápidos (MD5, SHA-256 simple)?|Crítico|[ ]|
|**C-4.2**|**Manejo de Tokens JWT**|¿Se valida la **firma criptográfica**, el tiempo de expiración (`exp`) y la audiencia (`aud`) del token JWT en cada solicitud?|Alto|[ ]|
|**C-4.3**|**Restricción de Sesiones**|¿Los tokens de sesión/JWT tienen un tiempo de vida corto (short-lived) y las sesiones están sujetas a un _timeout_ de inactividad estricto (ej. 15 minutos)?|Moderado|[ ]|
|**C-4.4**|**Rate Limiting en Login**|¿Existe un mecanismo de _rate limiting_ y bloqueo temporal implementado en todos los _endpoints_ de autenticación para mitigar ataques de fuerza bruta?|Alto|[ ]|

## 5. Exposición de Información y Logging (Mitigación de GDPR)

El código no debe exponer información sensible al usuario o a logs sin la debida sanitización.

|ID|Área de Control|Verificación Técnica del Revisor|Nivel de Riesgo|Estado|
|---|---|---|---|---|
|**C-5.1**|**Exposición de Errores**|¿El manejo de excepciones global previene la exposición de _stack traces_, información de la base de datos o mensajes internos al cliente final?|Alto|[ ]|
|**C-5.2**|**Hardcoded Secrets**|¿El código utiliza variables de entorno o un Gestor de Secretos (Vault/KMS) para todas las claves API, tokens y credenciales de DB? (**Ver Guía S1-T07**).|Crítico|[ ]|
|**C-5.3**|**Sanitización de Logs**|¿El _logging_ del código en producción está configurado para **enmascarar o evitar** el registro de PII, contraseñas, tokens y CVV en texto plano?|Crítico|[ ]|
|**C-5.4**|**Headers de Seguridad**|¿El servidor o la aplicación define _headers_ de seguridad cruciales (CSP, HSTS, X-Content-Type-Options) para mitigar ataques en el lado del cliente?|Moderado|[ ]|

## 6. Integración y Criterios de Aprobación

Este checklist se utiliza como el **Quality Gate manual** que complementa las herramientas automáticas (SAST/DAST).

|Categoría|Criterio de Decisión|
|---|---|
|**APROBACIÓN**|**TODOS** los controles críticos (Nivel Crítico/Alto) han sido verificados. No hay vulnerabilidades de Inyección, Hardcoding o BOLA.|
|**RECHAZO**|El PR contiene cualquier forma de concatenación SQL con _input_ de usuario, _hardcoded secrets_, o un fallo de autorización (BOLA).|
|**EXCEPCIÓN**|Los riesgos moderados pueden ser aceptados solo si están documentados formalmente como **Riesgo Residual Aceptado** por el Propietario del Activo.|

**Auditor (Revisión Final):** **___** **Fecha de Revisión:** **___**
