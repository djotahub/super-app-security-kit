# Super App Security Kit 

![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![Framework: NIST CSF](https://img.shields.io/badge/Framework-NIST%20CSF-blueviolet)
![Standard: OWASP](https://img.shields.io/badge/Standard-OWASP-orange)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)


**Versión:** 1.0 

**Base:** ISO/IEC 27001, NIST SP 800-63B, OWASP, CIS Benchmarks.

---

Un **Marco de Control DevSecOps** _open-source_ diseñado para establecer la **Postura de Riesgo (Risk Posture)** y la **Orquestación de Detección** de Super Apps Fintech, asegurando la integridad de los datos sensibles desde el primer ciclo de desarrollo.

### 1. Justificación del Proyecto: De la Regulación a la Mitigación

Las Super Apps operan en un entorno de alto riesgo regulatorio. La optimización del _time-to-market_ es históricamente un vector de **deuda técnica de seguridad**.

Este _framework_ no es una documentación teórica; es una **solución de minimización de deuda técnica** entregable en la fase inicial. Proporciona los controles de nivel de ingeniería necesarios para satisfacer los requisitos del Anexo A de **ISO 27001** y asegurar el Nivel de Garantía de Autenticación (AAL) de **NIST 800-63B**.

### 2. Propuesta de Valor y Retorno de Inversión (ROI)

El kit es un mecanismo de transferencia de conocimiento que reduce el riesgo residual a través de la estandarización y automatización de controles.

- **Implementación Táctica:** Proporciona artefactos de código y _checklists_ que se integran directamente en el flujo de trabajo (CI/CD), eliminando la ambigüedad en la implementación.
    
- **Foco en el Dominio Fintech:** Prioriza la mitigación de fallos de **Autorización Lógica (BOLA)** y los riesgos asociados a **Transacciones de Alto Valor** y **Clasificación de Datos**.
    
- **Alineación Normativa:** La documentación y la arquitectura técnica están directamente mapeadas a los controles de **ISO**, **NIST** y **CIS**, facilitando la trazabilidad en futuras auditorías de cumplimiento.
    
- **Eficiencia Operacional:** Construido con _Motores Open-Source_ (Semgrep, OWASP ZAP) para maximizar la capacidad de detección con un TCO (Costo Total de Propiedad) nulo en licencias.
    

### 3. Arquitectura de la Solución (Mapeo Funcional NIST)

La estructura del kit está diseñada para cubrir las **cinco funciones** del NIST Cybersecurity Framework, garantizando una defensa proactiva y reactiva.

|Carpeta|Función NIST|Foco de Ingeniería|
|---|---|---|
|` /policies/`|**IDENTIFICAR**|Establecimiento del **Dominio de Seguridad**. Marco normativo para la Clasificación de Activos (PII/KYC) y Requisitos de Identidad (MFA/RBAC).|
|`/checklists/`|**PROTEGER**|Mecanismos de **Hardening L2** para la infraestructura (Linux, Bases de Datos, Contenedores) y QA de APIs (OWASP).|
|` /scripts/`|**DETECTAR**|**Orquestación de Detección** (Motores SAST, DAST, SCA) con control de `exit codes` para la detención automatizada del _pipeline_ CI/CD.|
|` /playbooks/`|**RESPONDER**|Procedimientos de **Respuesta a Incidentes (IR)** para la contención, análisis forense y protocolo de notificación legal.|
|` /guides/`|**TRANSVERSAL**|Documentación de arquitectura (Threat Modeling, Gestión de Secretos, Ciclo de Vida de Cifrado).|

### 4. Protocolo de Adopción y Flujo de Integración (Go-Live)

La adopción de este _framework_ establece una postura de **Seguridad como Código (Security as Code)**. El flujo se centra en la **Validación Continua** y la integración temprana (_Shift-Left_).

|Fase de la Solución|Objetivo de la Postura de Riesgo|Acción Técnica Clave|Impacto Estratégico|
|---|---|---|---|
|**I. Gobernanza (IDENTIFICAR)**|Mitigación del Riesgo Legal y de Identidad.|Implementar el Nivel de Aseguramiento de Autenticación (AAL) mediante MFA y formalizar el **Modelo RBAC** para el acceso a datos clasificados (PII/KYC).|**Establece la base legal** para el uso de datos (GDPR/ISO).|
|**II. Hardening de Baseline (PROTEGER)**|Reducción del Riesgo Residual en la Infraestructura.|Ejecutar **Hardening L2 (CIS)** en el SO (`linux-hardening.md`) y la Base de Datos (`db-hardening.md`). **Mitiga el riesgo de escalada de privilegios y SSRF.**|**Blindaje proactivo** de los activos que contienen datos sensibles.|
|**III. Integración DevSecOps (DETECTAR)**|Implementación de la Detección No-Regresiva (_Shift-Left_).|Inyectar los _wrappers_ de Python/Bash de **SAST/DAST** en el _pipeline_ CI/CD. **Se requiere un `exit code` de 1 para bloquear el** _**deployment**_ **ante vulnerabilidades Altas.**|**Asegura la velocidad** del desarrollo al encontrar fallos antes de Staging.|
|**IV. Resiliencia (RESPONDER)**|Capacidad Operativa para Contención y Análisis Forense.|Integración de los `playbooks/` con el sistema de _alerting_ (SIEM) para asegurar una respuesta en el tiempo establecido por la normativa (ej. 72 horas).|**Minimiza el impacto financiero** y el riesgo de notificación legal.|

### 5. Catálogo de Arquitectura y Rendición de Cuentas

Esta sección es el índice técnico de los entregables y la documentación de la arquitectura final.

#### 5.1. Directorio `/policies` (Fundamentos de Gobernanza)

- **Propósito:** Proporcionar los documentos normativos para el cumplimiento de ISO/IEC 27001. Estos requieren aprobación ejecutiva formal.
    
- **Archivos Clave:**
    
    - `asset-management-policy.docx`: Define la clasificación de activos (Restringido/KYC) y la **propiedad** del activo (Accountability).
        
    - `password-policy.md`: Define los requisitos de identidad **NIST 800-63B** y la obligatoriedad de MFA.
        

#### 5.2. Directorio `/scripts` (Motores de Automatización)

- **Propósito:** El motor DevSecOps del proyecto. Las herramientas de detección que ejecutan el _Shift-Left_.
    
- **Arquitectura DAST:** `dast/scan.py` es el _wrapper_ de Python. **Función:** Orquestar el escaneo ZAP en _headless_ y devolver el `exit code` al CI/CD.
    
- **Arquitectura SAST:** `sast/ruleset.yml`. **Foco:** Reglas personalizadas (Semgrep) diseñadas para la lógica de negocio Fintech (ej. detección de _hardcoded secrets_ y patrones SQLi).
    

### 6. Gobierno del Proyecto y Cierre Estratégico

- **Coherencia Arquitectónica:** El documento `SECURITY_ARCHITECTURE_SUMMARY.md` detalla las decisiones clave (principios de **Zero Trust**, postura en la nube y modelo de gestión de secretos), justificando el diseño de cada entregable técnico.
    
- **Accountability y Mantenimiento:** La responsabilidad de cada documento de política (`Propietario`) está asignada a roles ejecutivos. El modelo _open-source_ con flujo de _Pull Request_ permite el mantenimiento técnico continuo por parte del equipo de seguridad interno.
    
- **Rendición de Cuentas:** El **`FINAL_EXECUTIVE_REPORT.pdf`** es el artefacto final que traduce el contenido técnico en valor de negocio (Riesgo Mitigado y Roadmap).
    

### 7. Metadatos y Licencia

**Propiedad Intelectual:**

- **Licencia:** MIT (Ver **`LICENSE`**).
    
- **Colaboración:** Consultar **`CONTRIBUTING.md`** para el flujo de _Pull Request_ y estilo de código.
