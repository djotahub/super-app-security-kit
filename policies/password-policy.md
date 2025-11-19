# 🔐 Política de Contraseñas - Sector Bancario

**Fecha de vigencia:** **\*\***\_\_\_**\*\***  
**Ámbito de aplicación:** Todos los sistemas bancarios, empleados y clientes de **entidades bancarias**  
**Base de cumplimiento:** NIST 800-63B, Superintendencia de Bancos

Este instrumento verifica el cumplimiento de controles de seguridad críticos para gestión de contraseñas en el ámbito bancario.
**Instrucción:** Marque la casilla únicamente si el control se cumple satisfactoriamente.

---

## 🚨 Controles Críticos (Requeridos por Regulación Bancaria)

### Longitud y Composición

| Estado | Verificación | Nivel de Riesgo |
| :----: | :--- | :--- |
|  [ ]   | **Clientes:** ¿Las contraseñas tienen longitud mínima de 12 caracteres? | 🔴 Crítico |
|  [ ]   | **Empleados:** ¿Las contraseñas internas tienen longitud mínima de 14 caracteres? | 🔴 Crítico |
|  [ ]   | **Administradores:** ¿Las cuentas privilegiadas requieren mínimo 16 caracteres? | 🔴 Crítico |
|  [ ]   | **Verificación:** ¿El sistema valida contra listas de contraseñas conocidas en brechas? | 🔴 Crítico |

### Autenticación Multifactor (MFA)

| Estado | Verificación | Nivel de Riesgo |
| :----: | :--- | :--- |
|  [ ]   | **Clientes:** ¿MFA obligatorio para transacciones de alto valor? | 🔴 Crítico |
|  [ ]   | **Empleados:** ¿MFA requerido para acceso a sistemas internos? | 🔴 Crítico |
|  [ ]   | **Administradores:** ¿MFA con doble factor para cuentas privilegiadas? | 🔴 Crítico |
|  [ ]   | **Respaldo:** ¿Existen métodos de recuperación seguros (no SMS único)? | 🟡 Alto |

### Gestión de Credenciales

| Estado | Verificación | Nivel de Riesgo |
| :----: | :--- | :--- |
|  [ ]   | **Almacenamiento:** ¿Las contraseñas se almacenan con hash seguro (bcrypt, Argon2)? | 🔴 Crítico |
|  [ ]   | **Transmisión:** ¿Las contraseñas viajan siempre encriptadas (TLS 1.2+)? | 🔴 Crítico |
|  [ ]   | **Intentos fallidos:** ¿Límite de 5 intentos antes de bloqueo temporal? | 🟡 Alto |
|  [ ]   | **Sesiones:** ¿Timeout automático después de 15 minutos de inactividad? | 🟡 Alto |

---

## 🛡️ Controles Específicos Sector Bancario

### Para Clientes Bancarios

| Estado | Verificación | Cumplimiento |
| :----: | :--- | :--- |
|  [ ]   | **Frases de acceso:** ¿Se recomiendan frases en lugar de contraseñas complejas? | NIST 800-63B |
|  [ ]   | **Transacciones:** ¿Re-autenticación requerida para operaciones sensibles? | SBIF |
|  [ ]   | **Educación:** ¿Campañas periódicas sobre phishing y seguridad? | Mejores Prácticas |
|  [ ]   | **Monitoreo:** ¿Detección proactiva de comportamientos sospechosos? | Basel III |

### Para Empleados del Banco

| Estado | Verificación | Cumplimiento |
| :----: | :--- | :--- |
|  [ ]   | **Gestores:** ¿Uso obligatorio de gestores de contraseñas corporativos? | Política Interna |
|  [ ]   | **Separación:** ¿Contraseñas diferentes para sistemas críticos vs. generales? | SOX |
|  [ ]   | **Training:** ¿Capacitación semestral en ciberseguridad? | ISO 27001 |
|  [ ]   | **Auditoría:** ¿Revisiones trimestrales de cuentas privilegiadas? | PCI DSS |

### Controles Técnicos Implementados

| Estado | Verificación | Nivel |
| :----: | :--- | :--- |
|  [ ]   | **API Security:** ¿Validación de tokens JWT con firma criptográfica? | 🔴 Crítico |
|  [ ]   | **Rate Limiting:** ¿Límites por usuario/IP para endpoints de autenticación? | 🟡 Alto |
|  [ ]   | **Logging:** ¿Registro de intentos fallidos y accesos exitosos? | 🟡 Alto |
|  [ ]   | **Encryption:** ¿Cifrado de datos sensibles en reposo y tránsito? | 🔴 Crítico |

---

## 📊 Matriz de Cumplimiento Regulatorio

### Requisitos Específicos por Estándar

| Estándar | Controles Implementados | Estado |
| :--- | :--- | :--- |
| **NIST 800-63B** | Longitud mínima, sin rotación forzada, MFA | [ ] Cumple |
| **Basel III** | Gestión de riesgo operacional, monitoreo continuo | [ ] Cumple |
| **PCI DSS** | Protección datos tarjetas, controles de acceso | [ ] Cumple |
| **ISO 27001** | Políticas documentadas, revisiones periódicas | [ ] Cumple |
| **SBIF** | Protección cliente, continuidad operacional | [ ] Cumple |

---

## 🚨 Procedimiento de Incidentes

### Respuesta a Compromiso de Credenciales

| Estado | Procedimiento | Tiempo Máximo |
| :----: | :--- | :--- |
|  [ ]   | **Detección:** ¿Sistemas de alerta temprana implementados? | 5 minutos |
|  [ ]   | **Contención:** ¿Bloqueo inmediato de credenciales afectadas? | 10 minutos |
|  [ ]   | **Investigación:** ¿Análisis forense de accesos sospechosos? | 2 horas |
|  [ ]   | **Comunicación:** ¿Notificación a clientes según regulación? | 24 horas |

### Recuperación de Acceso

| Estado | Procedimiento | Seguridad |
| :----: | :--- | :--- |
|  [ ]   | **Verificación:** ¿Múltiples factores de autenticación para recuperación? | 🔴 Crítico |
|  [ ]   | **Documentación:** ¿Registro completo del proceso de recuperación? | 🟡 Alto |
|  [ ]   | **Seguimiento:** ¿Monitoreo post-recuperación por 72 horas? | 🟡 Alto |

---

## 📝 Evidencia y Auditoría

### Documentación Requerida

- [ ] Política de contraseñas documentada y aprobada
- [ ] Registros de capacitación a empleados
- [ ] Evidencias de controles técnicos implementados
- [ ] Reportes de auditoría interna trimestral
- [ ] Plan de respuesta a incidentes actualizado

---

**Auditor:** **\*\***\_\_\_**\*\***  
**Fecha de revisión:** **\*\***\_\_\_**\*\***  
**Próxima auditoría:** **\*\***\_\_\_**\*\***  

---
*Documento conforme a NIST 800-63B y regulaciones bancarias locales - [Nombre del Banco]*
