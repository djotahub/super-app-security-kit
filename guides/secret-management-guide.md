# Guía de Gestión de Secretos y Credenciales (Secrets Management)

**Referencia:** S1-T07 **Versión:** 1.0

**Propósito:** Establecer protocolos para el manejo de credenciales sensibles (API Keys, Contraseñas de Base de Datos) para prevenir el **hardcoding** y las fugas al repositorio de código (GitHub). Esta guía implementa el requisito de **Clasificación Restringida** de la Política de Gestión de Activos.

## 1. Principio Rector: Prohibición de Hardcoding de Credenciales

El **Hardcoding** (la inclusión directa de secretos en el código fuente) representa el principal **vector de fuga** de credenciales y constituye una violación directa al control **A.5.10 (Uso Aceptable)** de la norma ISO/IEC 27001.

### 1.1. Regla de Cumplimiento (Conexión con el Control SAST)

**ESTRICTAMENTE PROHIBIDO** commitear credenciales, tokens o claves de API en cualquier formato (incluyendo texto plano o cifrado dentro del repositorio) a cualquier rama del sistema de control de versiones.

- El escáner **SAST** (T-12) está configurado para **bloquear el Pull Request** si detecta patrones de secretos en el código.


### 1.2. Protocolo de Exclusión Local del Repositorio

Utilice el archivo **`.gitignore`** para listar explícitamente todos los archivos que contienen secretos locales. La omisión de este paso es una vulnerabilidad crítica de AppSec.

- `settings.py` (si contiene credenciales)
- `config.js`
- `.env`
- `*.key` (claves privadas)


## 2. Estrategia de Inyección de Credenciales (Principios del Twelve-Factor App)

La solución es inyectar secretos en el ambiente de ejecución **en tiempo de ejecución**. Esto garantiza la separación estricta entre el código y los datos de configuración.

### 2.1. Entornos Locales (Desarrollo/QA)

- **Mecanismo:** Utilizar archivos `.env` (variables de entorno locales).

- **Acción:** El archivo `.env` debe ser creado manualmente en cada máquina y **siempre** debe estar incluido en el `.gitignore`.

### 2.2. Entornos de Integración Continua (CI/CD)

- **Mecanismo:** Utilizar la bóveda de secretos del proveedor de CI/CD (ej. GitHub Secrets, GitLab CI Variables).

- **Acción:** Los secretos se pasan al _runtime_ del _pipeline_ mediante variables de entorno en el script de despliegue. Su acceso debe ser limitado estrictamente al _job_ que lo necesita.

### 2.3. Entornos de Producción (Runtime)

- **Mecanismo:** Utilizar un **Gestor de Secretos Dedicado (Vault)**.

- **Herramientas Recomendadas:** AWS Secrets Manager, HashiCorp Vault, Azure Key Vault o GCP Secret Manager.

- **Acción:** La aplicación debe acceder al secreto a través de una API o SDK en lugar de leerlo directamente de una variable de entorno. Esto permite la auditoría, rotación automática y la trazabilidad de acceso.


## 3. Ciclo de Vida y Mantenimiento del Secreto (Creación, Rotación, Revocación)

La gestión de secretos es un ciclo de vida proactivo, no solo un lugar de almacenamiento.

### 3.1. Creación y Almacenamiento

- Los secretos deben generarse con **alta entropía** (longitud recomendada > 32 caracteres) y no deben ser reutilizados.

- El acceso a la bóveda debe requerir **Autenticación Multifactor (MFA)** para todos los usuarios, según lo exige la Política de Contraseñas (T-05).


### 3.2. Rotación (Mantenimiento Proactivo)

- **Requisito:** Los secretos sensibles (ej. contraseñas de DB de producción) deben rotarse **automáticamente** al menos cada 90 días, o forzadamente después de cualquier incidente.

- **Mecanismo:** Esta función debe ser delegada al Gestor de Secretos (ej. Lambda en AWS, o agente de Vault) para evitar errores manuales.


### 3.3. Revocación (Respuesta a Incidentes)

- **Acción:** Si se sospecha que un secreto ha sido comprometido (ej. un Push a GitHub) o durante el _offboarding_ de un empleado (Ver T-02, 4.3), el secreto debe ser **revocado inmediatamente** de la bóveda.

- **Protocolo:** Este proceso debe ser un paso explícito en los _Playbooks_ de Respuesta a Incidentes (T-14).


## 4. Conexión con Otras Políticas (Riesgos a Mitigar)

|Riesgo|Vinculación con Otras Tareas del Kit|Mitigación|
|---|---|---|
|**Fuga en Logs**|**Política de Activos (T-02):** Prohibición de _logging_ de variables de entorno y datos sensibles.|Asegurar que la aplicación solo imprima referencias, no valores de secretos.|
|**Escala de Privilegios**|**Hardening de Bases de Datos (T-16):** La DB debe tener usuarios de servicio con permisos mínimos (**Need-to-Know**) que solo la aplicación puede usar.|El secreto debe ser una credencial con el menor número de permisos posible.|
|**Falsa Detección**|**SAST Ruleset (T-12):** Las reglas de SAST deben buscar _patrones_ de claves, no solo variables de entorno, para cazar errores de desarrollador.|El uso de esta guía reduce el ruido de los falsos positivos del SAST.|
