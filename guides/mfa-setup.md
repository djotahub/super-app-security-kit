# Guía de Implementación de Autenticación Multifactor (MFA)

**Referencia:** T-08 (Infraestructura e Identidad) 

**Versión:** 1.0

**Propósito:** Definir los estándares técnicos para elevar el nivel de aseguramiento de la identidad (Authenticator Assurance Level - AAL2) mediante la implementación obligatoria de MFA. Esta guía aplica tanto a los accesos de infraestructura (AWS, GitHub) como a la lógica de autenticación de la Super App. 

**Base Normativa:** NIST SP 800-63B (AAL2), ISO/IEC 27001 (A.9.4.2), PCI DSS (Req 8.3).

## 1. Estrategia de Autenticación y Métodos Permitidos

La implementación de MFA no es uniforme. Se debe priorizar la resistencia al _phishing_ y la criptografía fuerte sobre la conveniencia insegura.

### 1.1. Jerarquía de Métodos de Autenticación

|Método|Nivel de Seguridad|Estado en la Organización|Casos de Uso|
|---|---|---|---|
|**FIDO2 / WebAuthn**|**Máximo (AAL3)**|**Recomendado**|Llaves de hardware (YubiKey) o biometría de dispositivo (TouchID/FaceID) para administradores de Cloud/Root.|
|**TOTP (Time-based OTP)**|**Alto (AAL2)**|**Estándar Obligatorio**|Apps autenticadoras (Google Auth, Authy, Microsoft Auth). Estándar para empleados y usuarios finales de la App.|
|**Push Notification**|Medio/Alto|Aceptable|Notificaciones "Is this you?" en la app móvil. Requiere "Number Matching" para evitar _MFA Fatigue_.|
|**SMS / Voz**|Bajo (Restringido)|**Desaconsejado**|Vulnerable a _SIM Swapping_. Solo permitido como último recurso para usuarios finales si no hay otra opción. Prohibido para accesos administrativos.|
|**Email OTP**|Muy Bajo|**Prohibido como 2FA**|El correo es a menudo el mismo canal de recuperación de contraseña, por lo que no constituye un verdadero "segundo factor" independiente.|

## 2. Implementación en Infraestructura (Cloud & DevOps)

El acceso a la infraestructura crítica debe estar protegido por defecto.

### 2.1. AWS IAM (Identity and Access Management)

- **Política de Cumplimiento:** Todo usuario IAM con acceso a la consola debe tener MFA activado.
    
- **Enforcement (Mecanismo Técnico):** Aplicar una política IAM que deniegue todas las acciones excepto `iam:ChangePassword` y `iam:CreateVirtualMFADevice` a menos que `aws:MultiFactorAuthPresent` sea `true`.
    

```
{
    "Sid": "DenyAllExceptOwnMFA",
    "Effect": "Deny",
    "NotAction": [
        "iam:CreateVirtualMFADevice",
        "iam:EnableMFADevice",
        "iam:GetUser",
        "iam:ListMFADevices",
        "iam:ListVirtualMFADevices",
        "iam:ResyncMFADevice",
        "sts:GetSessionToken"
    ],
    "Resource": "*",
    "Condition": {
        "BoolIfExists": {
            "aws:MultiFactorAuthPresent": "false"
        }
    }
}
```

### 2.2. Repositorios de Código (GitHub/GitLab)

- **Requisito:** Configurar la organización para **exigir autenticación de dos factores** a todos los miembros.
    
- **Acción:** `Settings` -> `Security` -> `Authentication security` -> `Require two-factor authentication for everyone`.
    
- **Impacto:** Los desarrolladores deben configurar tokens de acceso personal (PAT) o claves SSH para operaciones de Git en línea de comandos.
    

### 2.3. Acceso Remoto (VPN / SSH)

- **SSH:** Configurar el módulo PAM `libpam-google-authenticator` en los servidores bastión (jump hosts) para requerir un código TOTP además de la clave SSH.
    
- **VPN:** Integrar el servicio VPN con el proveedor de identidad (IdP) corporativo (ej. Okta, Azure AD) para forzar el desafío de MFA en la conexión.
    

## 3. Implementación en la Aplicación (Desarrollo de Software)

Guía para integrar TOTP (RFC 6238) en la Super App para usuarios finales.

### 3.1. Flujo de Enrolamiento (Setup)

1. **Generación de Secreto:** El backend genera una clave secreta aleatoria de 160 bits (Base32) única por usuario.
    
2. **Almacenamiento:** El secreto se cifra (AES-256) antes de guardarse en la base de datos.
    
3. **Intercambio:** El backend envía el secreto al cliente como un código QR (URI `otpauth://totp/...`).
    
4. **Verificación Inicial:** El usuario debe ingresar un código válido generado por su app para confirmar la sincronización y activar el MFA.
    

### 3.2. Librerías Recomendadas

Evitar implementaciones criptográficas propias ("Rolling your own crypto"). Usar librerías maduras:

- **Python:** `pyotp`
    
- **Node.js:** `otplib` o `speakeasy`
    
- **Java:** `java-totp`
    
- **Go:** `pquerna/otp`
    

### 3.3. Ejemplo de Código (Python/pyotp)

```
import pyotp
import qrcode

# 1. Generar secreto base32 (Guardar esto cifrado en DB)
secret = pyotp.random_base32()

# 2. Generar URI para el QR Code
uri = pyotp.totp.TOTP(secret).provisioning_uri(
    name='usuario@fintech.com',
    issuer_name='SuperApp'
)

# 3. Verificar un código ingresado por el usuario
totp = pyotp.TOTP(secret)
is_valid = totp.verify('123456') # Retorna True/False
```

### 3.4. Códigos de Recuperación (Backup Codes)

- **Requisito:** Al activar MFA, se deben generar y mostrar al usuario **10 códigos de un solo uso**.
    
- **Almacenamiento:** Deben guardarse en la base de datos como _hashes_ (igual que las contraseñas), nunca en texto plano.
    
- **Uso:** Al usar un código de recuperación, este debe ser eliminado o marcado como usado inmediatamente.
    

## 4. Checklist de Validación de Seguridad MFA

Para considerar la implementación completa y segura:

- [ ] **Rate Limiting:** ¿El endpoint de validación de MFA tiene límites de tasa estrictos (ej. 5 intentos por minuto) para evitar fuerza bruta al espacio de 6 dígitos?
    
- [ ] **No Divulgación:** ¿Los mensajes de error de MFA no revelan si el usuario existe o si la primera fase (password) fue correcta (Timing attacks)?
    
- [ ] **Re-autenticación:** ¿Las acciones críticas (cambio de password, transferencia de fondos > $X) solicitan el código MFA nuevamente aunque la sesión esté activa?
    
- [ ] **NTP:** ¿Los servidores tienen sincronización de tiempo (NTP) correcta para evitar fallos de validación TOTP?
    
- [ ] **Logs:** ¿Se registran los eventos de éxito y fallo de MFA (sin loguear el código en sí)?
    

**Auditor:** **___** **Fecha de Revisión:** **___**
