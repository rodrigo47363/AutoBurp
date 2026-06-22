#!/bin/bash
# ==============================================================================
# Autor: Rodrigo (rodrigo47363)
# Email: rodrigovil@proton.me
# Repositorio: https://github.com/rodrigo47363/autoburp
# Descripción: Despliegue Automatizado e Idempotente de Burp Suite (Rosetta Gateway)
# ==============================================================================

set -e

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31m[!] Error: Este script exige privilegios de superusuario: sudo ./$0\e[0m"
    exit 1
fi

INSTALL_DIR="/opt/BurpSuite"
BIN_PATH="/usr/local/bin/burpsuite"
DESKTOP_FILE="/usr/share/applications/burpsuite.desktop"
TMP_INSTALLER="/tmp/burp_installer.sh"

# Máscara de red legítima para atravesar el WAF de AWS CloudFront
U_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"

echo -e "\e[34m[*] Interrogando el DOM de PortSwigger para extraer la versión en producción...\e[0m"

BURP_VERSION=$(curl -s -A "$U_AGENT" "https://portswigger.net/burp/downloads" | grep -oP 'id="CurrentVersion".*?value="\K[^"]+')

if [ -z "$BURP_VERSION" ]; then
    echo -e "\e[31m[!] Fallo de aserción: No se pudo capturar la versión del DOM.\e[0m"
    exit 1
fi

echo -e "\e[32m[+] Versión unificada detectada: $BURP_VERSION\e[0m"

# EL SANTO GRIAL DESCUBIERTO POR RODRIGO: product=desktop
# Al invocar "desktop", el backend omite el Login Wall, genera la URL de Amazon CloudFront 
# firmada con el token criptográfico temporal y nos avienta hacia ella vía HTTP 302.
FRONT_DOOR_URL="https://portswigger.net/burp/releases/download?product=desktop&version=${BURP_VERSION}&type=Linux"

echo -e "\e[34m[*] Solicitando token de descarga a la Puerta Principal y siguiendo redirección 302...\e[0m"
curl -L --progress-bar -A "$U_AGENT" -o "$TMP_INSTALLER" "$FRONT_DOOR_URL"

# Guardián de integridad Cero-Especulación
if ! file "$TMP_INSTALLER" | grep -q "executable"; then
    echo -e "\e[31m[!] DENEGACIÓN DE PASE: El archivo resultante no es un binario.\e[0m"
    echo -e "\e[33m[*] Volcado de las primeras 10 líneas de la respuesta:\e[0m"
    head -n 10 "$TMP_INSTALLER"
    exit 1
fi

chmod +x "$TMP_INSTALLER"

echo -e "\e[34m[*] Ejecutando instalador nativo silencioso en $INSTALL_DIR...\e[0m"
"$TMP_INSTALLER" -q -dir "$INSTALL_DIR"
rm -f "$TMP_INSTALLER"

echo -e "\e[34m[*] Planchando enlace simbólico en el PATH global del sistema...\e[0m"
ln -sf "$INSTALL_DIR/BurpSuite" "$BIN_PATH"
chmod +x "$INSTALL_DIR/BurpSuite"

# Autodetección dinámica de icono
ICON_PATH=$(find "$INSTALL_DIR" -name "*burp*.png" 2>/dev/null | head -n 1)
[ -z "$ICON_PATH" ] && ICON_PATH="burpsuite"

echo -e "\e[34m[*] Compilando Desktop Entry optimizado para Rofi / dmenu...\e[0m"
cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Burp Suite
Exec=/bin/bash -c "cd $INSTALL_DIR && ./BurpSuite > /dev/null 2>&1"
Icon=$ICON_PATH
Type=Application
Categories=Security;Development;Network;
Terminal=false
EOF

update-desktop-database /usr/share/applications/

echo -e "\e[32m[+] ¡HA SIDO INSTALADO CON ÉXITO! Burp Suite v$BURP_VERSION (Unified) está operativo.\e[0m"
