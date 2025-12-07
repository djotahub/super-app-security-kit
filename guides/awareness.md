#  Guía de Concientización en Ciberseguridad

**"Human Firewall": Protegiendo nuestra organización juntos**

---

##  Tabla de Contenidos

1.  Introducción y Cultura de Seguridad
2.  Phishing: El arte del engaño masivo
3.  Spear Phishing: Cuando el ataque es personal
4.  Ingeniería Social: Hackeando a la persona
5.  Buenas Prácticas de Contraseñas y Accesos
6.  Procedimiento de Reporte de Incidentes
7.  Glosario Básico para No-Técnicos

---

## 1. Introducción: El "Factor Humano" 

### ¿Por qué leer esta guía?

En el mundo digital actual, la tecnología de seguridad (antivirus, firewalls) es muy avanzada y difícil de romper. Por eso, los ciberdelincuentes han cambiado de estrategia: ya no atacan a las máquinas, atacan a las **personas**.

Tú eres la primera y la última línea de defensa. Esta guía no busca convertirte en un técnico informático, sino darte las herramientas para detectar cuándo alguien intenta manipularte.

### Nuestra Cultura de Seguridad (No Punitiva)

Queremos dejar algo muy claro: **En esta empresa no castigamos el error honesto, castigamos el silencio.**

- Si haces clic en un enlace sospechoso por error: **Avísanos.**
- Si crees que diste tu contraseña: **Avísanos.**

El tiempo es oro. Un reporte rápido nos permite detener un ataque en minutos. Ocultar el error por miedo puede causar daños durante meses. Estamos aquí para ayudarte, no para regañarte.

---

## 2. Phishing: La Pesca con Red 🎣

El Phishing es el intento de engañar a un gran número de usuarios para que revelen información confidencial. Se llama así ("fishing" o pesca) porque lanzan el mismo anzuelo a miles de personas esperando que alguien pique.

### Anatomía de un correo de Phishing

Para que el engaño funcione, los atacantes usan trucos psicológicos:

1.  **Miedo o Urgencia:** _"Tu cuenta será eliminada en 24 horas"_, _"Tienes una deuda pendiente"_. Buscan que entres en pánico y actúes sin pensar.
2.  **Deseo o Recompensa:** _"Ganaste un iPhone"_, _"Bono salarial disponible"_. Si parece demasiado bueno para ser verdad, es mentira.
3.  **Curiosidad:** _"Mira las fotos de la fiesta"_, _"Factura adjunta" (cuando no compraste nada)_.

### Ejemplo Visual

Imagina recibir un correo de "Soporte Técnico":

> _"Detectamos actividad inusual. Haga clic aquí para verificar su identidad o perderá el acceso."_

Si pasas el mouse sobre el enlace (sin hacer clic), verás que la dirección no es `empresa.com`, sino algo como `empresa-seguridad-verify.net`. **Eso es una estafa.**

---

## 3. Spear Phishing: El Arpón Dirigido 

A diferencia del Phishing masivo, el **Spear Phishing** es un ataque personalizado. El atacante ha investigado a su víctima (probablemente usando LinkedIn o redes sociales).

### El escenario del "Fraude del CEO"

Este es el caso más común y peligroso en empresas como la nuestra:

- **El Correo:** Recibes un email que _parece_ venir del CEO o de un Director.
- **El Mensaje:** _"Hola [Tu Nombre], estoy en una reunión confidencial y no puedo hablar. Necesito que hagas una transferencia urgente a este proveedor para cerrar un trato. Hazlo ya, confío en ti."_
- **La Trampa:** Usan la autoridad de un jefe para que no te atrevas a cuestionar la orden.

### ¿Cómo defenderte?

Siempre verifica por un **canal alternativo**.

- Si recibes un correo urgente de dinero o datos sensibles, **llama por teléfono** o escribe por WhatsApp/Slack a esa persona.
- Pregunta: _"¿Me acabas de enviar un correo pidiendo una transferencia?"_.
- El 99% de las veces te dirán: _"No, yo no fui"_.

---

## 4. Ingeniería Social y Vishing 

Los ataques no solo llegan por correo.

- **Vishing (Voice Phishing):** Llamadas telefónicas. _"Hola, soy de soporte de Microsoft, tu computadora tiene un virus, dame acceso remoto para arreglarlo"_. **Soporte nunca te llamará sin que tú abras un ticket primero.**
- **Smishing (SMS Phishing):** Mensajes de texto. _"Tu paquete de Amazon no se pudo entregar, clic aquí"_.

**Regla de Oro:** Ningún departamento de TI, Banco o RRHH te pedirá jamás tu contraseña por teléfono o correo.

---

## 5. Tus Llaves Digitales: Contraseñas y MFA 

Si el Phishing es el ladrón intentando entrar, tu contraseña es la llave de la puerta.

### Evita las contraseñas débiles

- ❌ `123456`, `password`, `empresa2023`
- ❌ Nombres de hijos, mascotas o fechas de nacimiento (son datos públicos en tus redes sociales).

### Usa "Frases de Contraseña" (Passphrases)

Son más fáciles de recordar y más difíciles de hackear. Une 3 o 4 palabras aleatorias:

- ✅ `Caballo-Bateria-Grapa-Correcto`
- ✅ `Café.Mañana.Lluvia.Azul!`

### El "Escudo Extra": MFA (Autenticación Multifactor)

El MFA es ese código que te llega al celular o a una App (como Google Authenticator) después de poner tu contraseña.

- **Nunca** compartas ese código con nadie.
- Si te llega un código MFA sin que tú estés intentando entrar: **Alguien tiene tu contraseña.** Reportalo inmediatamente.

---

## 6. Procedimiento de Reporte Interno 

Detectar el ataque es un éxito. Reportarlo es la victoria.

### Paso 1: No interactúes

- No respondas al remitente.
- No hagas clic en enlaces ni descargues adjuntos.
- No reenvíes el correo a compañeros.

### Paso 2: Reporta

Reenvía el correo sospechoso como archivo adjunto (si es posible) a nuestro equipo de seguridad:
 **[CORREO-DE-SEGURIDAD@TU-EMPRESA.COM]**

### Paso 3: Verifica y Borra

Si tienes dudas sobre si es real, contacta al remitente por otro medio oficial (teléfono interno). Una vez confirmado que es Phishing y reportado, **elimínalo definitivamente**.

---

## 7. Glosario para No-Técnicos 

- **Malware:** Cualquier programa malicioso (virus, troyanos) diseñado para dañar tu equipo.
- **Ransomware:** Un tipo de virus que "secuestra" tus archivos y pide un rescate (dinero) para devolverlos.
- **Spoofing:** Suplantación de identidad. Hacer que un correo parezca venir de `jefe@empresa.com` cuando en realidad viene de otro lado.
- **VPN:** Red privada virtual. Un túnel seguro para trabajar desde casa como si estuvieras en la oficina.

---

**Gracias por ser parte de nuestra seguridad.**
_Departamento de TI / Seguridad de la Información_
