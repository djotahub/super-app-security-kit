#  Guía Estratégica de Modelado de Amenazas (Threat Modeling)

**Referencia:** T-19 

**Versión:** 2.0 

**Metodología Base:** STRIDE (Microsoft/OWASP)

**Propósito:** Establecer el procedimiento formal para la identificación y mitigación temprana de riesgos de diseño lógico y arquitectura en la fase de diseño, garantizando la integración de la seguridad en el ciclo de vida de desarrollo (SDLC) antes de la implementación del código.

## 1. Alcance y Justificación Estratégica

El Modelado de Amenazas constituye un proceso sistemático de análisis de la lógica de negocio, diferenciándose de los escaneos de vulnerabilidades tradicionales.

### 1.1 Limitaciones del Análisis Automático

Las herramientas de análisis estático y dinámico (SAST/DAST) son eficaces para detectar errores de codificación (ej. Inyección SQL), pero carecen de contexto para identificar **fallos de lógica de negocio**.

- **Riesgo No Detectable:** Vulnerabilidades complejas, como condiciones de carrera en transacciones financieras o el abuso de flujos legítimos (ej. cancelación de cuentas durante una transferencia), son invisibles para los escáneres automáticos.
    
- **Objetivo del Estándar:** Proveer un marco analítico para prevenir fraudes complejos y errores de diseño arquitectónico.
    

## 2. Metodología STRIDE: Taxonomía de Amenazas Fintech

Se adopta el modelo **STRIDE** como estándar corporativo para la categorización de riesgos en todos los componentes de la arquitectura (APIs, Bases de Datos, Microservicios).

|Categoría (STRIDE)|Definición Técnica|Escenario de Riesgo Fintech|Control de Mitigación (Arquitectura)|
|---|---|---|---|
|**Spoofing** (Suplantación)|Usurpación de la identidad de una entidad (usuario o proceso).|Un atacante manipula un token o ID de recurso para ejecutar acciones en nombre de otro usuario (**BOLA/IDOR**).|Implementación de MFA, Firmas Digitales (PKI), Validación estricta de sesión y propiedad del recurso.|
|**Tampering** (Manipulación)|Modificación no autorizada de datos en reposo, memoria o tránsito.|Intercepción y modificación del parámetro `monto` o `cuenta_destino` en una petición de transferencia.|Cifrado en tránsito (TLS 1.3), Firmas de integridad (HMAC) en payloads críticos, Validación de checksums.|
|**Repudiation** (Repudio)|Capacidad de un actor para negar la realización de una acción.|Un usuario niega haber autorizado una transacción financiera legítima para solicitar un reembolso fraudulento.|**Logs de Auditoría Inmutables**, Firmas digitales con no-repudio, Trazabilidad transaccional completa.|
|**Information Disclosure** (Divulgación)|Exposición de información a entidades no autorizadas.|Fuga de datos sensibles (PII, Credenciales) a través de mensajes de error (_stack traces_) o logs sin sanitizar.|Cifrado en reposo/tránsito, Enmascaramiento de datos, Control de Acceso (ACLs) estricto.|
|**Denial of Service** (Denegación)|Degradación o interrupción de la disponibilidad del servicio.|Agotamiento de recursos mediante ataques de fuerza bruta o envío de _payloads_ masivos (XML Bomb/XXE).|Rate Limiting, Cuotas de API por tenant, Validación de tamaño de input, Protección DDoS (WAF/CDN).|
|**Elevation of Privilege** (Elevación)|Obtención de capacidades superiores a las autorizadas.|Un usuario estándar explota una vulnerabilidad lógica para acceder a funciones administrativas.|Principio de Mínimo Privilegio, Validación de Roles (RBAC) en cada capa, Secure Boot.|

## 3. Procedimiento de Ejecución (Ciclo de Vida)

El proceso de Modelado de Amenazas es **mandatorio** durante la fase de Diseño para cualquier nueva funcionalidad crítica (ej. Pasarelas de Pago, Módulos de Crédito).

### Fase 1: Descomposición Arquitectónica (DFD)

Se requiere la creación de un Diagrama de Flujo de Datos (DFD) que identifique explícitamente:

- **Actores:** Usuarios, Administradores, Sistemas Externos (Bancos, Procesadores).
    
- **Procesos:** API Gateway, Funciones Serverless, Contenedores.
    
- **Almacenes de Datos:** Bases de Datos Relacionales, Object Storage (S3), Logs, Caché.
    
- **Límites de Confianza (Trust Boundaries):** Identificación crítica de los puntos donde los datos cruzan niveles de confianza (ej. de Internet Pública a VPC Privada). **Estos límites representan la superficie de ataque principal.**
    

### Fase 2: Análisis de Amenazas (Aplicación STRIDE)

Para cada elemento del DFD, se debe realizar un análisis sistemático aplicando las categorías STRIDE aplicables:

- _Validación de Identidad:_ ¿Es posible la suplantación (Spoofing) de este microservicio?
    
- _Integridad de Datos:_ ¿Existe riesgo de manipulación (Tampering) en el almacenamiento intermedio?
    
- _Trazabilidad:_ ¿Son suficientes los controles de auditoría para prevenir el repudio?
    

### Fase 3: Definición de Contramedidas

Por cada amenaza identificada, se debe documentar un requerimiento de seguridad específico y verificable.

- **Ejemplo:** Amenaza de manipulación de saldo en tránsito -> **Requerimiento:** Implementar mTLS entre microservicios y firma del payload.
    

### Fase 4: Validación y Verificación

Verificar que las contramedidas definidas se han implementado correctamente en el código y que los casos de prueba (QA/Pentest) cubren los escenarios de abuso identificados.

## 4. Caso de Estudio: Módulo de Transferencias P2P

**Escenario de Referencia:** Transacción monetaria entre usuarios (Origen a Destino).

### Matriz de Análisis STRIDE

|Elemento de Arquitectura|Amenaza Identificada (Tipo)|Clasificación de Riesgo|Mitigación Arquitectónica Requerida|
|---|---|---|---|
|**API Endpoint**|Agotamiento de recursos por peticiones masivas (DoS).|Alta|Implementar **Rate Limiting** granular por usuario/IP en el API Gateway.|
|**Payload JSON**|Intercepción y modificación de cuenta destino (Tampering).|Crítica|Forzar **TLS 1.3** (HSTS) y validar firma de integridad en el backend.|
|**Base de Datos**|Acceso no autorizado a saldos por administradores (Info Disclosure).|Alta|Implementar **Cifrado a Nivel de Columna** y segregación de funciones (SoD) para DBAs.|
|**Log de Auditoría**|Negación de transacción realizada (Repudiation).|Crítica|Registro de evento con timestamp, IP y ID de dispositivo en **Log Inmutable (WORM)**.|
|**Auth Service**|Uso de token robado para autorizar transacción (Spoofing).|Crítica|Requerir **MFA (Step-up Authentication)** para transacciones que superen un umbral definido.|

## 5. Herramientas y Entregables del Proceso

### Herramientas Homologadas

- **OWASP Threat Dragon:** Herramienta estándar para la creación de diagramas de amenazas.
    
- **Microsoft Threat Modeling Tool:** Recomendada para entornos con integración profunda en Azure/Windows.
    

### Definición del Entregable: "Documento de Modelo de Amenazas"

Cada nueva funcionalidad mayor debe incluir en su documentación técnica (ej. `docs/threat-model.md`) los siguientes elementos:

1. Diagrama de Flujo de Datos (DFD) actualizado.
    
2. Registro de Amenazas y Riesgos Residuales aceptados.
    
3. Lista de Requisitos de Seguridad vinculados a tickets de desarrollo (Jira/GitHub Issues).
    

## 6. Mantenimiento y Vigencia

El modelo de amenazas es un artefacto vivo que debe evolucionar con el sistema.

- **Trigger de Actualización:** Cambios en la arquitectura, integración de nuevas APIs externas o modificaciones en los flujos de datos sensibles.
    
- **Responsabilidad:** La propiedad del modelo recae en el Arquitecto de Software, con la validación del Security Champion.
    

> **Principio Rector:** La seguridad debe ser tratada como un requisito funcional no negociable, integrado desde la concepción del sistema.
