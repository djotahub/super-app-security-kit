# Playbook: Filtración de Credenciales (Credential Leak)

## 🚨 Descripción del Incidente
**Tipo**: Exposición de credenciales (API keys, tokens, contraseñas, certificados)
**Severidad**: 🔴 CRÍTICA
**Tiempo objetivo de respuesta**: < 15 minutos
**Tiempo objetivo de contención**: < 30 minutos

---

## ⚡ Pasos de Respuesta Inmediata (Atomic)

> **IMPORTANTE**: Cada paso debe completarse en **5-10 minutos máximo**. Si un paso toma más tiempo, escalar inmediatamente.

---

### 🔴 PASO 1: Revocación Inmediata de Credenciales (0-5 min)
**Objetivo**: Invalidar la credencial comprometida ANTES de investigar

#### Acciones
- [ ] **1.1** Identificar el tipo de credencial comprometida:
  - [ ] API Key de servicio externo (Stripe, Twilio, AWS, etc.)
  - [ ] Token de acceso (JWT, OAuth token)
  - [ ] Contraseña de usuario/admin
  - [ ] Certificado privado (SSL/TLS, SSH key)
  - [ ] Database credentials

- [ ] **1.2** Revocar/rotar credencial según tipo:

#### Para API Keys de Servicios Externos
```bash
# AWS
aws iam delete-access-key --access-key-id AKIA... --user-name service-account

# Stripe
curl https://api.stripe.com/v1/api_keys/sk_live_XXX \
  -u sk_live_XXX: \
  -X DELETE

# GitHub
# Ir a: Settings > Developer settings > Personal access tokens > Revoke
```

#### Para Tokens JWT/OAuth
```bash
# Agregar token a blacklist en Redis
redis-cli SADD token_blacklist "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# O invalidar todas las sesiones del usuario
redis-cli DEL "user:sessions:{user_id}"
```

#### Para Contraseñas de Usuario
```sql
-- Forzar cambio de contraseña en próximo login
UPDATE users
SET password_reset_required = TRUE,
    password_reset_token = gen_random_uuid(),
    updated_at = NOW()
WHERE id = {user_id};

-- Invalidar sesiones activas
DELETE FROM user_sessions WHERE user_id = {user_id};
```

#### Para Database Credentials
```sql
-- PostgreSQL
DROP USER IF EXISTS compromised_user;
CREATE USER new_user WITH PASSWORD 'new_secure_password';
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO new_user;

-- MySQL
DROP USER 'compromised_user'@'%';
CREATE USER 'new_user'@'%' IDENTIFIED BY 'new_secure_password';
GRANT SELECT, INSERT, UPDATE ON database.* TO 'new_user'@'%';
FLUSH PRIVILEGES;
```

#### Para Certificados/SSH Keys
```bash
# Revocar certificado SSL
openssl ca -revoke /path/to/compromised-cert.pem -config openssl.cnf

# Eliminar SSH key autorizada
ssh user@server "sed -i '/AAAAB3NzaC1yc2EAAA.../d' ~/.ssh/authorized_keys"
```

- [ ] **1.3** Verificar revocación exitosa:
```bash
# Intentar usar la credencial revocada (debe fallar)
curl -H "Authorization: Bearer REVOKED_TOKEN" https://api.example.com/test
# Esperado: 401 Unauthorized
```

- [ ] **1.4** Notificar a equipo en Slack/Teams:
```
🚨 CREDENTIAL LEAK - REVOCACIÓN COMPLETADA
Tipo: [API Key / Token / Password]
Servicio: [AWS / Stripe / Database]
Revocada: ✅ [timestamp]
Investigación en curso...
```

**⏱️ Tiempo estimado**: 3-5 minutos
**✅ Criterio de éxito**: Credencial revocada y verificada como inválida

---

### 🔍 PASO 2: Identificación de la Fuente de Exposición (5-15 min)
**Objetivo**: Determinar DÓNDE y CÓMO se filtró la credencial

#### Acciones
- [ ] **2.1** Revisar alertas de herramientas de detección:

```bash
# GitHub Secret Scanning
# Ir a: Repository > Security > Secret scanning alerts

# GitGuardian
# Revisar dashboard: https://dashboard.gitguardian.com/alerts

# TruffleHog (si se ejecuta en CI/CD)
grep -r "CREDENTIAL_LEAK" /var/log/ci-cd/
```

- [ ] **2.2** Buscar en repositorios de código:

```bash
# Buscar en historial de Git (incluso commits eliminados)
git log --all --full-history --source --find-object=<credencial>

# Buscar en todos los branches
git grep -i "AKIA" $(git rev-list --all)

# Buscar en archivos de configuración comunes
find . -type f \( -name ".env*" -o -name "config*.yml" -o -name "secrets*" \) \
  -exec grep -l "AKIA\|sk_live\|ghp_" {} \;
```

- [ ] **2.3** Revisar logs de aplicación:

```bash
# Buscar en logs de aplicación (últimas 24h)
grep -i "api.key\|token\|password" /var/log/app/*.log | tail -100

# Buscar en logs de error (pueden contener stack traces con credenciales)
grep -i "exception\|error" /var/log/app/error.log | grep -i "key\|token"

# CloudWatch Logs (AWS)
aws logs filter-log-events \
  --log-group-name /aws/lambda/my-function \
  --filter-pattern "AKIA" \
  --start-time $(date -d '24 hours ago' +%s)000
```

- [ ] **2.4** Revisar repositorios públicos:

```bash
# Buscar en GitHub público
# Ir a: https://github.com/search?q=AKIA[primeros_caracteres]&type=code

# Buscar en Pastebin/Gist
curl "https://pste.io/api/search?q=AKIA[primeros_caracteres]"
```

- [ ] **2.5** Documentar hallazgos:
```markdown
## Fuente de Exposición Identificada
- **Ubicación**: [GitHub repo / Logs / Pastebin]
- **Archivo**: [path/to/file.js]
- **Commit**: [hash del commit]
- **Fecha de exposición**: [timestamp]
- **Visibilidad**: [Pública / Interna / Privada]
- **Tiempo expuesto**: [X horas/días]
```

**⏱️ Tiempo estimado**: 5-10 minutos
**✅ Criterio de éxito**: Fuente de exposición identificada y documentada

---

### 🧹 PASO 3: Eliminación de Credencial Expuesta (15-25 min)
**Objetivo**: Remover la credencial de TODOS los lugares donde esté expuesta

#### Acciones
- [ ] **3.1** Eliminar de repositorio Git (si aplica):

```bash
# Opción 1: BFG Repo-Cleaner (recomendado, más rápido)
bfg --replace-text passwords.txt my-repo.git
cd my-repo.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# Opción 2: git-filter-repo
git filter-repo --replace-text <(echo "AKIA1234567890ABCDEF==>REDACTED")

# Opción 3: git filter-branch (legacy)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Forzar push (CUIDADO: reescribe historial)
git push origin --force --all
git push origin --force --tags
```

- [ ] **3.2** Eliminar de logs:

```bash
# Redactar credencial en logs existentes
sed -i 's/AKIA[A-Z0-9]\{16\}/REDACTED/g' /var/log/app/*.log

# Rotar logs inmediatamente
logrotate -f /etc/logrotate.d/app

# CloudWatch: No se puede editar, pero se puede eliminar log stream
aws logs delete-log-stream \
  --log-group-name /aws/lambda/my-function \
  --log-stream-name compromised-stream
```

- [ ] **3.3** Eliminar de repositorios públicos:

```bash
# GitHub: Contactar a GitHub Support para purgar caché
# Formulario: https://support.github.com/contact

# Pastebin: Reportar paste
curl -X POST https://pastebin.com/api/api_post.php \
  -d "api_dev_key=YOUR_KEY" \
  -d "api_option=delete" \
  -d "api_paste_key=PASTE_ID"
```

- [ ] **3.4** Verificar eliminación:

```bash
# Buscar nuevamente en Git
git grep -i "AKIA" $(git rev-list --all) || echo "✅ No encontrado"

# Buscar en logs
grep -r "AKIA" /var/log/app/ || echo "✅ No encontrado"
```

**⏱️ Tiempo estimado**: 8-10 minutos
**✅ Criterio de éxito**: Credencial eliminada de todas las fuentes identificadas

---

### 🔐 PASO 4: Generación y Despliegue de Nueva Credencial (25-35 min)
**Objetivo**: Restaurar funcionalidad del servicio con credencial segura

#### Acciones
- [ ] **4.1** Generar nueva credencial segura:

```bash
# API Key aleatoria (32 caracteres)
openssl rand -base64 32

# Password seguro (20 caracteres)
openssl rand -base64 20 | tr -d "=+/" | cut -c1-20

# AWS Access Key (crear nueva)
aws iam create-access-key --user-name service-account

# SSH Key
ssh-keygen -t ed25519 -C "service-account@example.com" -f ~/.ssh/new_key
```

- [ ] **4.2** Almacenar en gestor de secretos:

```bash
# AWS Secrets Manager
aws secretsmanager create-secret \
  --name prod/api/stripe-key \
  --secret-string "sk_live_NEW_KEY_HERE"

# HashiCorp Vault
vault kv put secret/prod/stripe api_key="sk_live_NEW_KEY_HERE"

# GCP Secret Manager
echo -n "sk_live_NEW_KEY_HERE" | gcloud secrets create stripe-api-key --data-file=-
```

- [ ] **4.3** Actualizar aplicación:

```bash
# Actualizar variable de entorno en Kubernetes
kubectl set env deployment/my-app STRIPE_API_KEY="sk_live_NEW_KEY_HERE"

# Actualizar en AWS ECS
aws ecs update-service \
  --cluster my-cluster \
  --service my-service \
  --force-new-deployment

# Actualizar en Heroku
heroku config:set STRIPE_API_KEY="sk_live_NEW_KEY_HERE" -a my-app
```

- [ ] **4.4** Verificar funcionalidad:

```bash
# Probar endpoint que usa la nueva credencial
curl -X POST https://api.example.com/test \
  -H "Authorization: Bearer NEW_TOKEN" \
  -d '{"test": true}'

# Revisar logs de aplicación
tail -f /var/log/app/app.log | grep -i "stripe\|api"
```

**⏱️ Tiempo estimado**: 8-10 minutos
**✅ Criterio de éxito**: Nueva credencial desplegada y funcional

---

### 📊 PASO 5: Análisis de Impacto (35-45 min)
**Objetivo**: Determinar si la credencial fue usada maliciosamente

#### Acciones
- [ ] **5.1** Revisar logs de acceso del servicio comprometido:

```bash
# AWS CloudTrail (para Access Keys)
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=AccessKeyId,AttributeValue=AKIA... \
  --start-time $(date -d '7 days ago' --iso-8601) \
  --max-results 100

# Stripe API logs
curl https://api.stripe.com/v1/events \
  -u sk_live_NEW_KEY: \
  -d limit=100 \
  -d type="request.*"

# GitHub Audit Log
# Ir a: Organization > Settings > Audit log
# Filtrar por: action:oauth_access.create
```

- [ ] **5.2** Buscar actividad anómala:

```markdown
## Indicadores de Compromiso
- [ ] Accesos desde IPs desconocidas
- [ ] Accesos fuera de horario laboral
- [ ] Volumen de requests inusual
- [ ] Operaciones no autorizadas (ej: creación de usuarios, modificación de permisos)
- [ ] Exfiltración de datos (queries masivas, exports)
```

- [ ] **5.3** Cuantificar impacto:

```markdown
## Impacto Estimado
- **Datos accedidos**: [Sí/No] - [Tipo de datos]
- **Datos modificados**: [Sí/No] - [Descripción]
- **Costo financiero**: $[monto] (ej: llamadas API no autorizadas)
- **Usuarios afectados**: [número]
- **Tiempo de exposición**: [X horas/días]
- **Uso malicioso detectado**: [Sí/No]
```

**⏱️ Tiempo estimado**: 10 minutos
**✅ Criterio de éxito**: Impacto cuantificado y documentado

---

### 🛡️ PASO 6: Prevención de Recurrencia (45-60 min)
**Objetivo**: Implementar controles para evitar futuras filtraciones

#### Acciones
- [ ] **6.1** Implementar detección automática:

```yaml
# GitHub Secret Scanning (habilitar)
# Ir a: Repository > Settings > Security > Secret scanning
# Activar: "Secret scanning" y "Push protection"

# Pre-commit hook con detect-secrets
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
```

```bash
# Instalar pre-commit hook
pip install pre-commit detect-secrets
detect-secrets scan > .secrets.baseline
pre-commit install
```

- [ ] **6.2** Configurar alertas:

```bash
# GitGuardian (SaaS)
# Integrar con: https://dashboard.gitguardian.com/

# TruffleHog en CI/CD
# .github/workflows/secrets-scan.yml
name: Secrets Scan
on: [push, pull_request]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: ${{ github.event.repository.default_branch }}
          head: HEAD
```

- [ ] **6.3** Rotar credenciales proactivamente:

```bash
# Crear script de rotación automática (ejemplo AWS)
# rotate-keys.sh
#!/bin/bash
USER="service-account"
OLD_KEY=$(aws iam list-access-keys --user-name $USER --query 'AccessKeyMetadata[0].AccessKeyId' --output text)
NEW_KEY=$(aws iam create-access-key --user-name $USER --query 'AccessKey.AccessKeyId' --output text)

# Actualizar en Secrets Manager
aws secretsmanager update-secret --secret-id prod/aws/access-key --secret-string "$NEW_KEY"

# Esperar despliegue (5 min)
sleep 300

# Eliminar clave antigua
aws iam delete-access-key --user-name $USER --access-key-id $OLD_KEY

echo "✅ Rotación completada: $OLD_KEY -> $NEW_KEY"
```

- [ ] **6.4** Capacitar al equipo:

```markdown
## Acciones de Capacitación
- [ ] Enviar post-mortem a todo el equipo de desarrollo
- [ ] Programar sesión de 30 min sobre "Manejo seguro de secretos"
- [ ] Actualizar documentación de onboarding con mejores prácticas
- [ ] Agregar checklist de seguridad en template de PR
```

**⏱️ Tiempo estimado**: 10-15 minutos (configuración inicial)
**✅ Criterio de éxito**: Controles preventivos implementados

---

## 📋 Checklist de Cierre de Incidente

- [ ] Credencial comprometida revocada ✅
- [ ] Fuente de exposición identificada ✅
- [ ] Credencial eliminada de todas las ubicaciones ✅
- [ ] Nueva credencial generada y desplegada ✅
- [ ] Análisis de impacto completado ✅
- [ ] Controles preventivos implementados ✅
- [ ] Post-mortem documentado (ver plantilla abajo)
- [ ] Notificación a stakeholders enviada
- [ ] Ticket de incidente cerrado en JIRA/ServiceNow

---

## 📝 Plantilla de Post-Mortem

```markdown
# Post-Mortem: Filtración de Credencial [FECHA]

## Resumen Ejecutivo
- **Fecha del incidente**: [YYYY-MM-DD HH:MM UTC]
- **Duración**: [X horas desde detección hasta resolución]
- **Severidad**: Crítica
- **Impacto**: [Descripción breve]

## Línea de Tiempo
- **[HH:MM]** - Detección inicial (alerta de GitHub Secret Scanning)
- **[HH:MM]** - Revocación de credencial completada
- **[HH:MM]** - Fuente identificada (commit abc123 en repo X)
- **[HH:MM]** - Credencial eliminada del historial de Git
- **[HH:MM]** - Nueva credencial desplegada
- **[HH:MM]** - Análisis de impacto completado
- **[HH:MM]** - Incidente cerrado

## Causa Raíz
[Descripción detallada de cómo ocurrió la filtración]

## Impacto
- **Datos comprometidos**: [Sí/No - Detalles]
- **Uso malicioso detectado**: [Sí/No]
- **Costo estimado**: $[monto]
- **Usuarios afectados**: [número]

## Acciones Correctivas
1. [Acción 1] - Responsable: [Nombre] - Fecha límite: [YYYY-MM-DD]
2. [Acción 2] - Responsable: [Nombre] - Fecha límite: [YYYY-MM-DD]

## Lecciones Aprendidas
- ✅ **Qué funcionó bien**: [Ej: Detección automática funcionó en <5 min]
- ❌ **Qué falló**: [Ej: No teníamos pre-commit hooks]
- 🔄 **Qué mejorar**: [Ej: Automatizar rotación de credenciales]
```

---

## 🔗 Referencias y Herramientas

### Herramientas de Detección
- **GitHub Secret Scanning**: https://docs.github.com/en/code-security/secret-scanning
- **GitGuardian**: https://www.gitguardian.com/
- **TruffleHog**: https://github.com/trufflesecurity/trufflehog
- **detect-secrets**: https://github.com/Yelp/detect-secrets

### Herramientas de Limpieza
- **BFG Repo-Cleaner**: https://rtyley.github.io/bfg-repo-cleaner/
- **git-filter-repo**: https://github.com/newren/git-filter-repo

### Gestores de Secretos
- **AWS Secrets Manager**: https://aws.amazon.com/secrets-manager/
- **HashiCorp Vault**: https://www.vaultproject.io/
- **GCP Secret Manager**: https://cloud.google.com/secret-manager
- **Azure Key Vault**: https://azure.microsoft.com/en-us/services/key-vault/

### Guías de Referencia
- **OWASP Secrets Management Cheat Sheet**: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- **NIST SP 800-57**: Key Management Guidelines

---

## 📞 Contactos de Escalamiento

| Severidad | Contacto | Tiempo de Respuesta |
|-----------|----------|---------------------|
| 🔴 Crítica | CISO: security@example.com | < 15 min |
| 🟡 Alta | Security Lead: security-lead@example.com | < 30 min |
| 🟢 Media | DevOps Team: devops@example.com | < 1 hora |
