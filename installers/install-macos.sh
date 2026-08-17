#!/usr/bin/env bash
# =============================================================================
#  ValenOrdu Terminal Setup — Installer macOS
#  Instala todas las herramientas via Homebrew y copia las configs
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/../configs"
PLUGINS_DIR="$SCRIPT_DIR/../plugins"

# ponytail: backup automático antes de pisar configs existentes
backup_if_exists() { [ -f "$1" ] && cp "$1" "$1.bak.$(date +%s)" && echo "  Backup: $1.bak"; }

echo "  [1/5] Verificando Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "  Instalando Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "  [2/5] Instalando herramientas..."
BREW_PACKAGES=(
  zsh                # shell
  starship           # prompt con rama git
  zoxide             # cd inteligente
  fzf                # busqueda difusa (Ctrl+R, Ctrl+T)
  zsh-autosuggestions
  zsh-syntax-highlighting
  fastfetch          # system info al abrir terminal
  figlet             # arte ASCII para el nombre 3D
  lazygit            # TUI para git
  eza                # ls con colores e iconos
  bat                # cat con syntax highlighting
  git-delta          # diffs con colores lado a lado
  gh                 # GitHub CLI
  jq                 # procesar JSON en terminal
)
brew install "${BREW_PACKAGES[@]}"

echo "  [3/5] Instalando Ghostty y la fuente Maple Mono NF..."
brew install --cask ghostty 2>/dev/null || echo "  Ghostty ya instalado o no disponible, continuando..."
brew install --cask font-maple-mono-nf 2>/dev/null || echo "  Fuente ya instalada o no disponible, continuando..."

echo "  [4/5] Copiando configuraciones..."

# Crear directorios
mkdir -p ~/.config/{fastfetch,starship,zsh}

# zshrc
backup_if_exists ~/.zshrc
cp "$CONFIGS_DIR/zsh/zshrc" ~/.zshrc

# Ghostty (opcional — solo si esta instalado)
if command -v ghostty &>/dev/null || [ -d /Applications/Ghostty.app ]; then
  mkdir -p ~/.config/ghostty
  backup_if_exists ~/.config/ghostty/config
  cp "$CONFIGS_DIR/ghostty/config" ~/.config/ghostty/config
  echo "  Ghostty detectado — config copiada"
else
  echo "  Ghostty no instalado — saltando config (opcional)"
fi

# Fastfetch
backup_if_exists ~/.config/fastfetch/config.jsonc
cp "$CONFIGS_DIR/fastfetch/config.jsonc" ~/.config/fastfetch/config.jsonc
backup_if_exists ~/.config/fastfetch/logo.txt
cp "$CONFIGS_DIR/fastfetch/logo.txt" ~/.config/fastfetch/logo.txt

# Starship
backup_if_exists ~/.config/starship.toml
cp "$CONFIGS_DIR/starship/starship.toml" ~/.config/starship.toml

# Git config
backup_if_exists ~/.gitconfig
cp "$CONFIGS_DIR/git/gitconfig" ~/.gitconfig

# Plugin zsh-shift-select
cp -r "$PLUGINS_DIR/zsh-shift-select" ~/.config/zsh/

echo "  [5/5] Listo!"
echo ""
echo "  Reinicia tu terminal (o Ghostty) para ver los cambios."
echo "  Si zsh no es tu shell por defecto: chsh -s \$(which zsh)"
echo ""
