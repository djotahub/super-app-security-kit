# Política de Clasificación de Datos

## 📋 Objetivo
Establecer un marco formal para clasificar datos según su sensibilidad e impacto potencial, y definir las salvaguardias mínimas requeridas para cada categoría. Esta política aplica a todos los datos procesados, almacenados o transmitidos por la organización.

---

## 🎯 Alcance
- **Datos en reposo**: Bases de datos, archivos, backups
- **Datos en tránsito**: APIs, mensajería, transferencias de archivos
- **Datos en uso**: Memoria, logs, entornos de desarrollo/staging

---

## 📊 Categorías de Clasificación

### 🔴 **CRÍTICO (High Impact)**

#### Definición
Datos cuya exposición, modificación o pérdida podría causar:
- Daño severo a la reputación de la organización
- Pérdidas financieras significativas (>$100,000 USD)
- Violaciones regulatorias con sanciones graves
- Riesgo para la seguridad física de personas

#### Ejemplos de Datos
- **PII sensible**: Números de identificación nacional (SSN, RFC, CURP), datos biométricos
- **Datos financieros**: Números de tarjetas de crédito (PAN), cuentas bancarias, información de transacciones
- **Credenciales**: Contraseñas, claves API de producción, certificados privados
- **Datos de salud**: Historiales médicos, diagnósticos (HIPAA/PHI)
- **Secretos empresariales**: Algoritmos propietarios, estrategias de negocio confidenciales
- **Datos legales**: Información de litigios, contratos confidenciales

#### Salvaguardias Mínimas Requeridas

##### 🔐 Cifrado
- **En reposo**: AES-256 obligatorio
- **En tránsito**: TLS 1.3 mínimo (no TLS 1.2 o inferior)
- **Gestión de claves**: AWS KMS, GCP Cloud KMS, Azure Key Vault (rotación automática cada 90 días)

##### 🛡️ Control de Acceso
- **Autenticación**: MFA obligatorio para todos los usuarios
- **Autorización**: RBAC con principio de mínimo privilegio
- **Auditoría**: Logging de TODOS los accesos (quién, qué, cuándo)
- **Revisión**: Auditoría trimestral de permisos

##### 🔍 Monitoreo y Detección
- **DLP obligatorio**: AWS Macie, GCP DLP API, o Microsoft Purview
- **Alertas en tiempo real**: Notificación inmediata de accesos anómalos
- **SIEM**: Integración con sistema de correlación de eventos

##### 🗄️ Almacenamiento
- **Ubicación**: Solo en infraestructura aprobada (no laptops, USB, servicios cloud no autorizados)
- **Backups**: Cifrados, almacenados en región geográfica diferente
- **Retención**: Según requisitos legales (mínimo 7 años para datos financieros)

##### 🧪 Entornos No Productivos
- **Prohibición**: NO usar datos reales en desarrollo/staging
- **Alternativa**: Usar datos sintéticos o pseudonimizados (ver sección de Pseudonimización)
- **Excepción**: Solo con aprobación escrita de CISO y controles adicionales

##### 🗑️ Destrucción Segura
- **Método**: Sobrescritura criptográfica (DoD 5220.22-M) o destrucción física
- **Certificación**: Documentar destrucción con certificado de eliminación
- **Plazo**: Dentro de 30 días después de fin de retención legal

---

### 🟡 **MODERADO (Medium Impact)**

#### Definición
Datos cuya exposición podría causar:
- Daño moderado a la reputación
- Pérdidas financieras limitadas ($10,000 - $100,000 USD)
- Violaciones regulatorias con multas menores
- Inconvenientes significativos para clientes

#### Ejemplos de Datos
- **PII básica**: Nombres completos + email, números de teléfono, direcciones postales
- **Datos de clientes**: Historial de compras, preferencias, datos de contacto
- **Datos operacionales**: Logs de aplicación con información de usuarios, métricas de negocio
- **Datos de empleados**: Información de contacto, evaluaciones de desempeño
- **Comunicaciones internas**: Emails corporativos, documentos de proyectos

#### Salvaguardias Mínimas Requeridas

##### 🔐 Cifrado
- **En reposo**: AES-128 mínimo (recomendado AES-256)
- **En tránsito**: TLS 1.2 o superior
- **Gestión de claves**: Servicio de gestión de secretos (no hardcodear)

##### 🛡️ Control de Acceso
- **Autenticación**: SSO corporativo obligatorio
- **Autorización**: RBAC basado en roles de negocio
- **Auditoría**: Logging de accesos (revisión mensual)
- **Revisión**: Auditoría semestral de permisos

##### 🔍 Monitoreo y Detección
- **DLP recomendado**: Escaneo periódico (semanal/mensual)
- **Alertas**: Notificación de accesos masivos o exportaciones grandes
- **Análisis**: Revisión de logs ante incidentes

##### 🗄️ Almacenamiento
- **Ubicación**: Infraestructura corporativa o cloud aprobado
- **Backups**: Cifrados, retención según política de backup estándar
- **Retención**: Según requisitos de negocio (típicamente 3-5 años)

##### 🧪 Entornos No Productivos
- **Pseudonimización obligatoria**: Aplicar técnicas de anonimización (ver sección)
- **Enmascaramiento**: Ocultar últimos dígitos de identificadores
- **Validación**: Verificar que no se puedan re-identificar individuos

##### 🗑️ Destrucción Segura
- **Método**: Eliminación segura (borrado de archivos + vaciado de papelera)
- **Plazo**: Dentro de 90 días después de fin de retención

---

### 🟢 **PÚBLICO (Low Impact)**

#### Definición
Datos cuya exposición NO causaría daño significativo a la organización o individuos.

#### Ejemplos de Datos
- **Información pública**: Contenido de sitio web, comunicados de prensa, material de marketing
- **Datos agregados**: Estadísticas anónimas, reportes públicos
- **Documentación técnica**: Manuales de usuario, FAQs, documentación de APIs públicas
- **Datos anonimizados**: Datasets completamente anonimizados (sin posibilidad de re-identificación)

#### Salvaguardias Mínimas Requeridas

##### 🔐 Cifrado
- **En tránsito**: HTTPS recomendado (no obligatorio para contenido estático)
- **En reposo**: No requerido (opcional según infraestructura)

##### 🛡️ Control de Acceso
- **Autenticación**: No requerida para lectura
- **Autorización**: Control de escritura/modificación según roles

##### 🗄️ Almacenamiento
- **Ubicación**: Sin restricciones (puede estar en CDN público)
- **Backups**: Según política estándar de disponibilidad

##### 🗑️ Destrucción
- **Método**: Eliminación estándar (sin requisitos especiales)

---

## 🎭 Técnicas de Pseudonimización para Entornos No Productivos

### ¿Qué es la Pseudonimización?
Proceso de reemplazar información identificable con pseudónimos, manteniendo la utilidad de los datos para desarrollo/testing sin exponer identidades reales.

### Técnicas Recomendadas

#### 1. **Sustitución de Identificadores**
```python
# Ejemplo: Reemplazar emails reales con emails de prueba
original: "juan.perez@gmail.com"
pseudonimizado: "user_12345@test.example.com"
```

**Herramientas**:
- Python: `Faker` library
- PostgreSQL: `pgcrypto` extension
- MySQL: `AES_ENCRYPT()` con salt consistente

#### 2. **Enmascaramiento de Datos**
```python
# Ejemplo: Ocultar dígitos de tarjetas/teléfonos
original: "4532-1234-5678-9010"
enmascarado: "****-****-****-9010"

original: "+52-555-123-4567"
enmascarado: "+52-555-***-**67"
```

**Herramientas**:
- AWS Glue DataBrew (transformaciones visuales)
- GCP DLP API (método `deidentify`)
- Microsoft Presidio (open-source)

#### 3. **Generalización**
```python
# Ejemplo: Reducir precisión de datos
original: "Fecha de nacimiento: 1985-03-15"
generalizado: "Año de nacimiento: 1985"

original: "Código postal: 03100"
generalizado: "Código postal: 03***"
```

#### 4. **Tokenización**
```python
# Ejemplo: Reemplazar con tokens únicos pero consistentes
original: "Juan Pérez"
token: "TOKEN_A7F3D9E2"

# El mismo nombre siempre genera el mismo token (útil para joins)
```

**Herramientas**:
- HashiCorp Vault (Transform Secrets Engine)
- AWS DynamoDB Encryption Client
- Protegrity (enterprise)

#### 5. **Datos Sintéticos**
Generar datasets completamente artificiales que mantienen distribuciones estadísticas.

**Herramientas**:
- `Faker` (Python): Genera nombres, direcciones, emails falsos
- `Mockaroo`: Servicio web para generar datos de prueba
- `Synthetic Data Vault (SDV)`: Genera datos sintéticos basados en datos reales

### Ejemplo de Script de Pseudonimización

```python
from faker import Faker
import hashlib

fake = Faker('es_MX')  # Locale español México

def pseudonimizar_usuario(usuario_real):
    """
    Pseudonimiza datos de usuario manteniendo consistencia
    """
    # Usar hash del email original como seed para consistencia
    seed = int(hashlib.md5(usuario_real['email'].encode()).hexdigest(), 16) % (10 ** 8)
    Faker.seed(seed)

    return {
        'id': usuario_real['id'],  # Mantener ID para relaciones
        'nombre': fake.name(),
        'email': f"user_{usuario_real['id']}@test.example.com",
        'telefono': fake.phone_number(),
        'direccion': fake.address(),
        'fecha_nacimiento': fake.date_of_birth(minimum_age=18, maximum_age=80),
        # Mantener campos no sensibles
        'fecha_registro': usuario_real['fecha_registro'],
        'plan': usuario_real['plan']
    }

# Uso
usuario_original = {
    'id': 12345,
    'nombre': 'Juan Pérez García',
    'email': 'juan.perez@gmail.com',
    'telefono': '+52-555-123-4567',
    'direccion': 'Av. Reforma 123, CDMX',
    'fecha_nacimiento': '1985-03-15',
    'fecha_registro': '2023-01-10',
    'plan': 'premium'
}

usuario_pseudonimizado = pseudonimizar_usuario(usuario_original)
print(usuario_pseudonimizado)
```

### Validación de Pseudonimización

Antes de usar datos pseudonimizados en staging/dev, verificar:

- [ ] **No re-identificación**: No es posible vincular datos pseudonimizados con personas reales
- [ ] **Consistencia**: Los mismos datos originales generan los mismos pseudónimos (para joins)
- [ ] **Utilidad**: Los datos mantienen formato y distribución útil para testing
- [ ] **Cobertura**: TODOS los campos sensibles fueron transformados
- [ ] **Documentación**: Existe registro de qué técnica se aplicó a cada campo

---

## 🤖 Herramientas de Detección Automática (DLP)

### AWS Macie
**Uso obligatorio para datos CRÍTICOS en AWS**

#### Configuración Mínima
```bash
# Habilitar Macie en la cuenta
aws macie2 enable-macie

# Crear job de descubrimiento para S3
aws macie2 create-classification-job \
  --job-type SCHEDULED \
  --s3-job-definition '{
    "bucketDefinitions": [{
      "accountId": "123456789012",
      "buckets": ["my-sensitive-bucket"]
    }]
  }' \
  --schedule-frequency '{
    "dailySchedule": {}
  }' \
  --name "daily-pii-scan"
```

#### Tipos de Datos Detectados
- Números de tarjetas de crédito (PCI DSS)
- SSN, pasaportes, licencias de conducir
- Claves API, tokens de acceso
- Datos personales (nombres, emails, direcciones)

#### Alertas Recomendadas
- **CRITICAL**: Detección de PAN (Primary Account Number) en logs
- **HIGH**: Credenciales expuestas en S3 público
- **MEDIUM**: PII en buckets sin cifrado

---

### GCP DLP API
**Uso obligatorio para datos CRÍTICOS en Google Cloud**

#### Configuración Mínima
```python
from google.cloud import dlp_v2

def inspect_gcs_bucket(project_id, bucket_name):
    dlp = dlp_v2.DlpServiceClient()

    # Configurar inspección
    inspect_config = {
        "info_types": [
            {"name": "CREDIT_CARD_NUMBER"},
            {"name": "EMAIL_ADDRESS"},
            {"name": "PHONE_NUMBER"},
            {"name": "MEXICO_CURP"},  # Específico para México
        ],
        "min_likelihood": dlp_v2.Likelihood.LIKELY,
    }

    # Configurar storage
    storage_config = {
        "cloud_storage_options": {
            "file_set": {
                "url": f"gs://{bucket_name}/*"
            }
        }
    }

    # Crear job de inspección
    parent = f"projects/{project_id}"
    response = dlp.create_dlp_job(
        request={
            "parent": parent,
            "inspect_job": {
                "inspect_config": inspect_config,
                "storage_config": storage_config,
            }
        }
    )

    return response.name
```

#### Info Types Soportados
- `CREDIT_CARD_NUMBER`, `IBAN_CODE`
- `EMAIL_ADDRESS`, `PHONE_NUMBER`
- `MEXICO_CURP`, `MEXICO_RFC` (específicos de México)
- `GENERIC_ID`, `AUTH_TOKEN`

---

### Microsoft Purview (Azure)
**Uso obligatorio para datos CRÍTICOS en Azure**

#### Configuración Mínima
```powershell
# Crear política de DLP para SharePoint/OneDrive
New-DlpCompliancePolicy -Name "Protección PII" `
  -ExchangeLocation All `
  -SharePointLocation All `
  -OneDriveLocation All

# Crear regla de detección
New-DlpComplianceRule -Name "Detectar Tarjetas" `
  -Policy "Protección PII" `
  -ContentContainsSensitiveInformation @{
    Name="Credit Card Number";
    minCount="1"
  } `
  -BlockAccess $true `
  -NotifyUser Owner
```

---

### Herramientas Open-Source

#### 1. **Presidio (Microsoft)**
```python
from presidio_analyzer import AnalyzerEngine
from presidio_anonymizer import AnonymizerEngine

# Analizar texto
analyzer = AnalyzerEngine()
results = analyzer.analyze(
    text="Mi tarjeta es 4532-1234-5678-9010",
    language='es'
)

# Anonimizar
anonymizer = AnonymizerEngine()
anonymized = anonymizer.anonymize(
    text="Mi tarjeta es 4532-1234-5678-9010",
    analyzer_results=results
)
print(anonymized.text)  # "Mi tarjeta es <CREDIT_CARD>"
```

#### 2. **Detect-Secrets (Yelp)**
```bash
# Escanear repositorio en busca de secretos
detect-secrets scan --all-files > .secrets.baseline

# Auditar resultados
detect-secrets audit .secrets.baseline
```

---

## 📝 Proceso de Clasificación

### 1. Identificación de Datos
**Responsable**: Data Owner (típicamente Product Manager o Tech Lead)

- Inventariar todos los datos procesados por el sistema
- Documentar origen, propósito, y destino de cada tipo de dato
- Identificar datos regulados (GDPR, PCI DSS, HIPAA, etc.)

### 2. Asignación de Categoría
**Responsable**: Data Owner + Security Team

Usar la siguiente matriz de decisión:

```
┌─────────────────────────────────────────────────────────────┐
│ ¿El dato está regulado por PCI DSS, HIPAA, o similar?       │
│ SÍ → CRÍTICO                                                 │
│ NO → Continuar                                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ ¿La exposición podría causar daño financiero >$100k?        │
│ SÍ → CRÍTICO                                                 │
│ NO → Continuar                                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ ¿El dato identifica a una persona (PII)?                    │
│ SÍ → MODERADO (mínimo)                                       │
│ NO → Continuar                                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ ¿El dato es público o completamente anonimizado?            │
│ SÍ → PÚBLICO                                                 │
│ NO → MODERADO                                                │
└─────────────────────────────────────────────────────────────┘
```

### 3. Documentación
**Responsable**: Data Owner

Crear entrada en el **Data Catalog** con:
- Nombre del dataset
- Categoría de clasificación (CRÍTICO/MODERADO/PÚBLICO)
- Justificación de la clasificación
- Salvaguardias implementadas
- Fecha de revisión (anual)

### 4. Implementación de Controles
**Responsable**: Engineering Team + Security Team

- Aplicar salvaguardias según categoría
- Configurar herramientas DLP
- Implementar cifrado y controles de acceso
- Documentar en diagrama de arquitectura

### 5. Revisión Periódica
**Responsable**: Data Owner

- **Frecuencia**: Anual o cuando cambie el uso de datos
- **Trigger**: Nuevas regulaciones, incidentes de seguridad, cambios de arquitectura
- **Acción**: Re-evaluar clasificación y actualizar controles

---

## 🚨 Manejo de Datos No Clasificados

### Regla de Oro
> **"Si no está clasificado, trátalo como CRÍTICO hasta que se clasifique formalmente"**

### Proceso de Escalamiento
1. **Detección**: Cualquier empleado puede reportar datos no clasificados
2. **Notificación**: Informar a Security Team dentro de 24 horas
3. **Clasificación temporal**: Security Team asigna categoría provisional
4. **Clasificación formal**: Data Owner completa proceso en 5 días hábiles

---

## 📋 Responsabilidades

### Data Owner
- Clasificar datos bajo su responsabilidad
- Aprobar accesos a datos CRÍTICOS
- Revisar clasificación anualmente
- Definir período de retención

### Security Team
- Proveer herramientas DLP
- Auditar cumplimiento de salvaguardias
- Investigar incidentes de exposición de datos
- Mantener actualizada esta política

### Engineering Team
- Implementar controles técnicos
- Etiquetar datos en sistemas (metadata tags)
- Aplicar pseudonimización en entornos no productivos
- Reportar datos no clasificados

### Todos los Empleados
- Cumplir con esta política
- Reportar exposiciones accidentales
- Completar capacitación anual de seguridad de datos

---

## 🔗 Referencias y Cumplimiento Regulatorio

### Regulaciones Aplicables
- **GDPR** (EU): Artículos 5, 25, 32 (protección de datos personales)
- **PCI DSS**: Requisito 3 (protección de datos de tarjetahabientes)
- **HIPAA**: Security Rule (protección de PHI)
- **Ley Federal de Protección de Datos Personales (México)**: Artículos 19, 20

### Estándares de Referencia
- **NIST SP 800-122**: Guide to Protecting PII
- **ISO 27001**: Anexo A.8 (Asset Management)
- **CIS Controls**: Control 3 (Data Protection)

### Herramientas Recomendadas
- **Data Discovery**: AWS Macie, GCP DLP, Microsoft Purview
- **Pseudonimización**: Faker, Mockaroo, Presidio
- **Cifrado**: AWS KMS, GCP Cloud KMS, HashiCorp Vault
- **Secrets Management**: AWS Secrets Manager, Azure Key Vault, Vault

---

## 📞 Contacto y Excepciones

### Solicitud de Excepción
Si no es posible cumplir con alguna salvaguardia, contactar a:
- **Email**: security@[empresa].com
- **Proceso**: Completar formulario de excepción de seguridad
- **Aprobación**: Requiere firma de CISO y Data Owner

### Reporte de Incidentes
En caso de exposición accidental de datos:
1. **Inmediato**: Notificar a Security Team (security@[empresa].com)
2. **1 hora**: Contener la exposición (revocar accesos, eliminar datos expuestos)
3. **24 horas**: Completar reporte de incidente
4. **72 horas**: Notificar a autoridades regulatorias si aplica (GDPR, LFPDP)

---

## ✅ Checklist de Cumplimiento

Usar este checklist para verificar cumplimiento:

### Para Datos CRÍTICOS
- [ ] Cifrado AES-256 en reposo habilitado
- [ ] TLS 1.3 configurado para datos en tránsito
- [ ] MFA habilitado para todos los usuarios con acceso
- [ ] DLP configurado (AWS Macie/GCP DLP/Purview)
- [ ] Logging de accesos habilitado y revisado mensualmente
- [ ] Backups cifrados y almacenados en región diferente
- [ ] Datos pseudonimizados en entornos no productivos
- [ ] Auditoría trimestral de permisos completada

### Para Datos MODERADOS
- [ ] Cifrado en reposo habilitado (AES-128 mínimo)
- [ ] TLS 1.2+ configurado
- [ ] SSO corporativo habilitado
- [ ] Pseudonimización aplicada en dev/staging
- [ ] Logging de accesos habilitado
- [ ] Revisión semestral de permisos completada

### Para Datos PÚBLICOS
- [ ] Control de modificación implementado
- [ ] Backups según política estándar
- [ ] Revisión anual de clasificación completada
