# AutoBurp

![Bash](https://img.shields.io/badge/Language-Bash-blue?logo=gnu-bash)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![Architecture](https://img.shields.io/badge/Arch-x86__64%20%7C%20ARM64-orange)

**AutoBurp** es una utilidad de despliegue automatizada, idempotente y de alta eficiencia diseñada para la instalación y actualización continua de **Burp Suite** en entornos Linux. El script agiliza el flujo de trabajo al interactuar directamente con la infraestructura de descarga oficial de PortSwigger, eliminando la fricción de los formularios de registro y tokens manuales.

---

## 🛠️ Requisitos previos

Para garantizar una ejecución exitosa, asegúrate de contar con las siguientes dependencias instaladas en tu sistema:

* **Bash** (Versión 4.0 o superior)
* **curl**: Para la comunicación HTTP/HTTPS y seguimiento de redirecciones 302.
* **grep**: Con soporte PCRE (`-P`) para scraping del DOM.
* **file**: Para la validación del binario descargado.
* **ca-certificates**: Para la validación de certificados SSL.

**Instalación de dependencias (Debian / Ubuntu / Kali / Parrot):**

```bash
sudo apt update && sudo apt install -y curl grep file ca-certificates
```

**Instalación de dependencias (Arch / Manjaro):**

```bash
sudo pacman -Sy --noconfirm curl grep file ca-certificates
```

---

## 🚀 Instalación y Uso

```bash
# 1. Clonar el repositorio
git clone https://github.com/rodrigo47363/AutoBurp.git
cd AutoBurp

# 2. Asignar permisos de ejecución
chmod +x autoburp.sh

# 3. Instalación / Actualización (requiere privilegios root)
sudo ./autoburp.sh
```

---

## 📖 Opciones y Comandos

| Comando | Descripción | Requiere Root |
| --- | --- | :---: |
| `sudo ./autoburp.sh` | Descarga e instala/actualiza Burp Suite a la versión más reciente en producción. | Sí |
| `sudo ./autoburp.sh --uninstall` | Desinstalación limpia e idempotente (`/opt/BurpSuite`, symlinks y `.desktop`). | Sí |
| `./autoburp.sh --version` | Consulta la última versión disponible en PortSwigger sin instalar. | No |
| `./autoburp.sh --help` | Muestra el menú de ayuda y opciones disponibles. | No |

---

## 📋 Especificaciones Técnicas

| Módulo | Tecnología / Técnica | Detalle |
| --- | --- | --- |
| **Parsing** | RegEx PCRE (`\K`) | Extracción atómica de la versión desde el DOM de PortSwigger. |
| **Bypass WAF & Login** | Endpoint `product=desktop` | Solicitud directa con User-Agent legítimo para resolver redirección 302 hacia CloudFront. |
| **Multi-Arquitectura** | Autodetección de CPU | Soporte nativo para `x86_64` (`Linux`) y `aarch64` / `arm64` (`LinuxArm64`). |
| **Shell Defensivo** | `set -euo pipefail` + `trap` | Manejo seguro de errores y limpieza automática de temporales en `/tmp/`. |
| **Integración XDG** | Desktop Entry estándar | Compatibilidad inmediata con Rofi, dmenu, GNOME, KDE, XFCE y terminal (`/usr/local/bin/burpsuite`). |
| **Idempotencia** | Reemplazo atómico | Instalación silenciosa `-q` y enlaces `ln -sf` seguros para upgrades continuos. |

---

## 🛡️ Notas de Seguridad y Ética

AutoBurp automatiza la descarga de los binarios **oficiales** directamente desde la CDN de PortSwigger.

* **Integridad:** No se modifican los binarios ni se utilizan mirrors o fuentes no oficiales de terceros.
* **Propósito:** Esta herramienta ha sido desarrollada para optimizar los tiempos de aprovisionamiento en laboratorios de auditoría, pruebas de penetración y entornos educativos de ciberseguridad.

---

## 📜 Licencia y Contacto

Proyecto distribuido bajo la **Licencia MIT**.

* **Autor:** Rodrigo (rodrigo47363)
* **Contacto:** [rodrigovil@proton.me](mailto:rodrigovil@proton.me)
* **Repositorio:** [github.com/rodrigo47363/AutoBurp](https://github.com/rodrigo47363/AutoBurp)
