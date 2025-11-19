# Glosario de Cumplimiento y Ciberseguridad

**Referencia:** T-03 **Versión:** 1.0 

**Propósito:** Proveer definiciones concisas y desambiguadas de los términos de cumplimiento normativo y seguridad que impactan directamente el desarrollo, el manejo de datos y la infraestructura de nuestra Super App Fintech.

## 1. Regulación de Datos (GDPR, PII, etc.)

|Término|Definición Concreta|Impacto Clave en el Proyecto|
|---|---|---|
|**Dato Personal (PII)**|Cualquier información que directa o indirectamente haga identificable a un individuo (ej. email, DNI, IP, datos de geolocalización, datos de la cuenta financiera).|**CRÍTICO:** Debe ser cifrado, anonimizado o pseudonimizado. Su exposición genera multas (Referencia: Política de Gestión de Activos).|
|**Controlador de Datos**|La entidad (nuestra empresa) que **define el propósito y los medios** del procesamiento de los datos personales.|Asumimos la responsabilidad legal completa sobre la seguridad y el consentimiento del usuario.|
|**Procesador de Datos**|La entidad que procesa los datos en nombre del Controlador (ej. un servicio de análisis externo o un Cloud Provider).|Debe ser contratado solo si cumple con altos estándares de seguridad y tiene un contrato (DPA) firmado con nosotros.|
|**Derecho al Olvido**|El derecho de un usuario a exigir la eliminación de sus datos personales sin dilación.|**REQUISITO DE ARQUITECTURA:** La base de datos debe estar diseñada para la eliminación eficiente y total de registros de usuario.|

## 2. Estándares de Pago (PCI DSS)

|Término|Definición Concreta|Impacto Clave en el Proyecto|
|---|---|---|
|**Alcance PCI (CDE)**|El **Entorno de Datos del Titular de la Tarjeta (Cardholder Data Environment)**. Incluye cualquier sistema, red o componente que almacena, procesa o transmite datos de tarjetas de crédito.|**ALTO:** Cualquier sistema dentro de este alcance debe aplicar los controles de seguridad más estrictos (Hardening CIS, Monitoreo).|
|**Datos Sensibles de Autenticación**|Información de la banda magnética, códigos de seguridad (CVV/CVC) o PIN.|**PROHIBICIÓN ESTRICTA:** Estos datos NUNCA deben ser almacenados en ningún formato (ni cifrados) después de la autorización inicial.|
|**Tokenización**|Sustituir los datos sensibles de la tarjeta por un valor no sensible (un "token") que no puede ser revertido a la tarjeta original.|**PRÁCTICA RECOMENDADA:** Usar un proveedor externo (ej. Stripe) y solo trabajar con el token dentro de nuestra infraestructura.|

## 3. Seguridad Aplicada y Gobernanza (ISO, NIST, OWASP)

|Término|Definición Concreta|Impacto Clave en el Proyecto|
|---|---|---|
|**Hardening**|El proceso de asegurar un sistema (servidor, base de datos) mediante la **deshabilitación de servicios innecesarios**, configuración segura por defecto y aplicación de parches.|Aplica a todas las máquinas de producción (Referencia: `checklists/linux-hardening.md`).|
|**MFA (Autenticación Multifactor)**|Uso de dos o más factores de verificación (algo que sabes + algo que tienes), como contraseña y código de la app.|**REQUISITO DE POLÍTICA:** Obligatorio para accesos administrativos (Referencia: `policies/password-policy.md`).|
|**Need-to-Know**|Principio de "Necesidad de Conocer". El acceso a la información se concede solo a aquellos individuos que lo necesitan estrictamente para su trabajo (Mínimo Privilegio).|Se aplica mediante la Política de Gestión de Activos y la gestión de roles (RBAC).|
|**SAST**|**Static Application Security Testing.** Análisis del código fuente SIN ejecutarlo, para encontrar vulnerabilidades (ej. hardcoding, SQLi).|Se integra en el pipeline de CI/CD (Referencia: Scripts SAST).|
|**DAST**|**Dynamic Application Security Testing.** Análisis de la aplicación web en ejecución (ej. OWASP ZAP) para encontrar fallas como SQLi, XSS.|Se ejecuta en un ambiente de staging o QA (Referencia: Scripts DAST).|
|**BOLA**|**Broken Object Level Authorization (API1 de OWASP).** El fallo de seguridad más común donde el usuario A accede a datos o recursos del usuario B solo cambiando el ID.|Mitigación es la máxima prioridad en el Checklist de Auditoría de APIs.|
|**Vulnerabilidad**|Una debilidad en un sistema, diseño o implementación que puede ser explotada por una amenaza para comprometer la seguridad.|Es lo que las herramientas de escaneo buscan activamente.|
|**Amenaza**|La causa potencial de un incidente no deseado que podría resultar en daño a un sistema u organización (ej. un atacante, un incendio, un error humano).|Sirve para el análisis de riesgo (Threat Modeling).|
|**Zero Trust**|Modelo de seguridad que exige la **verificación estricta de cada usuario y dispositivo** que intenta acceder a recursos en la red, independientemente de si están dentro o fuera del perímetro.|**REQUISITO ARQUITECTÓNICO:** Guía el diseño de red y la segmentación de la Super App.|

## 4. Uso y Mantenimiento

Este glosario funciona como un **diccionario de arquitectura de seguridad**. Su conocimiento es la base para entender el riesgo y aplicar correctamente todos los controles de nuestro "Super App Security Kit".

- **Propósito Táctico:** Este documento asegura que todos los equipos (Desarrollo, DevOps, Producto y Legal) utilicen un lenguaje común al discutir la **Clasificación de Datos (PII)** y el **Alcance PCI (CDE)**.
    
- **Responsabilidad:** Las referencias entre términos (ej. "Hardening" y "`checklists/linux-hardening.md`") garantizan que la teoría se traduzca en acción.
    
- **Mantenimiento:** Este glosario debe ser revisado anualmente o cuando se adopten nuevos estándares regulatorios (ej. nuevas leyes de datos) o se introduzcan nuevas herramientas de seguridad (ej. un nuevo escáner SAST).
