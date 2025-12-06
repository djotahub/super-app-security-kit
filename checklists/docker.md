# Manual Técnico de Hardening para Contenedores Docker

 **Versión:** 1.0 (Borrador Sprint 2) 
 
 **Base Normativa:** CIS Docker Benchmark v1.3.0, ISO/IEC 27001 (A.8.27), NIST SP 800-190. **Propósito:** Reducir la superficie de ataque de las imágenes y contenedores. Establecer el principio de **Mínimo Privilegio** y **Defensa en Profundidad** para el ambiente de ejecución.

## 1. Seguridad de la Imagen (Build-Time Hardening)

El _hardening_ comienza en el `Dockerfile`, asegurando que la imagen final sea lo más pequeña y menos privilegiada posible.

|ID|Control|Justificación Técnica|Verificación Dockerfile|Estado|
|---|---|---|---|---|
|**I-1.1**|**Usuario No-Root**|**CRÍTICO.** El proceso principal de la aplicación **nunca** debe ejecutarse como `root` dentro del contenedor. Esto previene la escalada de privilegios en el host.|Verificar el uso de la instrucción `USER` con un ID numérico (ej. `USER 1000`).|[ ]|
|**I-1.2**|**Imágenes Base Mínimas**|Utilizar imágenes base minimalistas (ej. `Distroless`, `Alpine`) o _runtime_ de contenedores ligeros. Esto reduce drásticamente el número de paquetes, binarios y CVEs.|Verificar que `FROM` apunte a una imagen con un número mínimo de bibliotecas (ej. Python `slim` o `alpine`).|[ ]|
|**I-1.3**|**Multi-Stage Builds**|Utilizar la compilación en múltiples etapas para asegurar que las herramientas de _build_ (compiladores, dependencias de desarrollo, claves SSH) **no** se incluyan en la imagen de producción final.|Verificar la existencia de `FROM builder AS production`.|[ ]|
|**I-1.4**|**Escaneo de Vulnerabilidades (SCA)**|La imagen final debe ser escaneada durante el CI/CD (Ver T-13) y no debe contener vulnerabilidades **Críticas** o **Altas** conocidas en las capas del SO.|Tarea de integración: El escaneo SCA (Trivy/Dependency-Check) debe pasar.|[ ]|
|**I-1.5**|**Etiquetas y Metadatos**|La imagen debe tener etiquetas informativas (`LABEL`) que especifiquen el contacto, la versión y la fecha de construcción.|Verificar `LABEL maintainer="<email>"`.|[ ]|

## 2. Seguridad del Contenedor (Runtime Security)

Estos controles se aplican al comando de ejecución (`docker run` o manifiesto de Kubernetes) para limitar las capacidades del contenedor en el host.

|ID|Control|Justificación Técnica|Configuración Ejecución|Estado|
|---|---|---|---|---|
|**R-2.1**|**Sistema de Archivos de Solo Lectura**|**CRÍTICO.** Montar el _filesystem_ principal como de solo lectura (`read-only`) para prevenir que el atacante escriba nuevos binarios o modifique el sistema de la aplicación para persistencia.|`docker run --read-only` o `readOnlyRootFilesystem: true` (K8s).|[ ]|
|**R-2.2**|**Eliminar Capabilities (CAP_DROP)**|**CRÍTICO.** Eliminar todas las capacidades de Linux que la aplicación no requiera. El _default_ de Docker es muy permisivo. `NET_RAW` y `SYS_ADMIN` son de alto riesgo.|`docker run --cap-drop ALL --cap-add NET_BIND_SERVICE`.|[ ]|
|**R-2.3**|**Límites de Recursos y DoS**|Definir límites de CPU y Memoria (RAM) para mitigar ataques de Denegación de Servicio (DoS) y asegurar que un contenedor defectuoso no comprometa la disponibilidad del host.|`docker run --memory` y `--cpus`.|[ ]|
|**R-2.4**|**Evitar Montaje de Sockets del Docker (DIND)**|El socket del Docker Host (`/var/run/docker.sock`) **nunca** debe ser montado dentro de un contenedor. Esto permite al atacante tomar control del host.|Auditar `volume mounts` para evitar `/var/run/docker.sock`.|[ ]|
|**R-2.5**|**Control de Acceso Obligatorio (MAC)**|Utilizar perfiles de seguridad como **AppArmor** o **seccomp** para restringir las llamadas al sistema (syscalls) que el contenedor puede hacer.|`docker run --security-opt seccomp=unconfined`.|[ ]|
|**R-2.6**|**Gestión Segura de Registries**|Utilizar firmas de imagen (Notary, Content Trust) para verificar que las imágenes provienen de una fuente confiable y no han sido alteradas.|Habilitar `DOCKER_CONTENT_TRUST=1`.|[ ]|

## 3. Seguridad del Host Docker y Motor (Daemon)

El host que ejecuta el Docker Daemon es el perímetro final de defensa y debe ser tratado con el mismo rigor que un servidor de producción.

|ID|Control|Justificación Técnica|Comando / Archivo de Config.|Estado|
|---|---|---|---|---|
|**H-3.1**|**Monitoreo de Logs Centralizado**|**CRÍTICO.** El Docker Daemon y los contenedores deben configurarse para enviar logs a un colector central (SIEM, CloudWatch) en lugar de almacenarlos solo localmente (requerido por A.5.12).|Configurar el _driver_ de _logging_ (`log-driver`) del Daemon a `json-file` o un _driver_ remoto (ej. `syslog`).|[ ]|
|**H-3.2**|**Restricción de Directorios**|Los directorios de configuración de Docker (`/var/lib/docker`) deben tener permisos estrictos (`root:root`) y solo ser accesibles por `root`.|Verificar `sudo chown root:root /var/lib/docker`.|[ ]|
|**H-3.3**|**Hardening del Host**|El sistema operativo anfitrión (Host OS) debe aplicar el Hardening de Linux definido en la tarea T-04 (SSH, Firewall, Permisos).|Tarea Cruzada: Verificar el cumplimiento de `checklists/linux-hardening.md`.|[ ]|
|**H-3.4**|**Restricción del Grupo Docker**|**CRÍTICO.** El grupo `docker` no debe contener usuarios que no sean de confianza, ya que otorga privilegios equivalentes a `root`.|Verificar usuarios en el grupo `docker` con `getent group docker`.|[ ]|
|**H-3.5**|**Uso de TLS para el Daemon**|El acceso remoto al Docker Daemon debe ser cifrado con TLS.|Configurar `tlsverify`, `tlscert`, y `tlskey` en la configuración del Daemon.|


**Auditor (Revisión Final):** **___** **Fecha de Revisión:** **___**
