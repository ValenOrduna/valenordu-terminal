#!/usr/bin/env bash
# =============================================================================
#  ValenOrdu Terminal Setup — Installer Linux
#  Instala herramientas via apt/dnf/pacman y copia las configs
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/../configs"
PLUGINS_DIR="$SCRIPT_DIR/../plugins"

# ponytail: backup automático antes de pisar configs existentes
backup_if_exists() { [ -f "$1" ] && cp "$1" "$1.bak.$(date +%s)" && echo "  Backup: $1.bak"; }

echo "  [1/5] Detectando gestor de paquetes..."

install_pkg() {
  if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y "$@"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$@"
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$@"
  elif command -v zypper &>/dev/null; then
    sudo zypper install -y "$@"
  else
    echo "  Gestor de paquetes no soportado. Instala manualmente: $*"
    return 1
  fi
}

echo "  [2/5] Instalando herramientas base..."
install_pkg zsh git curl

echo "  [3/5] Instalando herramientas adicionales..."

# Instalar Cargo (Rust) para herramientas que no estan en todos los repos
if ! command -v cargo &>/dev/null; then
  echo "  Instalando Rust/Cargo..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Herramientas via Cargo (multi-distro)
cargo_install() {
  cargo install "$1" 2>/dev/null || echo "  $1 ya instalado o error, continuando..."
}

cargo_install eza
cargo_install starship
cargo_install zoxide
cargo_install git-delta

# fzf
if ! command -v fzf &>/dev/null; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-bash --no-fish
fi

# bat
install_pkg bat 2>/dev/null || cargo_install bat

# lazygit — descargar binario
if ! command -v lazygit &>/dev/null; then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_$(uname -m).tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
fi

# fastfetch
if ! command -v fastfetch &>/dev/null; then
  curl -Lo /tmp/fastfetch.tar.gz "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$(uname -m).tar.gz"
  tar xf /tmp/fastfetch.tar.gz -C /tmp
  sudo install /tmp/fastfetch/usr/bin/fastfetch /usr/local/bin
fi

# figlet y jq
install_pkg figlet jq 2>/dev/null || echo "  figlet/jq no disponibles, continuando..."

# Plugins de zsh
echo "  [4/5] Instalando plugins de zsh..."

# zsh-autosuggestions
if [ ! -d /usr/local/share/zsh-autosuggestions ] && [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d /usr/local/share/zsh-syntax-highlighting ] && [ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh-syntax-highlighting
fi

echo "  [5/5] Copiando configuraciones..."

mkdir -p ~/.config/{fastfetch,starship,zsh}

backup_if_exists ~/.zshrc
cp "$CONFIGS_DIR/zsh/zshrc" ~/.zshrc

# En Linux, ajustar las rutas de los plugins en .zshrc (brew no existe)
sed -i 's|$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh|~/.zsh-autosuggestions/zsh-autosuggestions.zsh|g' ~/.zshrc
sed -i 's|$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh|g' ~/.zshrc

# Ghostty (opcional — solo si esta instalado)
if command -v ghostty &>/dev/null; then
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

# Git
backup_if_exists ~/.gitconfig
cp "$CONFIGS_DIR/git/gitconfig" ~/.gitconfig

# Plugin zsh-shift-select
cp -r "$PLUGINS_DIR/zsh-shift-select" ~/.config/zsh/

echo "  Listo!"
echo ""
echo "  Reinicia tu terminal para ver los cambios."
echo "  Si zsh no es tu shell por defecto: chsh -s \$(which zsh)"
echo ""
