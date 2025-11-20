# Manual de Hardening  para Servidores Linux (Ubuntu 22.04 LTS)

**Referencia:** T-04 **Versión:** 1.0 (Manual Avanzado / Nivel CIS 2)

**Fuente:** Controles Curados de CIS Benchmark Nivel 2, ISO 27001 y Prácticas DevSecOps de Alto Riesgo. 

**Propósito:** Asegurar la **Confidencialidad, Integridad y Disponibilidad (CID)** del sistema operativo. Este manual se enfoca en la prevención de escalada de privilegios, persistencia y la defensa de la integridad del kernel.

**Instrucción:** Esta es una guía de implementación. Cada control **debe** ser verificado y documentado antes de marcar el estado como [Cumple].

## 1. Gestión de Paquetes y Configuración Base

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-1.1**|**Forzar Actualizaciones Desatendidas**|El sistema debe estar configurado para instalar automáticamente parches de seguridad críticos y notificar al equipo sobre reinicios.|`sudo apt install unattended-upgrades` y verificar la configuración en `/etc/apt/apt.conf.d/50unattended-upgrades`.|[ ]|
|**P-1.2**|**Desinstalar Servicios y Clientes Innecesarios**|Eliminar todo lo que no sea esencial. **Esto incluye herramientas de compilación** (si no es un servidor de desarrollo).|`sudo apt purge telnetd rsh-server talk ypserv bind9 dnsmasq build-essential`|[ ]|
|**P-1.3**|**Configurar NTP/Timesync**|Sincronización horaria precisa (NTP). **CRÍTICO** para la correlación de logs de incidentes y la validez de los JWT.|`timedatectl set-ntp true` y verificar la fuente del servidor NTP.|[ ]|
|**P-1.4**|**Limitar el Acceso al Bootloader (GRUB)**|Asegurar el gestor de arranque con una contraseña para prevenir que un atacante modifique los parámetros del kernel o arranque en modo monousuario.|Configurar una contraseña en `/etc/grub.d/00_header`.|[ ]|

## 2. Permisos del Sistema de Archivos y Montaje

**(Foco en /tmp, /var/log, y opciones de montaje de integridad)**

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-2.1**|**Montaje de /tmp Restrictivo**|**CRÍTICO.** Montar `/tmp` como una partición separada con las opciones de seguridad `nodev` (no dispositivos) y `nosuid` (no SUID), y `noexec` (no ejecución).|Verificar en `/etc/fstab` las opciones `nodev, nosuid, noexec` para `/tmp`.|[ ]|
|**P-2.2**|**Asegurar la Partición /var/log**|Los archivos de log no deben ser modificables por nadie que no sea el sistema de logging.|Establecer permisos estrictos: `sudo chmod 640 /var/log/*` y `sudo chown root:adm /var/log/*`.|[ ]|
|**P-2.3**|**Permisos de `/etc/shadow`**|**CRÍTICO.** El archivo de contraseñas _hasheadas_ debe ser legible **solo** por el usuario `root`.|**Permiso:** `sudo chmod 000 /etc/shadow` y **Propiedad:** `sudo chown root:shadow /etc/shadow`|[ ]|
|**P-2.4**|**Permisos de `/etc/sudoers`**|Solo `root` puede leer/escribir.|**Permiso:** `sudo chmod 440 /etc/sudoers` y **Propiedad:** `sudo chown root:root /etc/sudoers`|[ ]|
|**P-2.5**|**Verificar Archivos SUID/SGID Peligrosos**|Identificar y eliminar/restringir el uso de binarios con permisos SUID/SGID que podrían ser usados para escalada de privilegios.|`find / -type f -perm /6000 -exec ls -l {} \;` (Investigar resultados).|[ ]|

## 3. Seguridad de Acceso Remoto (SSH Hardening Avanzado)

**(Objetivo: Forzar el uso de Zero Trust en el perímetro)**

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-3.1**|**Deshabilitar Login de Root Directo**|**CRÍTICO.** En `/etc/ssh/sshd_config`, establecer `PermitRootLogin no`.|[ ]||
|**P-3.2**|**Autenticación Únicamente por Llave Pública**|**CRÍTICO.** En `/etc/ssh/sshd_config`, establecer `PasswordAuthentication no` y `PubkeyAuthentication yes`.|[ ]||
|**P-3.3**|**Limitar Versiones de Protocolo y Cifrado**|Solo permitir SSHv2. **Restringir algoritmos** a curvas elípticas modernas y hashes fuertes (ej. `aes256-gcm@openssh.com`).|Revisar y restringir `Ciphers` y `Macs` en `/etc/ssh/sshd_config`.|[ ]|
|**P-3.4**|**Timeouts de Sesión y Control de Acceso**|Desconectar sesiones inactivas y limitar el acceso a usuarios específicos.|En `/etc/ssh/sshd_config`, usar `AllowUsers <lista_usuarios>` o `AllowGroups <grupo>` y configurar `ClientAliveInterval`.|[ ]|
|**P-3.5**|**Deshabilitar Reenvío de X11 y Túneles**|Prevenir el uso del servidor como pivote para ataques de red interna.|En `/etc/ssh/sshd_config`, establecer `X11Forwarding no` y `AllowTcpForwarding no`.|[ ]|

## 4. Kernel (`sysctl`) y Control de Acceso Obligatorio (MAC)

**(Foco: Prevención de ataques de red, DoS, y defensa de la integridad del sistema)**

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-4.1**|**Hardening del Kernel (`sysctl` Core)**|Deshabilitar _Source Routing_, activar _Reverse Path Filtering_ (`net.ipv4.conf.all.rp_filter = 1`) y configurar `syncookies` (DoS).|Revisar `/etc/sysctl.conf` para la configuración de `net.ipv4.conf.all` y `net.ipv4.tcp_syncookies`.|[ ]|
|**P-4.2**|**Restringir Redireccionamiento de ICMP**|Prevenir ataques _Man-in-the-Middle_ y _Routing_ malicioso.|En `/etc/sysctl.conf`, establecer `net.ipv4.conf.all.send_redirects = 0`.|[ ]|
|**P-4.3**|**Implementación de AppArmor**|**CRÍTICO (MAC).** Asegurar que AppArmor (o SELinux) esté instalado, habilitado y con perfiles de cumplimiento activos para servicios críticos (ej. Nginx, bases de datos).|Verificar estado con `aa-status` y asegurar que los perfiles estén en modo **enforce**.|[ ]|
|**P-4.4**|**Verificación de Módulos (Blacklisting)**|Deshabilitar módulos de kernel innecesarios o peligrosos (ej. `dccp`, `sctp`) que podrían ser usados como vectores de ataque.|Configurar _blacklist_ en `/etc/modprobe.d/blacklist.conf`.|[ ]|

## 5. Firewall, Logging y Auditoría (`Auditd`)

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-5.1**|**Instalar y Habilitar `Auditd`**|**CRÍTICO.** Habilitar el sistema de auditoría del kernel para registrar eventos críticos del sistema que `rsyslog` no captura.|`sudo apt install auditd` y verificar estado.|[ ]|
|**P-5.2**|**Reglas de Auditoría de Archivos Críticos**|Definir reglas de auditoría para monitorear intentos de acceso/modificación a `/etc/passwd`, `/etc/shadow`, `/etc/sudoers` y binarios SUID/SGID.|Configurar reglas en `/etc/audit/rules.d/`.|[ ]|
|**P-5.3**|**Logging Centralizado y `Fail2Ban`**|Asegurar que todos los logs sean enviados a un colector central (SIEM/CloudWatch). `Fail2Ban` debe estar configurado para proteger SSH, webserver, y aplicaciones críticas.|Verificar configuración de _forwarding_ en `rsyslog` y la activación de `jails` en `fail2ban`.|[ ]|
|**P-5.4**|**Restringir Logs de Auditoría**|Los archivos de log de `auditd` y `rsyslog` deben ser solo legibles por `root` y gestionados con la máxima restricción.|Verificar permisos de `/var/log/audit/` y `/var/log/`.|[ ]|

## 6. Gestión de Usuarios, PAM y Autenticación

**(Foco en la calidad de la contraseña y la sesión)**

|ID|Control|Requisito Mínimo y Razón (Rationale)|Verificación|Estado|
|---|---|---|---|---|
|**P-6.1**|**Configurar Requisitos de Calidad de Contraseña (PAM)**|Usar `pam_pwquality` para forzar longitud mínima (ej. 14 caracteres), mezcla de caracteres y bloqueo de secuencias simples.|Ajustar `/etc/security/pwquality.conf`.|[ ]|
|**P-6.2**|**Bloqueo de Cuenta (`faillock`)**|Configurar el sistema para bloquear automáticamente cuentas después de 3 a 5 intentos de login fallidos.|Configurar `/etc/security/faillock.conf` y verificar en `/etc/pam.d/common-auth`.|[ ]|
|**P-6.3**|**Configurar Bloqueo de Sesión (PAM)**|Limitar el tiempo de inactividad de la sesión de consola/TTY para forzar el reingreso de la contraseña o la reconexión SSH.|Configurar `/etc/profile` o usar módulos PAM de sesión.|[ ]|
|**P-6.4**|**Revisar Cuentas Huérfanas y Compartidas**|**CRÍTICO.** Eliminar o bloquear cuentas que ya no están en uso. Asegurar que no existan cuentas de servicio compartidas entre personas.|**Comando:** Auditoría de usuarios con `lastlog` y `chage -l <user>`.|[ ]|
|**P-6.5**|**Limitar Uso de Sudo**|Asegurar que solo los usuarios estrictamente necesarios estén en el grupo `sudo` o puedan usar el binario.|Revisar la membresía del grupo `sudo` y las reglas en `/etc/sudoers.d/`.|[ ]|

**Conclusión:** Este documento es ahora un **Manual de Hardening Nivel 2**. Utiliza terminología técnica precisa (`AppArmor`, `sysctl`, `faillock`, `pwquality`) y está diseñado para ser implementado por un ingeniero de alto nivel en un entorno Fintech.
