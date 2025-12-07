# Guía de Implementación Segura de JWT (JSON Web Tokens)

**Referencia:** T-17 **Versión:** 1.0 

**Propósito:** Definir los requisitos mandatorios para la generación, validación, almacenamiento y ciclo de vida de los tokens JWT utilizados para la autenticación y autorización en la Super App Fintech. 

**Base Normativa:** RFC 7519, OWASP Session Management Cheat Sheet, NIST SP 800-63B.

## 1. Principios de Diseño Criptográfico

La seguridad del token reside enteramente en la robustez de su firma y la gestión de sus claves.

### 1.1. Algoritmos de Firma Permitidos

- **Producción:** Se debe utilizar exclusivamente algoritmos asimétricos **RS256** (RSA Signature with SHA-256) o **ES256** (ECDSA).
    
    - _Justificación:_ Permite que múltiples microservicios validen el token usando la clave pública sin necesidad de compartir la clave privada, reduciendo la superficie de ataque.
        
- **Prohibición:** El uso de algoritmos simétricos (HS256) está restringido a servicios internos monolíticos y requiere aprobación de seguridad.
    
- **Hardening:** El servidor debe rechazar explícitamente cualquier token con el encabezado `alg: "none"` o algoritmos débiles.
    

### 1.2. Gestión de Claves Privadas

- **Almacenamiento:** La clave privada utilizada para firmar tokens debe almacenarse en un **Gestor de Secretos** (Vault/KMS) y nunca en el código fuente o variables de entorno no cifradas (Ver _Guía de Gestión de Secretos S1-T07_).
    
- **Rotación:** Se debe implementar un mecanismo de rotación de claves (Key Rotation) automatizado. El servidor debe soportar la validación con la clave anterior durante un periodo de gracia (ej. 24 horas).
    

## 2. Validación Estricta de Claims (Reclamos)

No basta con verificar la firma; el contenido del token debe ser validado lógicamente en cada petición.

### 2.1. Claims Estándar Obligatorios

|Claim|Nombre|Requisito de Validación|
|---|---|---|
|**`exp`**|Expiration Time|**CRÍTICO.** El servidor debe rechazar cualquier token cuya fecha actual sea posterior a `exp`.|
|**`iss`**|Issuer|Validar que el emisor sea de confianza (ej. `https://auth.superapp.com`). Evita aceptar tokens de otros entornos (Dev/Staging).|
|**`aud`**|Audience|Validar que el token fue emitido específicamente para el servicio que lo está recibiendo (ej. `api-pagos`). Evita el reuso de tokens entre servicios.|
|**`sub`**|Subject|Identificador inmutable y único del usuario (UUID). No usar emails o usernames que puedan cambiar.|

### 2.2. Información Sensible (Payload)

- **Prohibición:** Nunca incluir información sensible (PII, contraseñas, saldos financieros) dentro del _payload_ del JWT. El token es codificado en Base64, **no cifrado**, y cualquiera puede leer su contenido.
    
- **Minimización:** Incluir solo los identificadores y roles (scopes) mínimos necesarios para la autorización.
    

## 3. Almacenamiento y Transmisión (Cliente)

El vector de ataque más común para el robo de sesiones JWT es el Cross-Site Scripting (XSS).

### 3.1. Almacenamiento en el Navegador

- **LocalStorage / SessionStorage:** **ESTRICTAMENTE PROHIBIDO** para almacenar Access Tokens o Refresh Tokens. Cualquier script malicioso (XSS) puede leer estos almacenamientos.
    
- **Cookies Seguras:** Los tokens deben almacenarse en **Cookies** con las siguientes banderas obligatorias:
    
    - `HttpOnly`: Impide el acceso desde JavaScript (mitiga XSS).
        
    - `Secure`: Solo se envía sobre HTTPS.
        
    - `SameSite=Strict` o `Lax`: Mitiga ataques CSRF.
        

### 3.2. Transmisión

- El token debe enviarse preferiblemente en el encabezado estándar: `Authorization: Bearer <token>`
    
- Si se usa el patrón de cookies, el backend debe estar configurado para extraer el token de la cookie firmada.
    

## 4. Ciclo de Vida y Revocación

Dado que los JWT son "stateless" (sin estado), su revocación inmediata es un desafío técnico que debe ser abordado.

### 4.1. Tiempos de Expiración (`exp`)

- **Access Token:** Corta duración (Short-lived). Recomendado: **5 a 15 minutos**. Esto limita la ventana de oportunidad si el token es robado.
    
- **Refresh Token:** Larga duración. Recomendado: **12 a 24 horas** (con rotación).
    

### 4.2. Estrategia de Revocación (Logout / Compromiso)

Para permitir el cierre de sesión inmediato o bloquear usuarios comprometidos:

1. **Lista de Bloqueo (Blacklist/Denylist):** Almacenar el `jti` (JWT ID) de los tokens revocados en una base de datos rápida (Redis) con un TTL igual al tiempo restante de expiración del token.
    
2. **Invalidación de Usuario:** Incluir un `token_version` en el JWT y en la base de datos de usuarios. Si el usuario cambia su contraseña o reporta robo, se incrementa la versión en la DB, invalidando todos los tokens antiguos.
    

### 4.3. Rotación de Refresh Tokens

- Al utilizar un Refresh Token para obtener un nuevo Access Token, el sistema debe emitir también un **nuevo Refresh Token** y revocar el anterior (Refresh Token Rotation). Esto permite detectar robos si un atacante intenta usar un token antiguo.
    

## 5. Checklist de Verificación para Code Review

Antes de aprobar un PR relacionado con autenticación:

- [ ] ¿Se utiliza una librería de JWT madura y mantenida (ej. `PyJWT`, `jsonwebtoken`) en lugar de una implementación propia?
    
- [ ] ¿El algoritmo de firma está forzado explícitamente en el código de verificación (ej. `algorithms=['RS256']`)?
    
- [ ] ¿Están definidos y validados los tiempos de expiración?
    
- [ ] ¿Se están validando `iss` y `aud`?
    
- [ ] ¿El secreto/clave privada se inyecta desde el Gestor de Secretos y no está hardcodeado?
