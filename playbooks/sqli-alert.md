# Playbook: Alerta de SQL Injection (SQLi)

## 🚨 Descripción del Incidente
**Tipo**: Intento de inyección SQL detectado
**Severidad**: 🔴 CRÍTICA
**Tiempo objetivo de respuesta**: < 10 minutos
**Tiempo objetivo de contención**: < 30 minutos

---

## ⚡ Pasos de Respuesta Inmediata (Atomic)

> **IMPORTANTE**: Cada paso debe completarse en **5-10 minutos máximo**. Si un paso toma más tiempo, escalar inmediatamente.

---

### 🛑 PASO 1: Contención Inmediata (0-5 min)
**Objetivo**: Bloquear el ataque en curso ANTES de investigar

#### Acciones
- [ ] **1.1** Identificar el origen del ataque:

```bash
# Revisar alerta de WAF/IDS
# Ejemplo de alerta típica:
# "SQL Injection detected from IP 203.0.113.45 on endpoint /api/users?id=1' OR '1'='1"

# Extraer información clave
ATTACKER_IP="203.0.113.45"
ENDPOINT="/api/users"
PAYLOAD="id=1' OR '1'='1"
TIMESTAMP="2025-11-27 12:45:30 UTC"
```

- [ ] **1.2** Bloquear IP del atacante inmediatamente:

#### AWS WAF
```bash
# Agregar IP a IP Set de bloqueo
aws wafv2 update-ip-set \
  --name BlockedIPs \
  --scope REGIONAL \
  --id a1b2c3d4-5678-90ab-cdef-EXAMPLE11111 \
  --addresses 203.0.113.45/32 \
  --lock-token $(aws wafv2 get-ip-set --name BlockedIPs --scope REGIONAL --id a1b2c3d4-5678-90ab-cdef-EXAMPLE11111 --query 'LockToken' --output text)
```

#### Cloudflare
```bash
# Crear regla de firewall
curl -X POST "https://api.cloudflare.com/client/v4/zones/{zone_id}/firewall/access_rules/rules" \
  -H "X-Auth-Email: user@example.com" \
  -H "X-Auth-Key: your-api-key" \
  -H "Content-Type: application/json" \
  --data '{
    "mode": "block",
    "configuration": {
      "target": "ip",
      "value": "203.0.113.45"
    },
    "notes": "SQLi attack - Incident #12345"
  }'
```

#### Nginx (on-premise)
```bash
# Agregar a lista de bloqueo
echo "deny 203.0.113.45;" >> /etc/nginx/blocked-ips.conf

# Recargar configuración
nginx -t && nginx -s reload
```

#### iptables (Linux)
```bash
# Bloquear IP a nivel de firewall
iptables -A INPUT -s 203.0.113.45 -j DROP

# Persistir regla
iptables-save > /etc/iptables/rules.v4
```

- [ ] **1.3** Verificar bloqueo exitoso:

```bash
# Intentar acceder desde IP bloqueada (desde otra máquina o VPN)
curl -H "X-Forwarded-For: 203.0.113.45" https://api.example.com/test
# Esperado: 403 Forbidden o timeout

# Revisar logs de WAF
tail -f /var/log/nginx/access.log | grep "203.0.113.45"
# No debería haber nuevas entradas
```

- [ ] **1.4** Notificar a equipo:

```
🚨 SQLi ATTACK - IP BLOQUEADA
IP atacante: 203.0.113.45
Endpoint: /api/users
Payload: id=1' OR '1'='1
Bloqueado: ✅ [timestamp]
Investigación en curso...
```

**⏱️ Tiempo estimado**: 3-5 minutos
**✅ Criterio de éxito**: IP bloqueada y ataque detenido

---

### 🔍 PASO 2: Análisis de Impacto Inmediato (5-15 min)
**Objetivo**: Determinar si el ataque fue exitoso y qué datos fueron comprometidos

#### Acciones
- [ ] **2.1** Revisar logs de base de datos:

```bash
# PostgreSQL - Revisar queries ejecutadas en la última hora
sudo -u postgres psql -c "
SELECT
  query_start,
  usename,
  client_addr,
  query
FROM pg_stat_activity
WHERE query_start > NOW() - INTERVAL '1 hour'
  AND query ILIKE '%OR%1%=%1%'
     OR query ILIKE '%UNION%SELECT%'
     OR query ILIKE '%DROP%TABLE%'
ORDER BY query_start DESC;
"

# MySQL - Revisar general log (si está habilitado)
grep -i "OR.*1.*=.*1\|UNION.*SELECT\|DROP.*TABLE" /var/log/mysql/general.log | tail -50
```

- [ ] **2.2** Analizar payload del ataque:

```python
# Script para decodificar payload URL-encoded
import urllib.parse

payload = "id=1%27%20OR%20%271%27%3D%271"
decoded = urllib.parse.unquote(payload)
print(f"Payload decodificado: {decoded}")
# Output: id=1' OR '1'='1

# Clasificar tipo de SQLi
sqli_types = {
    "OR '1'='1": "Authentication Bypass",
    "UNION SELECT": "Union-based SQLi",
    "'; DROP TABLE": "Destructive SQLi",
    "SLEEP(5)": "Time-based Blind SQLi",
    "' AND 1=1--": "Boolean-based Blind SQLi"
}
```

- [ ] **2.3** Verificar si el ataque fue exitoso:

```markdown
## Indicadores de Compromiso

### ❌ Ataque NO exitoso (bloqueado por controles)
- [ ] WAF bloqueó request antes de llegar a la aplicación
- [ ] Aplicación usa consultas parametrizadas (prepared statements)
- [ ] Error 400/403 en logs de aplicación
- [ ] No hay queries anómalas en logs de DB

### ⚠️ Ataque PARCIALMENTE exitoso
- [ ] Request llegó a la aplicación pero falló en DB
- [ ] Error de sintaxis SQL en logs
- [ ] Información de error expuesta al atacante (ej: stack trace)

### 🔴 Ataque EXITOSO (requiere escalamiento inmediato)
- [ ] Query maliciosa ejecutada en DB
- [ ] Datos extraídos (ej: UNION SELECT retornó resultados)
- [ ] Autenticación bypasseada (login sin credenciales válidas)
- [ ] Datos modificados/eliminados (UPDATE/DELETE/DROP)
```

- [ ] **2.4** Cuantificar impacto:

```markdown
## Impacto Estimado
- **Datos accedidos**: [Sí/No] - [Tabla/columnas específicas]
- **Datos modificados**: [Sí/No] - [Descripción]
- **Datos eliminados**: [Sí/No] - [Tablas afectadas]
- **Autenticación bypasseada**: [Sí/No]
- **Número de registros afectados**: [cantidad]
- **Usuarios impactados**: [número o "Ninguno"]
```

**⏱️ Tiempo estimado**: 8-10 minutos
**✅ Criterio de éxito**: Impacto determinado y documentado

---

### 🔬 PASO 3: Análisis de Vulnerabilidad (15-25 min)
**Objetivo**: Identificar el código vulnerable que permitió el ataque

#### Acciones
- [ ] **3.1** Identificar endpoint vulnerable:

```bash
# Extraer endpoint de logs de aplicación
grep "203.0.113.45" /var/log/app/access.log | grep -E "GET|POST" | tail -10

# Ejemplo de output:
# [2025-11-27 12:45:30] 203.0.113.45 GET /api/users?id=1' OR '1'='1 HTTP/1.1 200
```

- [ ] **3.2** Revisar código del endpoint:

```bash
# Buscar implementación del endpoint
grep -r "GET.*\/api\/users" app/routes/ app/controllers/

# Revisar archivo identificado
cat app/controllers/users_controller.py
```

- [ ] **3.3** Identificar patrón vulnerable:

#### ❌ Patrón VULNERABLE (concatenación de strings)
```python
# VULNERABLE - NO USAR
@app.route('/api/users')
def get_user():
    user_id = request.args.get('id')
    query = f"SELECT * FROM users WHERE id = {user_id}"  # ⚠️ VULNERABLE
    cursor.execute(query)
    return jsonify(cursor.fetchall())
```

```javascript
// VULNERABLE - NO USAR
app.get('/api/users', (req, res) => {
  const userId = req.query.id;
  const query = `SELECT * FROM users WHERE id = ${userId}`;  // ⚠️ VULNERABLE
  db.query(query, (err, results) => {
    res.json(results);
  });
});
```

```php
// VULNERABLE - NO USAR
$user_id = $_GET['id'];
$query = "SELECT * FROM users WHERE id = $user_id";  // ⚠️ VULNERABLE
$result = mysqli_query($conn, $query);
```

- [ ] **3.4** Documentar vulnerabilidad:

```markdown
## Vulnerabilidad Identificada
- **Archivo**: app/controllers/users_controller.py
- **Línea**: 45
- **Tipo**: SQL Injection (concatenación de strings)
- **Parámetro vulnerable**: `id` (query parameter)
- **Severidad**: CRÍTICA (CVSS 9.8)
- **CWE**: CWE-89 (Improper Neutralization of Special Elements in SQL Command)
```

**⏱️ Tiempo estimado**: 8-10 minutos
**✅ Criterio de éxito**: Código vulnerable identificado y documentado

---

### 🛠️ PASO 4: Remediación de Código (25-35 min)
**Objetivo**: Corregir la vulnerabilidad inmediatamente

#### Acciones
- [ ] **4.1** Implementar consultas parametrizadas:

#### ✅ Solución SEGURA - Python (psycopg2/SQLAlchemy)
```python
# Opción 1: psycopg2 (PostgreSQL)
@app.route('/api/users')
def get_user():
    user_id = request.args.get('id')

    # Validar input
    if not user_id.isdigit():
        return jsonify({'error': 'Invalid user ID'}), 400

    # Consulta parametrizada
    query = "SELECT * FROM users WHERE id = %s"
    cursor.execute(query, (user_id,))  # ✅ SEGURO
    return jsonify(cursor.fetchall())

# Opción 2: SQLAlchemy ORM
from sqlalchemy import text

@app.route('/api/users')
def get_user():
    user_id = request.args.get('id', type=int)
    if not user_id:
        return jsonify({'error': 'Invalid user ID'}), 400

    # ORM (más seguro)
    user = db.session.query(User).filter_by(id=user_id).first()
    # O con text() para queries complejas
    result = db.session.execute(
        text("SELECT * FROM users WHERE id = :id"),
        {"id": user_id}
    )
    return jsonify(user.to_dict())
```

#### ✅ Solución SEGURA - Node.js (mysql2/Sequelize)
```javascript
// Opción 1: mysql2 con prepared statements
const mysql = require('mysql2/promise');

app.get('/api/users', async (req, res) => {
  const userId = parseInt(req.query.id);

  if (isNaN(userId)) {
    return res.status(400).json({ error: 'Invalid user ID' });
  }

  // Consulta parametrizada
  const [rows] = await db.execute(
    'SELECT * FROM users WHERE id = ?',
    [userId]  // ✅ SEGURO
  );
  res.json(rows);
});

// Opción 2: Sequelize ORM
const { User } = require('./models');

app.get('/api/users', async (req, res) => {
  const userId = parseInt(req.query.id);

  if (isNaN(userId)) {
    return res.status(400).json({ error: 'Invalid user ID' });
  }

  const user = await User.findByPk(userId);  // ✅ SEGURO
  res.json(user);
});
```

#### ✅ Solución SEGURA - PHP (PDO/MySQLi)
```php
// Opción 1: PDO con prepared statements
$user_id = $_GET['id'];

if (!is_numeric($user_id)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid user ID']);
    exit;
}

// Consulta parametrizada
$stmt = $pdo->prepare('SELECT * FROM users WHERE id = :id');
$stmt->execute(['id' => $user_id]);  // ✅ SEGURO
$user = $stmt->fetch(PDO::FETCH_ASSOC);
echo json_encode($user);

// Opción 2: MySQLi con prepared statements
$stmt = $mysqli->prepare('SELECT * FROM users WHERE id = ?');
$stmt->bind_param('i', $user_id);  // 'i' = integer
$stmt->execute();  // ✅ SEGURO
$result = $stmt->get_result();
```

- [ ] **4.2** Agregar validación de input:

```python
# Validación robusta con biblioteca especializada
from marshmallow import Schema, fields, ValidationError

class UserQuerySchema(Schema):
    id = fields.Int(required=True, strict=True)

@app.route('/api/users')
def get_user():
    try:
        # Validar input
        data = UserQuerySchema().load(request.args)
        user_id = data['id']
    except ValidationError as err:
        return jsonify({'errors': err.messages}), 400

    # Consulta segura
    query = "SELECT * FROM users WHERE id = %s"
    cursor.execute(query, (user_id,))
    return jsonify(cursor.fetchall())
```

- [ ] **4.3** Implementar principio de mínimo privilegio en DB:

```sql
-- Crear usuario de aplicación con permisos limitados
CREATE USER 'app_user'@'%' IDENTIFIED BY 'secure_password';

-- Solo permisos de lectura/escritura (NO DROP, CREATE, ALTER)
GRANT SELECT, INSERT, UPDATE ON app_database.* TO 'app_user'@'%';

-- Revocar permisos peligrosos
REVOKE DROP, CREATE, ALTER, GRANT OPTION ON *.* FROM 'app_user'@'%';

FLUSH PRIVILEGES;
```

- [ ] **4.4** Desplegar fix:

```bash
# Crear branch de hotfix
git checkout -b hotfix/sqli-users-endpoint

# Commit del fix
git add app/controllers/users_controller.py
git commit -m "fix: SQL injection in /api/users endpoint (CWE-89)"

# Push y crear PR urgente
git push origin hotfix/sqli-users-endpoint

# Desplegar inmediatamente (después de code review rápido)
# Opción 1: Kubernetes
kubectl set image deployment/api api=myapp:hotfix-sqli-v1.2.3
kubectl rollout status deployment/api

# Opción 2: AWS ECS
aws ecs update-service \
  --cluster production \
  --service api-service \
  --force-new-deployment

# Opción 3: Heroku
git push heroku hotfix/sqli-users-endpoint:main
```

**⏱️ Tiempo estimado**: 8-10 minutos
**✅ Criterio de éxito**: Fix desplegado en producción

---

### 🔍 PASO 5: Escaneo de Vulnerabilidades Similares (35-45 min)
**Objetivo**: Identificar otros endpoints con el mismo patrón vulnerable

#### Acciones
- [ ] **5.1** Buscar concatenación de SQL en codebase:

```bash
# Buscar patrones vulnerables en Python
grep -rn "f\".*SELECT.*{" app/ --include="*.py"
grep -rn "\".*SELECT.*\" +" app/ --include="*.py"
grep -rn ".format(.*SELECT" app/ --include="*.py"

# Buscar en JavaScript/Node.js
grep -rn "\`SELECT.*\${" app/ --include="*.js"
grep -rn "\"SELECT.*\" +" app/ --include="*.js"

# Buscar en PHP
grep -rn "\$.*SELECT.*\$" app/ --include="*.php"
grep -rn "\"SELECT.*\".*\." app/ --include="*.php"
```

- [ ] **5.2** Ejecutar SAST (Static Application Security Testing):

```bash
# Semgrep (recomendado)
semgrep --config=p/owasp-top-ten --config=p/sql-injection app/

# Bandit (Python)
bandit -r app/ -f json -o bandit-report.json

# NodeJsScan (Node.js)
nodejsscan --directory app/ --output nodejsscan-report.json

# SonarQube (multi-lenguaje)
sonar-scanner \
  -Dsonar.projectKey=my-app \
  -Dsonar.sources=app/ \
  -Dsonar.host.url=http://localhost:9000
```

- [ ] **5.3** Revisar resultados y priorizar:

```markdown
## Vulnerabilidades Adicionales Encontradas

| Archivo | Línea | Endpoint | Severidad | Estado |
|---------|-------|----------|-----------|--------|
| users_controller.py | 45 | /api/users | CRÍTICA | ✅ Corregido |
| products_controller.py | 78 | /api/products | CRÍTICA | 🔴 Pendiente |
| orders_controller.py | 123 | /api/orders | ALTA | 🔴 Pendiente |
| search_controller.py | 56 | /api/search | MEDIA | 🟡 Planificado |
```

- [ ] **5.4** Crear tickets para remediación:

```markdown
# Template de ticket JIRA/GitHub Issue

**Título**: [SECURITY] SQL Injection en /api/products

**Descripción**:
Se detectó vulnerabilidad de SQL Injection en el endpoint `/api/products`.

**Ubicación**: app/controllers/products_controller.py:78

**Código vulnerable**:
\`\`\`python
query = f"SELECT * FROM products WHERE category = {category}"
\`\`\`

**Solución recomendada**:
\`\`\`python
query = "SELECT * FROM products WHERE category = %s"
cursor.execute(query, (category,))
\`\`\`

**Severidad**: CRÍTICA (CVSS 9.8)
**CWE**: CWE-89
**Prioridad**: P0 (fix en <24h)
**Asignado a**: @security-team
```

**⏱️ Tiempo estimado**: 10 minutos
**✅ Criterio de éxito**: Todas las vulnerabilidades similares identificadas y documentadas

---

### 🛡️ PASO 6: Fortalecimiento de Defensas (45-60 min)
**Objetivo**: Implementar controles adicionales para prevenir futuros ataques

#### Acciones
- [ ] **6.1** Configurar WAF con reglas anti-SQLi:

#### AWS WAF
```bash
# Crear regla de SQLi
aws wafv2 create-rule-group \
  --name SQLiProtection \
  --scope REGIONAL \
  --capacity 100 \
  --rules '[
    {
      "Name": "BlockSQLi",
      "Priority": 1,
      "Statement": {
        "SqliMatchStatement": {
          "FieldToMatch": {
            "AllQueryArguments": {}
          },
          "TextTransformations": [
            {
              "Priority": 0,
              "Type": "URL_DECODE"
            },
            {
              "Priority": 1,
              "Type": "HTML_ENTITY_DECODE"
            }
          ]
        }
      },
      "Action": {
        "Block": {}
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "SQLiBlocked"
      }
    }
  ]'
```

#### Cloudflare WAF
```bash
# Habilitar OWASP Core Ruleset
curl -X PATCH "https://api.cloudflare.com/client/v4/zones/{zone_id}/firewall/waf/packages/{package_id}" \
  -H "X-Auth-Email: user@example.com" \
  -H "X-Auth-Key: your-api-key" \
  -H "Content-Type: application/json" \
  --data '{
    "sensitivity": "high",
    "action_mode": "block"
  }'
```

#### ModSecurity (Nginx/Apache)
```nginx
# /etc/nginx/modsec/main.conf
SecRuleEngine On
SecRequestBodyAccess On

# OWASP CRS - SQL Injection Rules
Include /usr/share/modsecurity-crs/rules/REQUEST-942-APPLICATION-ATTACK-SQLI.conf

# Bloquear patrones comunes
SecRule ARGS "@detectSQLi" \
  "id:1001,\
   phase:2,\
   block,\
   log,\
   msg:'SQL Injection Attack Detected'"
```

- [ ] **6.2** Implementar rate limiting en endpoints sensibles:

```python
# Flask-Limiter
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/users')
@limiter.limit("10 per minute")  # Límite estricto para endpoints de búsqueda
def get_user():
    # ...
```

```javascript
// Express-rate-limit (Node.js)
const rateLimit = require('express-rate-limit');

const apiLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minuto
  max: 10, // 10 requests por minuto
  message: 'Too many requests, please try again later.'
});

app.use('/api/', apiLimiter);
```

- [ ] **6.3** Configurar logging y alertas:

```yaml
# Prometheus + Alertmanager
# prometheus-rules.yml
groups:
  - name: security_alerts
    interval: 30s
    rules:
      - alert: SQLiAttackDetected
        expr: rate(waf_blocked_requests{rule="SQLi"}[5m]) > 5
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "SQL Injection attack detected"
          description: "{{ $value }} SQLi attempts blocked in last 5 minutes"
```

```python
# Integración con SIEM (ejemplo: Splunk)
import logging
from splunk_handler import SplunkHandler

splunk = SplunkHandler(
    host='splunk.example.com',
    port=8088,
    token='your-hec-token',
    index='security'
)

logger = logging.getLogger('security')
logger.addHandler(splunk)

# En el código de detección
logger.critical(
    'SQLi attack blocked',
    extra={
        'attacker_ip': '203.0.113.45',
        'endpoint': '/api/users',
        'payload': "id=1' OR '1'='1",
        'timestamp': datetime.utcnow().isoformat()
    }
)
```

- [ ] **6.4** Implementar sanitización de errores:

```python
# NO exponer detalles de errores SQL en producción
import os

@app.errorhandler(Exception)
def handle_error(error):
    # Loggear error completo internamente
    app.logger.error(f"Error: {error}", exc_info=True)

    # Retornar mensaje genérico al usuario
    if os.getenv('FLASK_ENV') == 'production':
        return jsonify({
            'error': 'Internal server error',
            'request_id': request.id  # Para soporte
        }), 500
    else:
        # Solo en desarrollo mostrar detalles
        return jsonify({
            'error': str(error),
            'type': type(error).__name__
        }), 500
```

**⏱️ Tiempo estimado**: 10-15 minutos (configuración inicial)
**✅ Criterio de éxito**: Controles preventivos implementados y probados

---

## 📋 Checklist de Cierre de Incidente

- [ ] IP atacante bloqueada ✅
- [ ] Impacto del ataque analizado ✅
- [ ] Código vulnerable identificado ✅
- [ ] Vulnerabilidad corregida y desplegada ✅
- [ ] Vulnerabilidades similares escaneadas ✅
- [ ] WAF configurado con reglas anti-SQLi ✅
- [ ] Rate limiting implementado ✅
- [ ] Alertas configuradas ✅
- [ ] Post-mortem documentado
- [ ] Equipo capacitado sobre prevención de SQLi
- [ ] Ticket de incidente cerrado

---

## 📝 Plantilla de Post-Mortem

```markdown
# Post-Mortem: Ataque de SQL Injection [FECHA]

## Resumen Ejecutivo
- **Fecha del incidente**: [YYYY-MM-DD HH:MM UTC]
- **Duración**: [X minutos desde detección hasta contención]
- **Severidad**: Crítica
- **Impacto**: [Exitoso/Bloqueado]

## Línea de Tiempo
- **[HH:MM]** - Detección inicial (alerta de WAF)
- **[HH:MM]** - IP atacante bloqueada
- **[HH:MM]** - Análisis de impacto completado
- **[HH:MM]** - Código vulnerable identificado
- **[HH:MM]** - Fix desplegado en producción
- **[HH:MM]** - Escaneo de vulnerabilidades similares completado
- **[HH:MM]** - Incidente cerrado

## Detalles del Ataque
- **IP atacante**: [IP]
- **Endpoint vulnerable**: [/api/endpoint]
- **Payload**: [payload decodificado]
- **Tipo de SQLi**: [Union-based / Boolean-based / Time-based]
- **Éxito del ataque**: [Sí/No]

## Causa Raíz
[Descripción de por qué el código era vulnerable]

## Impacto
- **Datos accedidos**: [Sí/No - Detalles]
- **Datos modificados**: [Sí/No]
- **Autenticación bypasseada**: [Sí/No]
- **Registros afectados**: [número]

## Acciones Correctivas
1. Migrar todos los endpoints a consultas parametrizadas - @dev-team - [Fecha]
2. Implementar SAST en CI/CD pipeline - @security-team - [Fecha]
3. Capacitación sobre secure coding - @all-devs - [Fecha]

## Lecciones Aprendidas
- ✅ **Qué funcionó bien**: [Ej: WAF detectó y bloqueó ataque]
- ❌ **Qué falló**: [Ej: Código no revisado por security antes de deploy]
- 🔄 **Qué mejorar**: [Ej: Agregar SAST obligatorio en CI/CD]
```

---

## 🔗 Referencias y Herramientas

### Herramientas de Detección
- **AWS WAF**: https://aws.amazon.com/waf/
- **Cloudflare WAF**: https://www.cloudflare.com/waf/
- **ModSecurity**: https://github.com/SpiderLabs/ModSecurity
- **OWASP CRS**: https://owasp.org/www-project-modsecurity-core-rule-set/

### Herramientas SAST
- **Semgrep**: https://semgrep.dev/ (recomendado, multi-lenguaje)
- **Bandit**: https://github.com/PyCQA/bandit (Python)
- **NodeJsScan**: https://github.com/ajinabraham/NodeJsScan (Node.js)
- **SonarQube**: https://www.sonarqube.org/

### Guías de Prevención
- **OWASP SQL Injection Prevention Cheat Sheet**: https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
- **OWASP Top 10 - A03:2021 Injection**: https://owasp.org/Top10/A03_2021-Injection/
- **CWE-89**: https://cwe.mitre.org/data/definitions/89.html

### Ejemplos de Código Seguro
- **SQLAlchemy (Python)**: https://docs.sqlalchemy.org/en/14/core/tutorial.html#using-textual-sql
- **Sequelize (Node.js)**: https://sequelize.org/docs/v6/core-concepts/raw-queries/
- **PDO (PHP)**: https://www.php.net/manual/en/pdo.prepared-statements.php

---

## 📞 Contactos de Escalamiento

| Severidad | Contacto | Tiempo de Respuesta |
|-----------|----------|---------------------|
| 🔴 Ataque exitoso (datos comprometidos) | CISO: security@example.com | < 10 min |
| 🟡 Ataque bloqueado (vulnerabilidad confirmada) | Security Lead: security-lead@example.com | < 30 min |
| 🟢 Falso positivo | DevOps Team: devops@example.com | < 1 hora |
