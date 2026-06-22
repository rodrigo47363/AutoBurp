# AutoBurp

**AutoBurp** es una utilidad de despliegue automatizado, idempotente y de alta eficiencia diseñada para instalar la versión unificada de **Burp Suite** en sistemas Linux, evadiendo las restricciones de marketing y los portales de autenticación de PortSwigger.

## 🛠️ ¿Cómo funciona?

El script utiliza una técnica de **omisión de lógica de negocio**. Al identificar el parámetro `product=desktop` en las rutas de descarga, el servidor backend omite el formulario de registro (Login Wall) y entrega directamente la URL firmada de Amazon CloudFront.

1. **Reconocimiento:** Scraping dinámico del DOM para detectar la versión actual (`CurrentVersion`).
2. **Infiltración:** Solicitud HTTP con `User-Agent` de navegador legítimo para evadir restricciones de bot-detection (AWS WAF).
3. **Despliegue:** Instalación desatendida, cumplimiento FHS (Filesystem Hierarchy Standard) y creación de atajos de escritorio integrados.

## 🚀 Instalación rápida

1. **Clona el repositorio:**
```bash
git clone https://github.com/rodrigo47363/autoburp
cd autoburp

```


2. **Otorga permisos de ejecución:**
```bash
chmod +x autoburp.sh

```


3. **Ejecuta con privilegios elevados:**
```bash
sudo ./autoburp.sh

```



## 📋 Especificaciones Técnicas

| Módulo | Tecnología / Técnica |
| --- | --- |
| **Parsing** | RegEx PCRE (`\K`) para extracción atómica de versiones. |
| **Bypass WAF** | Spoofing de `User-Agent` y gestión de redirecciones 302. |
| **Integración** | Generación dinámica de `burpsuite.desktop` para Rofi/dmenu. |
| **Idempotencia** | Reemplazo seguro mediante `ln -sf` y actualización de caché de iconos. |

## 🛡️ Notas de Seguridad

Este script automatiza la descarga **oficial** desde los servidores de PortSwigger. No altera el binario original ni utiliza fuentes de terceros. El script está diseñado para ahorrar tiempo en entornos de auditoría, evitando la fricción de los formularios de registro repetitivos.

---

## 📜 Licencia

Este proyecto se distribuye bajo licencia de código abierto. Siéntete libre de contribuir o adaptar el script para otras arquitecturas (ARM64, etc.).

**Autor:** Rodrigo
**Contacto:** [rodrigovil@proton.me](https://www.google.com/search?q=mailto%3Arodrigovil%40proton.me)
**Repositorio:** [https://github.com/rodrigo47363/autoburp](https://github.com/rodrigo47363/autoburp)

---

*Hecho para pentesters, por pentesters.*
