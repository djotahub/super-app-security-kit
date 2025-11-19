# Política de Gestión de Activos

**Referencia:** T-02 **Versión:** 1.0 **Fecha de Aprobación:** [Fecha]

## 1. Propósito y Alcance

**Propósito:** Esta política establece los requisitos para la identificación, clasificación, propiedad, uso y disposición segura de todos los activos de información y activos físicos asociados utilizados por [Nombre de la Empresa]. Su objetivo es proteger la confidencialidad, integridad y disponibilidad de la información de acuerdo con los requisitos de ISO/IEC 27001 y las regulaciones aplicables (como GDPR/LGPD/PCI DSS).

**Alcance:** Aplica a todos los empleados, contratistas, proveedores externos y partes interesadas que accedan, procesen o gestionen activos propiedad de la Compañía, incluyendo tanto activos físicos como digitales.

## 2. Clasificación y Nivel de Sensibilidad

Todos los activos deben ser clasificados según su sensibilidad y el impacto que su divulgación, modificación o indisponibilidad pueda tener en la Compañía y sus clientes.

|Clasificación|Descripción|Impacto|Ejemplos (Fintech)|
|---|---|---|---|
|**Público**|Información destinada al consumo masivo. No requiere protección especial.|Bajo|Contenido de marketing, comunicados de prensa.|
|**Interno**|Información de uso interno de la empresa, no sensible, pero no para el público.|Medio|Organigramas, políticas operacionales (no de seguridad).|
|**Confidencial (PII)**|Información personal identificable (PII) o datos comerciales estratégicos que no deben ser divulgados.|Alto|Salarios, planes de producto, detalles de contratos.|
|**Restringido (KYC/Secretos)**|Información de alto valor y cumplimiento legal: datos de Conozca a su Cliente (KYC), información no pública de cuentas financieras, y secretos técnicos.|Crítico|Credenciales de producción, claves de cifrado, datos de tarjeta de crédito (si aplica), archivos de KYC, Código Fuente propietario.|

## 3. Gestión del Inventario y Propiedad

### 3.1 Inventario de Activos (ISO A.5.9)

Es obligatorio mantener un inventario exhaustivo de todos los activos de información. El inventario debe incluir, como mínimo:

- Identificador único del activo.
    
- Ubicación o sistema donde reside.
    
- **Clasificación de Seguridad** (según la Sección 2).
    
- Fecha de alta y fecha esperada de retiro.
    

**Nota:** Los activos de código fuente deben ser identificados hasta el nivel del repositorio (p. ej., GitHub o GitLab) y clasificados según los datos que procesan o almacenan.

### 3.2 Asignación de Propiedad (ISO A.5.10)

Cada activo en el inventario debe tener un **Propietario** (dueño) claramente designado.

- El Propietario es un miembro de la Dirección o un Gerente.
    
- El Propietario es responsable de la protección y la gestión del ciclo de vida del activo.
    
- El Propietario debe asegurarse de que se implementen los controles de acceso y de clasificación necesarios.
    

## 4. Normas de Uso y Manejo

### 4.1 Uso Aceptable de Activos

- Los activos deben utilizarse únicamente para los propósitos del negocio.
    
- Está prohibido modificar, copiar, transferir o destruir activos Confidenciales o Restringidos sin la autorización explícita del Propietario del Activo.
    
- El uso de software no autorizado o la instalación de aplicaciones personales en equipos de la empresa está estrictamente prohibido.
    

### 4.2 Almacenamiento y Transferencia

- Los activos con clasificación **Confidencial** o **Restringido** deben ser almacenados en ubicaciones protegidas (cifradas en reposo y en tránsito) y accesibles solo mediante el principio de **Mínimo Privilegio**.
    
- La transferencia de datos restringidos a través de canales públicos (p. ej., correo electrónico externo) está prohibida a menos que se utilice cifrado de extremo a extremo aprobado.
    

### 4.3 PROHIBICIÓN DE CREDENCIALES FIJAS (HARDCODING) 

**Está terminantemente prohibido, bajo cualquier circunstancia, insertar (hardcoding) credenciales, claves de API, tokens de acceso o secretos en el código fuente de las aplicaciones, scripts o configuraciones.**

- Todas las credenciales deben ser gestionadas mediante un sistema de gestión de secretos centralizado y seguro (como HashiCorp Vault o Azure Key Vault, según el entorno de la Compañía).
    
- Las variables de entorno son aceptables para entornos de desarrollo/QA, pero no son una solución para credenciales de alta sensibilidad en producción.
    

### 4.4 Disposición y Retiro de Activos (ISO A.5.11)

Esta sección define el procedimiento para la eliminación o disposición de activos al final de su ciclo de vida útil.

- **Activos Físicos:** Antes de desechar o reasignar hardware (servidores, portátiles, discos duros, etc.), todos los datos almacenados deben ser borrados de forma segura, mediante la sanitización física (destrucción) o lógica (borrado de tres pasadas) que haga irrecuperable la información, especialmente aquella clasificada como **Restringido**.
    
- **Activos Digitales/Información:** La información que ya no es legalmente requerida o necesaria para el negocio debe ser eliminada de forma segura de todos los sistemas de almacenamiento (incluidas copias de seguridad).
    
- **Retiro de Accesos (ISO A.6.6):** Al finalizar la relación laboral o contractual, todos los derechos de acceso del usuario a los activos deben ser revocados inmediatamente, y cualquier activo físico de la Compañía debe ser devuelto al departamento correspondiente.


## 5. CUMPLIMIENTO Y REVISIÓN

El incumplimiento de esta política puede resultar en acciones disciplinarias y, en casos de exposición de datos **CONFIDENCIALES**, en responsabilidades legales y regulatorias.

Esta política será revisada y actualizada por el Propietario anualmente o después de cualquier cambio significativo en el entorno regulatorio (ej. nuevas leyes de PII).    


## 6. Glosario de Activos Clave

- **PII (Personally Identifiable Information):** Información que puede utilizarse para identificar, localizar o contactar a una persona (Nombre, Email, Dirección, Teléfono, Número de ID).
    
- **KYC (Know Your Customer):** Información legal y regulatoria recopilada para verificar la identidad de un cliente y cumplir con las leyes contra el lavado de dinero.
    
- **Credenciales Fijas (Hardcoded):** Inclusión de una contraseña o clave secreta directamente en el código fuente, lo que compromete la seguridad.
