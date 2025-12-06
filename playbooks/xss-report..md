# Playbook: Reporte de Cross-Site Scripting (XSS)

**Clasificación del Incidente:** Inyección de Script en el Lado del Cliente **Severidad Clasificada:** ALTA (Riesgo de robo de sesión/PII)

**Tiempo Objetivo de Respuesta:** < 15 minutos (Bloqueo de la URL/Función) **Documento Vinculado:** Checklist de Revisión de Código Seguro (S1-T08)

## 1.0 Protocolo de Respuesta Inmediata (Fase I: Contención)

**Objetivo:** Eliminar el vector de ataque del sitio o bloquear el acceso al recurso comprometido.

### 1.1 Tarea Crítica: Identificación del Vector y Contención del Endpoint (0-10 minutos)

|Tarea|Procedimiento Operacional|
|---|---|
|[ ] **Identificación del Vector**|Determinar si el XSS es **Almacenado** (Strored) o **Reflejado** (Reflected). _El XSS Almacenado es el de mayor criticidad._|
|[ ] **Ruta y Parámetro**|Identificar la URL completa, el parámetro vulnerable y la línea de código que está fallando en la codificación de la salida.|
|[ ] **Bloqueo de Emergencia (WAF)**|Si la vulnerabilidad está en un _endpoint_ o _path_ específico, implementar una regla de WAF de inmediato para bloquear peticiones que contengan caracteres sospechosos (`<script>`, `<img`, `onerror`, etc.) en ese _path_.|
|[ ] **Deshabilitación (Strored XSS)**|Si el ataque es de tipo **Almacenado** (ej. en comentarios de usuario o descripciones de producto), deshabilitar inmediatamente la función de escritura o purgar los datos comprometidos de la base de datos hasta que el parche sea desplegado.|
|[ ] **Notificación Formal**|Notificar al canal de incidentes indicando el _endpoint_ y el estado de la contención.|

## 2.0 Análisis de Impacto y Root Cause Analysis (Fase II)

**Objetivo:** Determinar el alcance potencial del robo de sesión (cookies, tokens) y parchear el código vulnerable.

### 2.1 Análisis de la Exposición y Causa Raíz

|Tarea|Procedimiento de Análisis|
|---|---|
|[ ] **Revisión de Logs**|Buscar en los logs del WAF o IDS si el _payload_ de ataque se ha ejecutado múltiples veces o desde diferentes IPs.|
|[ ] **Exposición de Sesión**|Determinar si las _cookies_ de sesión críticas tienen la bandera **`HttpOnly`**. _Si falta HttpOnly, la cookie pudo ser robada._|
|[ ] **Identificación de Código**|Localizar la línea de código donde el _output_ no fue sanitizado/codificado correctamente (ej. usando `.innerHTML` en lugar de `.textContent` en JavaScript).|
|[ ] **Creación del Parche**|Desarrollar un _hotfix_ que utilice una función de _output encoding_ estricta o migre el código a un _framework_ que codifique el _output_ por defecto (ej. React/Vue).|

### 2.2 Cuantificación y Parche Final

- **Cuantificación:** Determinar si la vulnerabilidad es Autenticada o No Autenticada. El riesgo es mayor si el XSS puede ejecutarse sin iniciar sesión.
    
- **Despliegue del Fix:** Desplegar el parche inmediatamente en producción.
    
- **Verificación de Parche:** Correr un escaneo DAST (ZAP) contra el _endpoint_ parcheado para confirmar la mitigación de la vulnerabilidad.
    

## 3.0 Fortalecimiento Preventivo y Cierre Formal

**Objetivo:** Asegurar la no recurrencia y actualizar los estándares de desarrollo.

### 3.1 Hardening de la Configuración del Cliente

|Tarea|Protocolo de Fortalecimiento|
|---|---|
|[ ] **Configuración HSTS/CSP**|Asegurar que el servidor esté devolviendo encabezados **HSTS** y una **Política de Seguridad de Contenido (CSP)** estricta, limitando las fuentes de _scripts_ externos.|
|[ ] **Flag HttpOnly**|Verificar que todas las _cookies_ de sesión y autenticación tengan la bandera **`HttpOnly`** para prevenir el robo por scripts maliciosos.|
|[ ] **Capacitación del Desarrollador**|Utilizar el código comprometido como ejemplo para la capacitación sobre _Output Encoding_ (Ver T-18).|

### 3.2 Documentación de Cierre

- **Post-Mortem:** Documentar el incidente en la **Plantilla de Post-Mortem** con la línea de tiempo completa y las acciones correctivas.
    
- **Actualización del Checklist:** Asegurarse de que el _Checklist de Revisión de Código Seguro_ (S1-T08) contenga una verificación más estricta de _Output Encoding_.
    

### Referencias Técnicas Clave

- **Solución Permanente:** Migrar a _templating engines_ o _frameworks_ con codificación automática de salida (Auto-Escaping).
    
- **Guía de Prevención:** OWASP XSS Prevention Cheat Sheet.
    
- **Herramientas de Búsqueda:** SAST (Semgrep) debe detectar patrones inseguros de `innerHTML`.
