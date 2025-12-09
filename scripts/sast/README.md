# SAST Automation Engine: Static Application Security Testing

**Referencia:** T-12

**Herramienta:** [Semgrep](https://semgrep.dev/ "null") (OSS)

**Versión Script:** 2.0 (Modern Fintech Ruleset) 

**Propósito:** Proveer un mecanismo automatizado para la detección temprana de vulnerabilidades de seguridad, secretos _hardcodeados_ y patrones de diseño inseguros directamente en el código fuente, cumpliendo con el requisito de "Detección Temprana" (Shift-Left).

## 1. Mecanismo de Ejecución y Lógica del Quality Gate

El script `scan-code.sh` opera como un **Quality Gate de Seguridad** de alta fidelidad en local y bloqueante en CI/CD. Su flujo lógico es:

1. **Aprovisionamiento Inteligente:** Detecta la ausencia del binario `semgrep` y crea un entorno virtual efímero (`venv`) para la ejecución aislada, evitando conflictos con el sistema operativo.
    
2. **Análisis Semántico (AST):** Inspecciona el código fuente utilizando Árboles de Sintaxis Abstracta, lo que permite comprender el flujo de datos y reducir los Falsos Positivos comparado con búsquedas de texto plano.
    
3. **Inteligencia Personalizada:** Aplica un _Ruleset_ específico (`ruleset.yml`) diseñado para mitigar riesgos Fintech (PCI/GDPR) y OWASP Top 10.
    
4. **Generación de Evidencia:** Produce artefactos de auditoría en formato estándar (`JSON`) en el directorio `./reports`.
    
5. **Decisión de Bloqueo:** Retorna un código de salida `1` (Error) ante hallazgos de severidad **ERROR**, forzando la detención del _pipeline_ de despliegue.
    

## 2. Procedimiento de Validación Local (PoC)

Este procedimiento permite a los desarrolladores sanear su código antes de realizar un _commit_.

### Requisitos del Entorno

- **Python 3.7+** instalado.
    
- `pip` (gestor de paquetes).
    
- Acceso de lectura al repositorio.
    

### Cobertura de Riesgos (Ruleset Avanzado)

El motor implementa reglas de alta precisión para arquitecturas modernas (Cloud/Microservicios):

|Categoría|Patrones Detectados|
|---|---|
|**Secretos (CWE-798)**|Claves de AWS, Stripe, Slack, Google API y Private Keys (Regex Avanzado).|
|**Inyección SQL/NoSQL (CWE-89)**|Concatenación insegura en SQL y patrones vulnerables en consultas MongoDB/NoSQL.|
|**Riesgos Cloud/API (SSRF/XXE)**|Peticiones HTTP con URLs controladas por usuario (SSRF) y parseo XML inseguro (XXE).|
|**Deserialización (CWE-502)**|Uso peligroso de `pickle`, `yaml.load` o deserializadores que permiten RCE.|
|**Criptografía (CWE-327)**|Uso de algoritmos obsoletos (MD5, SHA1) y generadores aleatorios débiles.|
|**Configuración**|Modo `debug=True` en producción y verificación SSL deshabilitada.|

### Ejecución del Escáner

```
# 1. Asignar permisos de ejecución
chmod +x scripts/sast/scan-code.sh

# 2. Iniciar el motor de análisis
./scripts/sast/scan-code.sh

```

### Interpretación de Resultados

En caso de fallo, el sistema desplegará un resumen en consola y la ubicación del reporte JSON:

```
[ERROR]  FALLO DE SEGURIDAD: Se detectaron 3 vulnerabilidades.
--- Detalle de Hallazgos ---
CRITICAL: Deserialización insegura detectada (pickle)...
   --> vulnerable_code.py:97

```

## 3. Artefactos de Auditoría y Reportes

El motor genera evidencia persistente en la carpeta `reports/` con _timestamps_ únicos para trazabilidad:

- **`sast_report_*.json`**: Formato estructurado conteniendo metadatos de la regla violada (ID, Mensaje, OWASP Category), línea de código afectada y ruta del archivo. Compatible con **DefectDojo** y **SonarQube**.
    

## 4. Integración en Pipeline CI/CD (GitHub Actions)

Para implementar el control **"Shift-Left"**, incorpore el siguiente _stage_ en el flujo de trabajo (`.github/workflows/pipeline.yml`). Esto garantiza que ningún código vulnerable sea fusionado a la rama principal.

```
jobs:
  sast-quality-gate:
    name: SAST Security Audit
    runs-on: ubuntu-latest
    steps:
      - name: Checkout del Código Fuente
        uses: actions/checkout@v3

      - name: Ejecutar Motor SAST (Semgrep Wrapper)
        run: |
          chmod +x scripts/sast/scan-code.sh
          ./scripts/sast/scan-code.sh
        
      - name: Archivar Evidencia de Auditoría
        if: always() # Garantizar la subida del reporte incluso en caso de fallo
        uses: actions/upload-artifact@v3
        with:
          name: sast-compliance-reports
          path: reports/

```

## 5. Diagnóstico y Resolución de Incidentes

**Incidente:** `Fallo crítico al instalar dependencias de Semgrep` o errores `PEP 668`.

- **Causa Raíz:** Restricciones de instalación de paquetes Python a nivel de sistema (común en Kali/Debian 12+).
    
- **Resolución:** El script `scan-code.sh` maneja esto automáticamente creando un entorno virtual (`.venv_sast`). Asegúrese de tener instalado `python3-venv`.
    

**Incidente:** Falsos Positivos recurrentes (Bloqueo de código seguro).

- **Causa Raíz:** El motor detecta un patrón que parece vulnerable pero está sanitizado o es intencional.
    
- **Resolución:** Aplicar el mecanismo de supresión documentada. Agregue el comentario `# nosemgrep: <rule-id>` en la línea afectada explicando la justificación.
