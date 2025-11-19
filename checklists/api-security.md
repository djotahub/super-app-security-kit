# Checklist de Auditoría de Seguridad en APIs (OWASP Top 10)

**Fecha de Auditoría:** **\*\***\_\_\_**\*\***
**Auditor:** **\*\***\_\_\_**\*\***
**API Auditada:** **\*\***\_\_\_**\*\***
**Tipo:** [ ] RESTful [ ] GraphQL

Este instrumento verifica el cumplimiento de controles de seguridad críticos basados en OWASP API Security Top 10 (2023).
**Instrucción:** Marque la casilla únicamente si el control se cumple satisfactoriamente.

---

## 🚨 Controles Críticos (Requeridos por Ticket)

### API1: Broken Object Level Authorization (BOLA)

_El riesgo más crítico: verificar que el usuario A no pueda ver/editar datos del usuario B._

| Estado | Verificación                                                                                                                                 |
| :----: | :------------------------------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Validación de ID:** ¿El servidor valida que el `ID` del recurso solicitado pertenece al usuario autenticado antes de devolver datos?       |
|  [ ]   | **IDs No Secuenciales:** ¿Se utilizan UUIDs o IDs aleatorios en lugar de IDs autoincrementales (ej. 1, 2, 3) para dificultar la enumeración? |
|  [ ]   | **Tests de Acceso:** ¿Se han ejecutado pruebas intentando acceder a recursos de otros usuarios con un token válido ajeno?                    |

### API3: Broken Object Property Level Authorization (Mass Assignment)

_Evitar que se modifiquen campos sensibles (ej. saldo, rol, permisos)._

| Estado | Verificación                                                                                                                               |
| :----: | :----------------------------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Filtrado de Inputs:** ¿La API ignora o rechaza explícitamente campos de entrada que no espera (whitelisting)?                            |
|  [ ]   | **Inmutabilidad:** ¿Los campos sensibles (como `is_admin`, `role`, `balance`) están bloqueados para modificación directa desde el cliente? |
|  [ ]   | **Esquemas Definidos:** (GraphQL/REST) ¿Los esquemas de entrada definen estrictamente qué campos son escribibles?                          |

### API4: Unrestricted Resource Consumption (Rate Limiting)

_Evitar ataques de denegación de servicio o fuerza bruta._

| Estado | Verificación                                                                                                                           |
| :----: | :------------------------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Límites por Usuario/IP:** ¿Existe un límite de peticiones (Rate Limiting) configurado (ej. 100 req/min) para todos los endpoints?    |
|  [ ]   | **Paginación Forzada:** ¿Los endpoints que devuelven listas tienen paginación obligatoria y un límite máximo de resultados por página? |
|  [ ]   | **Timeouts:** ¿Existen tiempos de espera (timeouts) configurados para evitar que operaciones pesadas bloqueen el servidor?             |

---

## 🛡️ Controles Generales OWASP API

### Autenticación y Gestión de Sesiones (API2)

| Estado | Verificación                                                                                                 |
| :----: | :----------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Protección de Tokens:** ¿Se validan la firma y expiración de los JWT (JSON Web Tokens) en cada petición?   |
|  [ ]   | **Mecanismos Estándar:** ¿Se usa `Authorization: Bearer` o cookies seguras en lugar de pasar tokens por URL? |

### Broken Function Level Authorization (BFLA - API5)

| Estado | Verificación                                                                                                             |
| :----: | :----------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Roles y Permisos:** ¿Se verifica el rol del usuario (Admin vs. User) en el servidor para cada endpoint administrativo? |
|  [ ]   | **Separación:** ¿Las funciones administrativas están separadas lógicamente de las funciones de usuario regular?          |

### Server Side Request Forgery (SSRF - API7)

| Estado | Verificación                                                                                                                                               |
| :----: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Validación de URL:** Si la API acepta una URL como parámetro, ¿se valida que no apunte a direcciones IP internas o locales (ej. 127.0.0.1, 169.254.x.x)? |

### Configuración de Seguridad (API8)

| Estado | Verificación                                                                                                                       |
| :----: | :--------------------------------------------------------------------------------------------------------------------------------- |
|  [ ]   | **CORS:** ¿La política de CORS es restrictiva (no usar `*` en producción)?                                                         |
|  [ ]   | **Mensajes de Error:** ¿Los mensajes de error genéricos evitan filtrar información sensible (stack traces, versiones de software)? |
|  [ ]   | **HTTPS:** ¿Todo el tráfico de la API está forzado a través de TLS/HTTPS?                                                          |

### Inventario y Gestión (API9)

| Estado | Verificación                                                                                             |
| :----: | :------------------------------------------------------------------------------------------------------- |
|  [ ]   | **Documentación:** ¿Existe documentación actualizada (Swagger/OpenAPI) de todos los endpoints expuestos? |
|  [ ]   | **Entornos:** ¿Los endpoints de prueba o "v1" obsoletos han sido deshabilitados en producción?           |
