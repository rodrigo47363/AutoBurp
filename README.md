# AutoBurp

![Bash](https://img.shields.io/badge/Language-Bash-blue?logo=gnu-bash)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)

**AutoBurp** es una utilidad de despliegue automatizada, idempotente y de alta eficiencia diseñada para el despliegue optimizado de **Burp Suite** en entornos Linux. El script agiliza el flujo de trabajo al interactuar directamente con la infraestructura de descarga oficial de PortSwigger, eliminando la fricción de los formularios de registro repetitivos.

## 🛠️ Requisitos previos

Para garantizar una ejecución exitosa, asegúrate de contar con las siguientes dependencias instaladas en tu sistema:

* **Bash** (Versión 4.0 o superior)
* **curl**: Para la comunicación HTTP/HTTPS.
* **sed / grep**: Para el procesamiento de texto y scraping del DOM.
* **ca-certificates**: Para la validación de certificados SSL.

**Instalación de dependencias (Debian/Kali/Parrot):**

```bash
sudo apt update && sudo apt install -y curl sed grep ca-certificates

```

## 🚀 Instalación y Uso

```bash
# Clonar el repositorio
git clone [https://github.com/rodrigo47363/autoburp](https://github.com/rodrigo47363/autoburp)
cd autoburp

# Configurar permisos
chmod +x autoburp.sh

# Ejecución (requiere privilegios root para despliegue en /opt)
sudo ./autoburp.sh

```

## 📋 Especificaciones Técnicas

| Módulo | Tecnología / Técnica |
| --- | --- |
| **Parsing** | RegEx PCRE (`\K`) para extracción atómica de versiones. |
| **Bypass WAF** | Spoofing de `User-Agent` y gestión de redirecciones 302. |
| **Integración** | Generación de `.desktop` compatible con XDG. |
| **Idempotencia** | Reemplazo atómico mediante enlaces simbólicos (`ln -sf`). |

## 🛡️ Notas de Seguridad y Ética

AutoBurp automatiza la descarga de los binarios **oficiales** directamente desde los servidores de PortSwigger.

* **Integridad:** No se modifican los binarios ni se utilizan fuentes de terceros.
* **Propósito:** Esta herramienta ha sido desarrollada estrictamente para facilitar la configuración de entornos de auditoría, optimizando tiempos de despliegue en entornos de pruebas de penetración o laboratorios de seguridad.

---

## 📜 Licencia y Contacto

Proyecto distribuido bajo licencia MIT. Se fomenta la contribución para soporte de arquitecturas adicionales.

**Autor:** Rodrigo Vil

**Contacto:** [rodrigovil@proton.me](mailto:rodrigovil@proton.me)

**Repositorio:** [github.com/rodrigo47363/autoburp](https://github.com/rodrigo47363/autoburp)

---
