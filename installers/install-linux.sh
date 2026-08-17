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
# Devuelve 0 aunque el archivo no exista: con set -e, un `return 1` aca
# abortaba el installer en silencio en una maquina limpia.
backup_if_exists() {
  [ -f "$1" ] || return 0
  cp "$1" "$1.bak.$(date +%s)"
  echo "  Backup: $1.bak"
}

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
install_pkg zsh git curl unzip

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

# bat — en Debian/Ubuntu el binario se llama batcat, lo exponemos como bat
install_pkg bat 2>/dev/null || cargo_install bat
if ! command -v bat &>/dev/null && command -v batcat &>/dev/null; then
  mkdir -p ~/.local/bin && ln -sf "$(command -v batcat)" ~/.local/bin/bat
fi

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

# Fuente Maple Mono NF — necesaria para los iconos de eza y starship
if [ ! -f ~/.local/share/fonts/MapleMono-NF-Regular.ttf ]; then
  echo "  Instalando fuente Maple Mono NF..."
  mkdir -p ~/.local/share/fonts
  curl -fsSLo /tmp/maple.zip "https://github.com/subframe7536/Maple-font/releases/latest/download/MapleMono-NF-unhinted.zip" \
    && unzip -oq /tmp/maple.zip -d ~/.local/share/fonts \
    && fc-cache -f >/dev/null 2>&1 \
    || echo "  No se pudo instalar la fuente, instalala a mano desde https://github.com/subframe7536/Maple-font/releases"
fi

# Plugins de zsh
echo "  [4/5] Instalando plugins de zsh..."

# El .zshrc busca cada plugin en /usr/share, /usr/local/share y ~/.<nombre>.
# Solo clonamos si el sistema no lo trae en ninguna de esas rutas.
clone_plugin() {
  for d in "/usr/share/$1" "/usr/local/share/$1" "$HOME/.$1"; do
    [ -f "$d/$1.zsh" ] && { echo "  $1 ya presente en $d"; return; }
  done
  git clone --depth 1 "https://github.com/zsh-users/$1" "$HOME/.$1"
}

clone_plugin zsh-autosuggestions
clone_plugin zsh-syntax-highlighting

echo "  [5/5] Copiando configuraciones..."

mkdir -p ~/.config/{fastfetch,starship,zsh}

backup_if_exists ~/.zshrc
cp "$CONFIGS_DIR/zsh/zshrc" ~/.zshrc

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

echo "  Verificando instalacion..."

faltan=""
for t in starship eza bat delta fzf zoxide fastfetch figlet lazygit jq; do
  command -v "$t" &>/dev/null || faltan="$faltan $t"
done
for f in ~/.zshrc ~/.gitconfig ~/.config/starship.toml ~/.config/fastfetch/config.jsonc; do
  [ -f "$f" ] || faltan="$faltan $f"
done

if [ -n "$faltan" ]; then
  echo ""
  echo "  ATENCION — falto instalar o copiar:$faltan"
  echo "  Volve a correr el installer o instalalo a mano."
else
  echo "  Todo instalado y copiado correctamente."
fi

echo ""
echo "  Reinicia tu terminal para ver los cambios."
echo "  Si zsh no es tu shell por defecto: chsh -s \$(which zsh)"
echo ""
