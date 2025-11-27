# Checklist: Revisión Manual de Código Seguro (Quality Gate)

## 📋 Descripción
Este checklist define el **Quality Gate de seguridad** que debe aplicarse antes de integrar código en CI/CD. Está diseñado para guiar al revisor en la identificación de patrones de código inseguro durante Pull Requests manuales.

**Objetivo**: Detectar vulnerabilidades comunes antes de que el código llegue a producción.

---

## ✅ Validación de Inputs

### [ ] 1. Sanitización de Entradas de Usuario
- **¿Qué revisar?**
  - Todos los datos recibidos desde formularios, APIs, URLs o headers HTTP
  - Validación tanto en cliente como en servidor (nunca confiar solo en frontend)

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Sin validación
  const userId = req.query.id;
  db.query(`SELECT * FROM users WHERE id = ${userId}`);

  // ✅ BIEN - Con validación y sanitización
  const userId = validator.isInt(req.query.id) ? parseInt(req.query.id) : null;
  if (!userId) throw new Error('Invalid user ID');
  ```

- **Checklist específico:**
  - [ ] Se valida tipo de dato (string, int, email, etc.)
  - [ ] Se valida longitud máxima/mínima
  - [ ] Se valida formato (regex para emails, URLs, etc.)
  - [ ] Se rechazan caracteres especiales peligrosos (`<`, `>`, `'`, `"`, `;`, `--`)
  - [ ] Se usa allowlist en lugar de blocklist cuando sea posible

---

### [ ] 2. Prevención de SQL Injection

- **¿Qué revisar?**
  - Cualquier consulta SQL que incluya datos del usuario

- **Patrones inseguros a detectar:**
  ```python
  # ❌ MAL - Concatenación de strings
  query = f"SELECT * FROM users WHERE email = '{user_email}'"
  cursor.execute(query)

  # ✅ BIEN - Consultas parametrizadas
  query = "SELECT * FROM users WHERE email = %s"
  cursor.execute(query, (user_email,))
  ```

- **Checklist específico:**
  - [ ] Se usan consultas parametrizadas (prepared statements)
  - [ ] NO se concatenan strings para construir SQL
  - [ ] Se usa ORM con protección contra SQL injection (ej: SQLAlchemy, Sequelize)
  - [ ] Se valida input antes de usarlo en `LIKE`, `ORDER BY`, o nombres de tablas

---

### [ ] 3. Prevención de XSS (Cross-Site Scripting)

- **¿Qué revisar?**
  - Cualquier dato del usuario que se renderice en HTML

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Inserción directa en DOM
  document.getElementById('username').innerHTML = userInput;

  // ✅ BIEN - Escapado automático
  document.getElementById('username').textContent = userInput;
  // O usar framework con escapado automático (React, Vue)
  ```

- **Checklist específico:**
  - [ ] Se usa `textContent` en lugar de `innerHTML` para datos del usuario
  - [ ] Se escapan caracteres HTML (`<`, `>`, `&`, `"`, `'`)
  - [ ] Se usa Content Security Policy (CSP) en headers HTTP
  - [ ] Se valida y sanitiza input en formularios WYSIWYG

---

### [ ] 4. Validación de Uploads de Archivos

- **¿Qué revisar?**
  - Endpoints que permiten subir archivos

- **Patrones inseguros a detectar:**
  ```php
  // ❌ MAL - Sin validación de tipo
  move_uploaded_file($_FILES['file']['tmp_name'], '/uploads/' . $_FILES['file']['name']);

  // ✅ BIEN - Validación estricta
  $allowed = ['jpg', 'png', 'pdf'];
  $ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
  if (!in_array(strtolower($ext), $allowed)) {
      throw new Exception('Tipo de archivo no permitido');
  }
  ```

- **Checklist específico:**
  - [ ] Se valida extensión del archivo (allowlist)
  - [ ] Se valida MIME type real (no solo el declarado)
  - [ ] Se renombra el archivo (no usar nombre original)
  - [ ] Se limita tamaño máximo de archivo
  - [ ] Se almacenan archivos fuera del webroot o con permisos restrictivos

---

## 🔐 Autenticación y Autorización

### [ ] 5. Manejo Seguro de Contraseñas

- **¿Qué revisar?**
  - Código que crea, almacena o verifica contraseñas

- **Patrones inseguros a detectar:**
  ```python
  # ❌ MAL - Hash débil
  import hashlib
  password_hash = hashlib.md5(password.encode()).hexdigest()

  # ✅ BIEN - Bcrypt/Argon2
  import bcrypt
  password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
  ```

- **Checklist específico:**
  - [ ] Se usa bcrypt, Argon2, o PBKDF2 (NO MD5, SHA1, o SHA256 simple)
  - [ ] Se usa salt único por usuario (automático en bcrypt)
  - [ ] NO se loggean contraseñas en texto plano
  - [ ] Se implementa rate limiting en login
  - [ ] Se requiere complejidad mínima de contraseña

---

### [ ] 6. Gestión de Sesiones y Tokens

- **¿Qué revisar?**
  - Código que maneja JWT, cookies de sesión, o tokens de API

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Token sin expiración
  const token = jwt.sign({ userId: user.id }, SECRET_KEY);

  // ✅ BIEN - Token con expiración
  const token = jwt.sign(
    { userId: user.id },
    SECRET_KEY,
    { expiresIn: '1h' }
  );
  ```

- **Checklist específico:**
  - [ ] Los tokens tienen tiempo de expiración
  - [ ] Se usa `httpOnly` y `secure` en cookies de sesión
  - [ ] Se implementa refresh token rotation
  - [ ] Se invalidan tokens al hacer logout
  - [ ] NO se almacenan tokens en localStorage (usar httpOnly cookies)

---

### [ ] 7. Control de Acceso (Authorization)

- **¿Qué revisar?**
  - Endpoints que requieren permisos específicos

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Sin verificación de permisos
  app.delete('/api/users/:id', (req, res) => {
    deleteUser(req.params.id);
  });

  // ✅ BIEN - Verificación de permisos
  app.delete('/api/users/:id', requireAdmin, (req, res) => {
    if (req.user.id !== req.params.id && !req.user.isAdmin) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    deleteUser(req.params.id);
  });
  ```

- **Checklist específico:**
  - [ ] Se verifica autorización en CADA endpoint protegido
  - [ ] Se valida que el usuario solo acceda a SUS propios recursos
  - [ ] Se implementa RBAC (Role-Based Access Control) o ABAC
  - [ ] NO se confía en datos del cliente para determinar permisos

---

## 🗄️ Seguridad de Bases de Datos

### [ ] 8. Consultas SQL Parametrizadas

- **Checklist específico:**
  - [ ] NO se usa concatenación de strings en SQL
  - [ ] Se usan placeholders (`?`, `%s`, `:param`)
  - [ ] Se valida input antes de usar en `ORDER BY` o nombres de columnas
  - [ ] Se limita número de resultados (LIMIT) para prevenir DoS

---

### [ ] 9. Principio de Mínimo Privilegio en DB

- **¿Qué revisar?**
  - Configuración de conexión a base de datos

- **Checklist específico:**
  - [ ] El usuario de DB tiene solo permisos necesarios (no usar `root`)
  - [ ] Se usan usuarios diferentes para lectura vs escritura
  - [ ] Se deshabilitan comandos peligrosos (`xp_cmdshell`, `LOAD_FILE`)

---

## 🔒 Manejo de Datos Sensibles

### [ ] 10. Exposición de Información Sensible

- **¿Qué revisar?**
  - Logs, mensajes de error, respuestas de API

- **Patrones inseguros a detectar:**
  ```python
  # ❌ MAL - Stack trace en producción
  except Exception as e:
      return jsonify({'error': str(e), 'trace': traceback.format_exc()})

  # ✅ BIEN - Mensaje genérico
  except Exception as e:
      logger.error(f"Error: {e}", exc_info=True)
      return jsonify({'error': 'Internal server error'}), 500
  ```

- **Checklist específico:**
  - [ ] NO se exponen stack traces en producción
  - [ ] NO se loggean contraseñas, tokens, o datos de tarjetas
  - [ ] Los mensajes de error son genéricos para el usuario
  - [ ] Se usa logging estructurado con niveles apropiados
  - [ ] Se enmascaran datos sensibles en logs (ej: `****1234` para tarjetas)

---

### [ ] 11. Cifrado de Datos Sensibles

- **¿Qué revisar?**
  - Almacenamiento de datos como PII, tarjetas de crédito, secretos

- **Checklist específico:**
  - [ ] Datos sensibles se cifran en reposo (AES-256)
  - [ ] Se usa HTTPS/TLS para datos en tránsito
  - [ ] Las claves de cifrado NO están hardcodeadas
  - [ ] Se usa un gestor de secretos (AWS Secrets Manager, Vault)

---

## 🌐 Seguridad de APIs

### [ ] 12. Rate Limiting y Throttling

- **¿Qué revisar?**
  - Endpoints públicos o de autenticación

- **Checklist específico:**
  - [ ] Se implementa rate limiting por IP
  - [ ] Se limitan intentos de login (ej: 5 intentos / 15 min)
  - [ ] Se protegen endpoints de registro/creación de recursos

---

### [ ] 13. CORS (Cross-Origin Resource Sharing)

- **¿Qué revisar?**
  - Configuración de headers CORS

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - CORS abierto a todos
  app.use(cors({ origin: '*' }));

  // ✅ BIEN - CORS restrictivo
  app.use(cors({
    origin: 'https://app.example.com',
    credentials: true
  }));
  ```

- **Checklist específico:**
  - [ ] NO se usa `Access-Control-Allow-Origin: *` en producción
  - [ ] Se especifican orígenes permitidos explícitamente
  - [ ] Se valida el header `Origin` en el servidor

---

### [ ] 14. Output Encoding en APIs

- **¿Qué revisar?**
  - Respuestas JSON que incluyen datos del usuario

- **Checklist específico:**
  - [ ] Se usa `Content-Type: application/json` correcto
  - [ ] NO se retornan datos sensibles innecesarios (ej: password hash)
  - [ ] Se filtran campos según permisos del usuario

---

## 🛡️ Protección contra Ataques Comunes

### [ ] 15. CSRF (Cross-Site Request Forgery)

- **¿Qué revisar?**
  - Formularios y endpoints que modifican estado (POST, PUT, DELETE)

- **Checklist específico:**
  - [ ] Se usan tokens CSRF en formularios
  - [ ] Se valida header `X-Requested-With` o `Origin`
  - [ ] Se usa `SameSite=Strict` o `Lax` en cookies

---

### [ ] 16. Inyección de Comandos

- **¿Qué revisar?**
  - Código que ejecuta comandos del sistema operativo

- **Patrones inseguros a detectar:**
  ```python
  # ❌ MAL - Inyección de comandos
  import os
  os.system(f"ping {user_input}")

  # ✅ BIEN - Usar librerías específicas
  import subprocess
  subprocess.run(['ping', '-c', '4', user_input], check=True)
  ```

- **Checklist específico:**
  - [ ] NO se usa `eval()`, `exec()`, `system()` con input del usuario
  - [ ] Se usan librerías específicas en lugar de comandos shell
  - [ ] Se valida input con allowlist estricta

---

### [ ] 17. Path Traversal

- **¿Qué revisar?**
  - Código que accede a archivos basándose en input del usuario

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Path traversal
  const filePath = `/uploads/${req.query.filename}`;
  res.sendFile(filePath);

  // ✅ BIEN - Validación de path
  const path = require('path');
  const safePath = path.normalize(req.query.filename).replace(/^(\.\.[\/\\])+/, '');
  const filePath = path.join(__dirname, 'uploads', safePath);
  ```

- **Checklist específico:**
  - [ ] Se valida que el path no contenga `../` o `..\`
  - [ ] Se usa `path.join()` y `path.normalize()`
  - [ ] Se verifica que el archivo esté dentro del directorio permitido

---

## 🔧 Configuración y Dependencias

### [ ] 18. Gestión de Secretos

- **¿Qué revisar?**
  - Claves API, contraseñas de DB, tokens

- **Patrones inseguros a detectar:**
  ```javascript
  // ❌ MAL - Secreto hardcodeado
  const API_KEY = 'sk_live_1234567890abcdef';

  // ✅ BIEN - Variable de entorno
  const API_KEY = process.env.API_KEY;
  if (!API_KEY) throw new Error('API_KEY not configured');
  ```

- **Checklist específico:**
  - [ ] NO hay secretos hardcodeados en el código
  - [ ] Se usan variables de entorno o gestores de secretos
  - [ ] Los archivos `.env` están en `.gitignore`
  - [ ] Se rotan secretos periódicamente

---

### [ ] 19. Dependencias Vulnerables

- **¿Qué revisar?**
  - Archivos `package.json`, `requirements.txt`, `pom.xml`

- **Checklist específico:**
  - [ ] Se ejecuta `npm audit` / `pip-audit` antes del merge
  - [ ] NO hay dependencias con vulnerabilidades CRITICAL o HIGH
  - [ ] Se especifican versiones exactas (no `^` o `~` en producción)
  - [ ] Se revisan dependencias transitivas

---

### [ ] 20. Headers de Seguridad HTTP

- **¿Qué revisar?**
  - Configuración de servidor web o middleware

- **Checklist específico:**
  - [ ] `Strict-Transport-Security` (HSTS) está configurado
  - [ ] `X-Content-Type-Options: nosniff` está presente
  - [ ] `X-Frame-Options: DENY` o `SAMEORIGIN` está configurado
  - [ ] `Content-Security-Policy` está definido
  - [ ] NO se expone `X-Powered-By` o `Server`

---

## 📊 Criterios de Aprobación

### ✅ El PR puede aprobarse si:
- [ ] **TODOS** los items críticos (SQL injection, XSS, auth) están verificados
- [ ] No se detectaron patrones inseguros de alto riesgo
- [ ] Se documentaron excepciones justificadas (si las hay)

### ❌ El PR debe rechazarse si:
- [ ] Se detecta concatenación de SQL con input del usuario
- [ ] Hay secretos hardcodeados en el código
- [ ] Falta validación de input en endpoints públicos
- [ ] Se exponen stack traces o datos sensibles en logs

---

## 🔗 Referencias
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Code Review Guide](https://owasp.org/www-project-code-review-guide/)
- [CWE Top 25](https://cwe.mitre.org/top25/)
- [NIST Secure Software Development Framework](https://csrc.nist.gov/projects/ssdf)

---

## 📝 Notas para Revisores

1. **Prioriza según contexto**: No todos los items aplican a todos los PRs
2. **Usa herramientas**: Complementa con SAST (Semgrep, SonarQube) cuando sea posible
3. **Educa al equipo**: Comparte hallazgos como oportunidades de aprendizaje
4. **Documenta excepciones**: Si se acepta un riesgo, documentarlo explícitamente

