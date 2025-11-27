# Política de Contraseñas y Autenticación Multifactor (MFA)

**Identificador:** P-ID-001 **Versión:** 1.0
**Propietario:** Equipo de Ciberseguridad / Liderazgo de Producto (Florencia) **Base de Cumplimiento:** NIST SP 800-63B (Digital Identity Guidelines) & ISO/IEC 27001.

## 1. Principios Fundamentales

Esta política establece los requisitos mínimos para la creación, protección y gestión de credenciales de acceso para reducir el riesgo de _Account Takeover_ y fraude. Nuestro enfoque se centra en la longitud, la prohibición de patrones débiles y la obligatoriedad de la **Autenticación Multifactor (MFA)**. La implementación debe priorizar la usabilidad para el usuario final sin comprometer la seguridad.

## 2. Requisitos de Composición y Creación de Contraseñas

La Compañía exige la implementación de las siguientes reglas de composición, priorizando la **longitud** sobre la complejidad artificial (ej. rotación forzada). La validación debe realizarse en el lado del servidor.

|Categoría de Usuario|Longitud Mínima (Requisito NIST)|Regla de Composición|Estado|
|---|---|---|---|
|**Cuentas Privilegiadas (Administradores, Root)**|**16 caracteres**|Incluir minúsculas, mayúsculas, números y símbolos. Se recomienda el uso de gestores de contraseñas corporativos.|[ ]|
|**Empleados (Sistemas Internos/Cloud)**|**14 caracteres**|Prohibición de uso de palabras completas, nombres propios comunes o datos de la compañía (ej. nombre del proyecto, mes actual).|[ ]|
|**Usuarios Finales (Clientes de la App)**|**12 caracteres**|Se recomiendan _passphrases_ (frases de acceso) de 3 o más palabras.|[ ]|
|**Lista Negra de Contraseñas**|N/A|**CRÍTICO:** El sistema debe validar las contraseñas nuevas y modificadas contra una lista de credenciales conocidas en brechas de datos (ej. Troy Hunt's Pwned Passwords) y diccionarios comunes.|[ ]|

## 3. Autenticación Multifactor (MFA) - Control Crítico

**El MFA es un control obligatorio para todos los roles de alto riesgo.** La implementación de MFA eleva el Nivel de Aseguramiento de la Autenticación (AAL) según NIST 800-63B, especialmente para accesos remotos y gestión de datos sensibles.

|Rol / Tipo de Acceso|Requisito de MFA|Nivel de Riesgo|Estado|
|---|---|---|---|
|**Cuentas Privilegiadas (Cloud, DevOps, Bases de Datos)**|**Obligatorio** para todos los accesos. Se prefiere TOTP (Time-Based One-Time Password) o WebAuthn sobre otros métodos.|Crítico|[ ]|
|**Empleados (Acceso Remoto a Sistemas Internos)**|**Obligatorio** para el acceso a la VPN o SSO corporativo. Debe ser un método resistente al _phishing_.|Crítico|[ ]|
|**Transacciones de Alto Valor (Clientes)**|**Obligatorio** para transacciones que superen un umbral monetario definido (ej. transferencias, cambio de dirección).|Alto|[ ]|
|**Métodos de Respaldo**|Los mecanismos de recuperación de cuentas deben requerir múltiples factores seguros y estar auditados (ej. código de recuperación + correo/teléfono). **Queda prohibido el SMS como factor único.**|Moderado|[ ]|

## 4. Gestión Técnica de Credenciales (Hardening)

Estos controles aseguran que las contraseñas, una vez creadas, se almacenen y transmitan de forma segura, garantizando la integridad de las credenciales en todo el ciclo de vida.

|Control|Verificación Técnica|Vínculo con Política|Estado|
|---|---|---|---|
|**Almacenamiento Seguro (Hashing)**|¿Las contraseñas se almacenan mediante algoritmos modernos de hashing unidireccional y lento (Argon2 o bcrypt con _cost factor_ alto) y con un _salt_ único y aleatorio para cada usuario?|ISO 27001|[ ]|
|**Transmisión Segura (TLS)**|¿Todo el tráfico de autenticación (Login/Registro) está forzado a través de TLS 1.2 o superior, con la implementación de HSTS (HTTP Strict Transport Security)?|ISO 27001|[ ]|
|**Prohibición de Rotación Forzada**|¿Se ha eliminado la política de rotación forzada periódica (ej. cada 90 días) para reducir la fatiga de contraseñas? **La rotación solo debe ser forzada en caso de compromiso conocido.**|NIST 800-63B|[ ]|
|**Bloqueo por Fallos**|¿El sistema bloquea temporalmente la cuenta después de un máximo de 5 intentos fallidos de autenticación en un periodo de 15 minutos?|Práctica Antifraude|[ ]|
|**Timeout de Sesión**|¿Las sesiones de usuario/empleado finalizan automáticamente después de 15 minutos de inactividad, y las sesiones privilegiadas no superan las 4 horas de duración máxima?|ISO 27001|[ ]|

## 5. Procedimiento de Incidentes y Mantenimiento

Esta sección define el protocolo para la detección, respuesta y el mantenimiento proactivo de las políticas de identidad.

|Control|Procedimiento|Responsable|Estado|
|---|---|---|---|
|**Reporte de Credenciales Comprometidas**|El protocolo de reporte de incidentes (Playbooks T-14) está activado para el bloqueo de cuentas y notificación al usuario y a las autoridades competentes en el tiempo establecido por la regulación (ej. 72 horas).|Equipo de Ciberseguridad|[ ]|
|**Auditoría de Cuentas Privilegiadas**|Las cuentas con acceso elevado (DB Admin, Cloud Admin) son revisadas trimestralmente para asegurar la vigencia del MFA y el principio de **Need-to-Know**. Se verifica que no existan cuentas huérfanas.|Propietario del Activo|[ ]|
|**Cierre de Ciclo**|Se verifica que las credenciales son revocadas inmediatamente durante el proceso de _offboarding_ (T-02). El registro de revocación debe ser auditable.|RRHH/TI|[ ]|
|**Revisión Anual de la Política**|La política será revisada y actualizada anualmente o ante cambios en las regulaciones (GDPR, PCI, etc.).|Liderazgo de Producto|[ ]|

**Auditor (Revisión Final):** ******___****** **Fecha de Auditoría:** ******___******
