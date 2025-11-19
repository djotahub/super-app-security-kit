 POLÍTICA DE GESTIÓN DE ACTIVOS

**Identificador:** P-AM-001 **Versión:** 1.0 **Fecha de Publicación:** 19/11/2025 **Propietario:** CTO / Equipo de Ciberseguridad

## 1. OBJETIVO Y ALCANCE

El objetivo de esta política es establecer un marco de referencia para la identificación, clasificación y protección de los activos de información manejados por la compañía, asegurando su confidencialidad, integridad y disponibilidad (CID), conforme a los requisitos del Anexo A de **ISO/IEC 27001:2022**.

**Alcance:** Esta política aplica a todo el personal, contratistas, y a todos los activos de información y sistemas de procesamiento utilizados o generados dentro del ecosistema de la Super App Fintech, incluyendo entornos de desarrollo, QA, staging y producción.

## 2. REQUISITOS CLAVE (ISO 27001)

### 2.1. Inventario de Activos (A.5.9)

Todo activo de información relevante debe ser documentado y mantenido en un **Inventario de Activos**. El inventario debe incluir, como mínimo, la siguiente información:

1. Nombre del activo (ej. "Base de Datos de Producción", "Repositorio de API Transferencias").
2. Clasificación de la Información (ver Sección 3).
3. Propietario del Activo (Rol o persona responsable).
4. Ubicación (Cloud Provider, Servicio).

### 2.2. Propiedad de los Activos (A.5.10)

Cada activo de información debe tener un **Propietario (Owner)** asignado. El Propietario del Activo es responsable de:

- Asignar la clasificación de la información.
- Asegurar que los controles de seguridad y los requisitos de manejo sean aplicados.
- Revisar la clasificación y los requisitos de acceso al menos anualmente.

## 3. CLASIFICACIÓN DE LA INFORMACIÓN Y MANEJO

La información será clasificada en tres niveles, basándose en el impacto potencial de su divulgación, modificación o destrucción no autorizada en el negocio y la regulación (GDPR, PCI DSS).

|Nivel|Activos Fintech de Ejemplo|Impacto / Requisitos de Control|
|---|---|---|
|**3. CONFIDENCIAL / RESTRINGIDO**|**PII/KYC** (DNI, Nombres completos), **Credenciales** (API Keys, Secretos DB Prod), Código Fuente de Lógica de Negocio.|**ALTO.** Divulgación resulta en multas regulatorias y daño severo a la reputación.<br><br>**Manejo:** Cifrado Obligatorio (en reposo y tránsito). Acceso basado en la necesidad de saber ("Need-to-Know"). Logging y auditoría de acceso obligatorios.|
|**2. INTERNO**|Logs de producción sin PII, Diagramas de Arquitectura interna, Código fuente (no crítico) del Frontend, Minutas de reuniones internas.|**MEDIO.** Divulgación podría causar vergüenza o ventaja competitiva.<br><br>**Manejo:** Restringido a empleados. Autenticación fuerte (MFA obligatorio) para acceso. Prohibido el almacenamiento en dispositivos personales.|
|**1. PÚBLICO**|Marketing, Descripciones del producto, Documentos de licencias (MIT, Apache), Readme de repositorios públicos.|**BAJO.** Diseñado para ser visible externamente.<br><br>**Manejo:** Sin restricciones de acceso o cifrado, pero el proceso de publicación debe ser autorizado.|

## 4. REQUISITOS DE MANEJO DE ACTIVOS POR CLASIFICACIÓN

### 4.1. Manejo de Credenciales y Secretos (CONFIDENCIAL)

1. **Prohibición de Hardcoding:** Queda estrictamente prohibido incluir claves de API, contraseñas de bases de datos o tokens de servicio directamente en el código fuente.
2. **Almacenamiento:** Los secretos deben almacenarse en servicios de gestión de secretos dedicados (ej. AWS Secrets Manager, GCP Secret Manager o HashiCorp Vault), y solo inyectarse en el entorno de ejecución.
3. **Ambientes:** Los secretos de **Producción** deben ser distintos y no deben ser accesibles desde los entornos de Desarrollo/QA.

### 4.2. Uso Aceptable (A.5.10)

1. El acceso a la información **CONFIDENCIAL** debe ser revisado trimestralmente por el Propietario del Activo.
2. El uso de activos para fines personales está estrictamente prohibido.

### 4.3. Devolución y Retención (A.6.6)

1. **Terminación de Empleo:** Al término del empleo (incluyendo contratistas), todo acceso a activos **INTERNOS** y **CONFIDENCIALES** debe ser **revocado inmediatamente** por el equipo de IT/Ciberseguridad.
2. El proceso de _offboarding_ debe ser formal y documentado.


## 5. CUMPLIMIENTO Y REVISIÓN

El incumplimiento de esta política puede resultar en acciones disciplinarias y, en casos de exposición de datos **CONFIDENCIALES**, en responsabilidades legales y regulatorias.

Esta política será revisada y actualizada por el Propietario anualmente o después de cualquier cambio significativo en el entorno regulatorio (ej. nuevas leyes de PII).
