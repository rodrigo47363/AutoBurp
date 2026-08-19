#!/usr/bin/env bash
# ==============================================================================
# Autor: Rodrigo (rodrigo47363)
# Email: rodrigovil@proton.me
# Repositorio: https://github.com/rodrigo47363/autoburp
# Descripción: Despliegue Automatizado e Idempotente de Burp Suite (Rosetta Gateway)
# ==============================================================================

set -euo pipefail

# Constantes del sistema
INSTALL_DIR="/opt/BurpSuite"
BIN_PATH="/usr/local/bin/burpsuite"
DESKTOP_FILE="/usr/share/applications/burpsuite.desktop"
TMP_INSTALLER=$(mktemp /tmp/burp_installer_XXXXXX.sh)

# Máscara de red legítima para atravesar el WAF de AWS CloudFront
U_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"

# Limpieza segura de archivos temporales al salir o tras interrupción
cleanup() {
    rm -f "$TMP_INSTALLER" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# Verificación de privilegios de superusuario
check_root() {
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then
        echo -e "\e[31m[!] Error: Esta operación exige privilegios de superusuario: sudo ./$0\e[0m"
        exit 1
    fi
}

# Autodetección dinámica de arquitectura de CPU
detect_arch() {
    local arch
    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            echo "Linux"
            ;;
        aarch64|arm64)
            echo "LinuxArm64"
            ;;
        *)
            echo -e "\e[31m[!] Error: Arquitectura no soportada: $arch\e[0m" >&2
            exit 1
            ;;
    esac
}

# Desinstalación limpia e idempotente
uninstall() {
    check_root
    echo -e "\e[34m[*] Desinstalando Burp Suite del sistema...\e[0m"

    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        echo -e "\e[33m[-] Directorio $INSTALL_DIR eliminado.\e[0m"
    fi

    if [ -L "$BIN_PATH" ] || [ -f "$BIN_PATH" ]; then
        rm -f "$BIN_PATH"
        echo -e "\e[33m[-] Enlace binario $BIN_PATH eliminado.\e[0m"
    fi

    if [ -f "$DESKTOP_FILE" ]; then
        rm -f "$DESKTOP_FILE"
        echo -e "\e[33m[-] Entrada de escritorio $DESKTOP_FILE eliminada.\e[0m"
    fi

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi

    echo -e "\e[32m[+] ¡Desinstalación completada con éxito! El sistema ha quedado limpio.\e[0m"
    exit 0
}

# Flujo principal de instalación y actualización
install() {
    check_root
    local os_type
    os_type=$(detect_arch)

    echo -e "\e[34m[*] Interrogando el DOM de PortSwigger para extraer la versión en producción...\e[0m"

    local burp_version
    burp_version=$(curl -s -A "$U_AGENT" "https://portswigger.net/burp/downloads" | grep -oP 'id="CurrentVersion".*?value="\K[^"]+' || true)

    if [ -z "$burp_version" ]; then
        echo -e "\e[31m[!] Fallo de aserción: No se pudo capturar la versión del DOM.\e[0m"
        exit 1
    fi

    echo -e "\e[32m[+] Versión unificada detectada: v$burp_version ($os_type)\e[0m"

    # EL SANTO GRIAL DESCUBIERTO POR RODRIGO: product=desktop
    # Al invocar "desktop", el backend omite el Login Wall, genera la URL de Amazon CloudFront 
    # firmada con el token criptográfico temporal y nos avienta hacia ella vía HTTP 302.
    local front_door_url="https://portswigger.net/burp/releases/download?product=desktop&version=${burp_version}&type=${os_type}"

    echo -e "\e[34m[*] Solicitando token de descarga a la Puerta Principal y siguiendo redirección 302...\e[0m"
    curl -L --progress-bar -A "$U_AGENT" -o "$TMP_INSTALLER" "$front_door_url"

    # Guardián de integridad Cero-Especulación
    if ! file "$TMP_INSTALLER" | grep -q "executable"; then
        echo -e "\e[31m[!] DENEGACIÓN DE PASE: El archivo resultante no es un binario ejecutable.\e[0m"
        echo -e "\e[33m[*] Volcado de las primeras 10 líneas de la respuesta:\e[0m"
        head -n 10 "$TMP_INSTALLER"
        exit 1
    fi

    chmod +x "$TMP_INSTALLER"

    echo -e "\e[34m[*] Ejecutando instalador nativo silencioso en $INSTALL_DIR...\e[0m"
    "$TMP_INSTALLER" -q -dir "$INSTALL_DIR"

    echo -e "\e[34m[*] Planchando enlace simbólico en el PATH global del sistema ($BIN_PATH)...\e[0m"
    ln -sf "$INSTALL_DIR/BurpSuite" "$BIN_PATH"
    chmod +x "$INSTALL_DIR/BurpSuite"

    # Autodetección dinámica de icono
    local icon_path
    icon_path=$(find "$INSTALL_DIR" -maxdepth 2 -name "*burp*.png" 2>/dev/null | head -n 1 || true)
    [ -z "$icon_path" ] && icon_path="burpsuite"

    echo -e "\e[34m[*] Compilando Desktop Entry optimizado para Rofi / dmenu / GNOME / KDE...\e[0m"
    cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Name=Burp Suite
Exec=/bin/bash -c "cd $INSTALL_DIR && ./BurpSuite > /dev/null 2>&1"
Icon=$icon_path
Type=Application
Categories=Security;Development;Network;
Terminal=false
EOF

    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database /usr/share/applications/ 2>/dev/null || true
    fi

    echo -e "\e[32m[+] ¡HA SIDO INSTALADO CON ÉXITO! Burp Suite v$burp_version ($os_type) está operativo.\e[0m"
}

# Menú de ayuda
show_help() {
    cat <<EOF
AutoBurp - Despliegue Automatizado e Idempotente de Burp Suite

Uso:
  sudo ./autoburp.sh             Instalar o actualizar a la versión más reciente
  sudo ./autoburp.sh --uninstall Desinstalar Burp Suite y limpiar el sistema
  ./autoburp.sh --help           Mostrar este mensaje de ayuda
  ./autoburp.sh --version        Consultar la versión disponible en PortSwigger

Opciones:
  -u, --uninstall   Elimina /opt/BurpSuite, enlaces simbólicos y entradas .desktop
  -v, --version     Consulta y muestra la última versión de Burp Suite sin instalar
  -h, --help        Muestra esta información
EOF
}

# Consulta rápida de versión
check_version_only() {
    echo -e "\e[34m[*] Consultando última versión oficial...\e[0m"
    local burp_version
    burp_version=$(curl -s -A "$U_AGENT" "https://portswigger.net/burp/downloads" | grep -oP 'id="CurrentVersion".*?value="\K[^"]+' || true)
    if [ -n "$burp_version" ]; then
        echo -e "\e[32m[+] Última versión disponible: v$burp_version ($(detect_arch))\e[0m"
    else
        echo -e "\e[31m[!] No se pudo determinar la versión remota.\e[0m"
        exit 1
    fi
}

# Enrutamiento de banderas CLI
case "${1:-}" in
    --uninstall|-u)
        uninstall
        ;;
    --version|-v)
        check_version_only
        ;;
    --help|-h)
        show_help
        ;;
    "")
        install
        ;;
    *)
        echo -e "\e[31m[!] Opción no reconocida: $1\e[0m"
        show_help
        exit 1
        ;;
esac
