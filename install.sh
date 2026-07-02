#!/usr/bin/env bash
# =============================================================================
#  ValenOrdu Terminal Setup — Installer Universal
#  Detecta el OS y ejecuta el installer correspondiente
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "  ╔═══════════════════════════════════════════════╗"
echo "  ║     ValenOrdu Terminal Setup — Installer      ║"
echo "  ╚═══════════════════════════════════════════════╝"
echo ""

# Detectar OS
OS="$(uname -s)"
case "$OS" in
  Darwin)
    echo "  OS detectado: macOS"
    echo ""
    exec bash "$SCRIPT_DIR/installers/install-macos.sh"
    ;;
  Linux)
    echo "  OS detectado: Linux"
    echo ""
    exec bash "$SCRIPT_DIR/installers/install-linux.sh"
    ;;
  *)
    echo "  OS no soportado: $OS"
    echo "  En Windows ejecuta: powershell -ExecutionPolicy Bypass -File installers\install-windows.ps1"
    exit 1
    ;;
esac
