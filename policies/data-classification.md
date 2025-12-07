# Política de Clasificación de Datos

**Referencia:** S1-T06 (Entregable de Gobernanza) 

**Versión:** 2.0 

**Propósito:** Establecer un marco formal para la categorización de activos de información según su sensibilidad e impacto en el negocio. Esta política define los controles de seguridad mandatorios (Salvaguardias) para cada nivel de clasificación, garantizando el cumplimiento de GDPR, PCI DSS y las normativas locales de privacidad.

## 1. Objetivo y Alcance

**Objetivo:** Proveer una metodología estandarizada para identificar, clasificar y proteger los datos a lo largo de su ciclo de vida. Esta política es vinculante para determinar los requisitos de cifrado, control de acceso y retención.

**Alcance:** Esta política aplica a la totalidad de los datos procesados, almacenados o transmitidos por la organización, independientemente de su formato o ubicación:

- **Datos en Reposo:** Bases de datos, sistemas de archivos, _backups_, _object storage_ (S3/Blob).
    
- **Datos en Tránsito:** Comunicaciones API, mensajería interna, transferencias de archivos.
    
- **Datos en Uso:** Memoria volátil, logs de aplicación, entornos de desarrollo y _staging_.
    

## 2. Niveles de Clasificación y Controles Mandatorios

Los datos deben ser clasificados en una de las siguientes tres categorías. En caso de ambigüedad, se debe aplicar el principio de precaución y clasificar en el nivel más alto aplicable.

### 2.1. Nivel: CRÍTICO (Alto Impacto)

**Definición:** Información cuya exposición, modificación no autorizada o pérdida causaría un impacto severo a la organización, incluyendo pérdidas financieras significativas (>$100,000 USD), sanciones regulatorias graves o riesgo para la seguridad física de las personas.

**Tipos de Datos:**

- **PII Sensible:** Identificadores nacionales (SSN, RFC, CURP), datos biométricos.
    
- **Datos Financieros (PCI DSS):** Número de Cuenta Primario (PAN), datos de banda magnética (prohibido su almacenamiento), historial transaccional detallado.
    
- **Credenciales:** Claves privadas, API Keys de producción, contraseñas (hash), tokens de sesión.
    
- **Datos de Salud (PHI):** Historiales médicos, diagnósticos.
    
- **Propiedad Intelectual:** Algoritmos propietarios, secretos comerciales.
    

**Salvaguardias Técnicas Requeridas:**

|Dominio de Control|Requisito Técnico|
|---|---|
|**Cifrado**|**Reposo:** AES-256 obligatorio. Gestión de claves mediante KMS/HSM con rotación automática (90 días).<br><br>**Tránsito:** TLS 1.3 mínimo. Se prohíbe el uso de cifrados débiles.|
|**Control de Acceso**|**Autenticación:** MFA obligatorio y resistente a phishing.<br><br>**Autorización:** RBAC estricto bajo el principio de Mínimo Privilegio. Acceso justificado y temporal (JIT).|
|**Monitoreo (DLP)**|Implementación obligatoria de herramientas de Prevención de Pérdida de Datos (ej. AWS Macie, GCP DLP). Alertas en tiempo real ante accesos anómalos.|
|**Almacenamiento**|Alojamiento exclusivo en infraestructura aprobada y certificada. Backups cifrados y replicados en región geográfica distinta (DR).|
|**Entornos No-Prod**|**Prohibición Absoluta:** No se permite el uso de datos reales en Desarrollo/QA. Se debe utilizar datos sintéticos o anonimizados irreversiblemente.|
|**Destrucción**|Sobrescritura criptográfica o destrucción física certificada (NIST 800-88). Certificado de eliminación requerido.|

### 2.2. Nivel: MODERADO (Impacto Medio)

**Definición:** Información cuya exposición podría causar un daño reputacional moderado, pérdidas financieras limitadas o sanciones administrativas menores. Datos de uso interno que no son públicos.

**Tipos de Datos:**

- **PII Básica:** Nombres, correos electrónicos corporativos, números de teléfono.
    
- **Datos Operacionales:** Logs de aplicación (sin secretos), métricas de negocio internas.
    
- **Datos de Empleados:** Estructura organizacional, evaluaciones de desempeño.
    
- **Comunicaciones Internas:** Correos electrónicos no confidenciales, documentación de proyectos.
    

**Salvaguardias Técnicas Requeridas:**

|Dominio de Control|Requisito Técnico|
|---|---|
|**Cifrado**|**Reposo:** AES-128 mínimo (recomendado AES-256).<br><br>**Tránsito:** TLS 1.2 o superior.|
|**Control de Acceso**|**Autenticación:** Integración con SSO corporativo.<br><br>**Autorización:** RBAC basado en roles de negocio. Auditoría de permisos semestral.|
|**Monitoreo**|Escaneo periódico de DLP. Revisión mensual de logs de acceso.|
|**Entornos No-Prod**|**Pseudonimización Obligatoria:** Los datos deben ser enmascarados o tokenizados para impedir la re-identificación directa en entornos de prueba.|
|**Destrucción**|Eliminación lógica segura. Plazo máximo de 90 días tras el fin del periodo de retención.|

### 2.3. Nivel: PÚBLICO (Bajo Impacto)

**Definición:** Información diseñada para su divulgación pública o cuya exposición no conlleva riesgo significativo para la organización.

**Tipos de Datos:**

- Material de marketing y comunicados de prensa.
    
- Documentación técnica de APIs públicas.
    
- Datos estadísticos agregados y completamente anonimizados.
    

**Salvaguardias Técnicas Requeridas:**

- **Integridad:** Controles de acceso para prevenir la modificación no autorizada (defacement).
    
- **Transmisión:** HTTPS recomendado para garantizar la autenticidad del origen.
    

## 3. Estrategia de Protección de Datos en Desarrollo (Pseudonimización)

Para cumplir con el principio de "Privacidad por Diseño", los entornos de desarrollo y pruebas no deben contener datos reales. Se aplicarán las siguientes técnicas:

### 3.1. Técnicas de Transformación Aprobadas

1. **Sustitución Sintética:** Reemplazo de identificadores reales por valores ficticios generados (ej. librería `Faker`). Mantiene la integridad referencial y el formato.
    
2. **Enmascaramiento Estático:** Ofuscación de caracteres sensibles (ej. mostrar solo los últimos 4 dígitos de una tarjeta: `****-****-****-1234`).
    
3. **Tokenización:** Sustitución de datos sensibles por tokens aleatorios generados por una bóveda segura (Vault). Permite análisis sin exponer el dato real.
    
4. **Generalización:** Reducción de la precisión del dato (ej. convertir fecha de nacimiento completa a solo "Año de Nacimiento").
    

### 3.2. Validación de Anonimización

Antes de migrar cualquier conjunto de datos a un entorno inferior, el _Data Owner_ debe certificar que el proceso de pseudonimización es irreversible sin el uso de tablas de mapeo seguras, y que no existe riesgo de re-identificación.

## 4. Arquitectura de Detección Automática (DLP)

La clasificación manual debe ser complementada por mecanismos de inspección automatizada.

### 4.1. Herramientas de Infraestructura

- **AWS Macie / GCP DLP / Azure Purview:** Configuración de _jobs_ de descubrimiento continuo en repositorios de almacenamiento (S3, Buckets).
    
- **Reglas de Detección:** Configurar patrones para identificar PAN (Tarjetas de Crédito), Credenciales (AWS Keys, Private Keys) y PII Nacional.
    

### 4.2. Respuesta ante Hallazgos

- **Nivel Crítico:** Detección de PAN o Credenciales en logs/texto plano. Requiere escalamiento inmediato al equipo de Seguridad y ejecución del _Playbook_ de Respuesta a Incidentes.
    
- **Nivel Alto:** PII en ubicaciones no cifradas. Requiere remediación en < 24 horas.
    

## 5. Gobernanza y Responsabilidades

### 5.1. Data Owner (Propietario del Dato)

- Asignar la clasificación inicial de los datos bajo su custodia.
    
- Autorizar solicitudes de acceso a datos de nivel CRÍTICO.
    
- Revisar la clasificación y los privilegios de acceso anualmente.
    

### 5.2. Equipo de Ingeniería y DevOps

- Implementar los controles técnicos (Cifrado, TLS, RBAC) definidos en esta política.
    
- Asegurar la ejecución de scripts de sanitización/pseudonimización en los _pipelines_ de CI/CD para entornos no productivos.
    

### 5.3. Equipo de Seguridad

- Administrar las políticas de DLP y monitorear las alertas de violación de política.
    
- Realizar auditorías de cumplimiento y pruebas de acceso.
    

## 6. Procedimiento de Manejo de Excepciones

Cualquier desviación de esta política requiere una **Excepción de Seguridad** formalmente documentada.

1. **Solicitud:** Debe detallar la justificación de negocio, el riesgo técnico y los controles compensatorios propuestos.
    
2. **Aprobación:** Requiere autorización explícita del CISO y del Data Owner.
    
3. **Vigencia:** Las excepciones son temporales y deben ser revisadas trimestralmente.
    

## 7. Marco Normativo y Referencias

- **GDPR:** Artículos 5 (Principios), 25 (Privacidad por diseño), 32 (Seguridad del tratamiento).
    
- **PCI DSS:** Requisito 3 (Protección de datos de titulares de tarjetas).
    
- **NIST SP 800-122:** Guide to Protecting the Confidentiality of PII.
    
- **ISO/IEC 27001:** Controles A.8.2 (Clasificación de información) y A.8.10 (Eliminación de información).
