# ValenOrdu Terminal Setup

Configuracion completa de terminal con Ghostty + zsh, lista para instalar en macOS, Linux o Windows.

## Que incluye

### Herramientas
| Herramienta | Reemplaza | Para que sirve |
|-------------|-----------|----------------|
| **starship** | prompt | Muestra rama git, estado, lenguaje en el prompt |
| **lazygit** | git CLI | TUI para git (ramas, commits, diffs, stash) |
| **eza** | ls | Listado con colores, iconos y estado de git |
| **bat** | cat | Cat con syntax highlighting |
| **delta** | git diff | Diffs lado a lado con colores |
| **fzf** | — | Busqueda difusa (Ctrl+R historial, Ctrl+T archivos) |
| **zoxide** | cd | cd inteligente que recuerda directorios frecuentes |
| **fastfetch** | neofetch | System info al abrir terminal |
| **figlet** | — | Arte ASCII del nombre "ValenOrdu" en 3D |
| **gh** | — | GitHub CLI (PRs, issues, releases) |
| **jq** | — | Procesar JSON en terminal |

### Plugins de zsh
- **zsh-autosuggestions** — sugerencias en gris del historial (aceptar con →)
- **zsh-syntax-highlighting** — resaltado de sintaxis (verde = ok, rojo = error)
- **zsh-shift-select** — seleccionar texto con shift+flechas
- **compinit** — autocompletado con menu navegable

### Aliases
| Alias | Comando | Que hace |
|-------|---------|----------|
| `lg` | lazygit | TUI de git |
| `ls` | eza --icons --git | Listado con iconos |
| `ll` | eza -lh | Listado largo |
| `la` | eza -lah | Listado con ocultos |
| `lt` | eza --tree | Arbol de directorios |
| `cat` | bat | Cat con colores |
| `cl` | claude | Claude CLI |
| `co` | codex | Codex CLI |
| `op` | opencode | Opencode CLI |

### Fuente
- **Maple Mono NF** — redondeada, moderna, con Nerd Font para iconos

### Config de Ghostty
- Fuente Maple Mono NF size 15
- Transparencia 92% + blur
- Padding 12px x 8px
- Keybindings: Cmd+R reload, Cmd+Z undo, Cmd+Shift+Z redo, etc.

## Instalacion

### macOS
```bash
cd valenordu-terminal
chmod +x install.sh
./install.sh
```

### Linux
```bash
cd valenordu-terminal
chmod +x install.sh
./install.sh
```

### Windows (PowerShell como administrador)
```powershell
cd valenordu-terminal
powershell -ExecutionPolicy Bypass -File installers\install-windows.ps1
```

## Estructura
```
valenordu-terminal/
├── README.md                  <- este archivo
├── install.sh                 <- installer universal (detecta OS)
├── configs/
│   ├── ghostty/
│   │   └── config             <- config de Ghostty
│   ├── zsh/
│   │   └── zshrc              <- config de zsh con aliases y plugins
│   ├── fastfetch/
│   │   ├── config.jsonc       <- config de fastfetch
│   │   └── logo.txt           <- logo ASCII ValenOrdu
│   ├── starship/
│   │   └── starship.toml      <- config del prompt
│   └── git/
│       └── gitconfig          <- config de git con delta
├── plugins/
│   └── zsh-shift-select/      <- plugin para seleccionar texto
└── installers/
    ├── install-macos.sh       <- installer macOS (Homebrew)
    ├── install-linux.sh       <- installer Linux (apt/dnf/pacman)
    └── install-windows.ps1    <- installer Windows (Scoop + PowerShell)
```

## Notas
- En macOS requiere Homebrew. Se instala automaticamente si no lo tenes.
- En Linux detecta apt/dnf/pacman/zypper automaticamente.
- En Windows usa Scoop y configura PowerShell (no zsh).
- El installer hace backup automático de configs existentes antes de pisar (archivo.bak.<timestamp>).
