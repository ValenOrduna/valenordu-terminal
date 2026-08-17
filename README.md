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
| `gs` | git status | Estado del repo |
| `gc` | git commit | Commit |
| `gp` | git push | Push |
| `gd` | git diff | Ver cambios |
| `gco` | git checkout | Cambiar rama |
| `gb` | git branch | Listar ramas |
| `gl` | git log --oneline | Historial compacto |
| `ls` | eza --icons --git | Listado con iconos |
| `ll` | eza -lh | Listado largo |
| `la` | eza -lah | Listado con ocultos |
| `lt` | eza --tree | Arbol de directorios |
| `cat` | bat | Cat con colores |
| `..` | cd .. | Subir un nivel |
| `...` | cd ../.. | Subir dos niveles |
| `cl` | claude | Claude CLI |
| `co` | codex | Codex CLI |
| `op` | opencode | Opencode CLI |
| `ports` | lsof -i -P -n | Ver puertos en uso |
| `path` | echo $PATH | PATH legible |
| `myip` | curl ifconfig.me | IP publica |
| `sitiohoy` | — | Bootstrap del toolkit SitioHoy |

### Funciones
| Funcion | Que hace |
|---------|----------|
| `mkcd <dir>` | Crea directorio y entra |
| `valenfetch` | Nombre 3D + system info |

### Fuente
- **Maple Mono NF** — redondeada, moderna, con Nerd Font para iconos

### Config de Ghostty
- Fuente Maple Mono NF size 15 con font-thicken (mejor render Retina)
- Cursor bar sin parpadeo
- Transparencia 92% + blur
- Padding 12px x 8px
- Copy-on-select al clipboard
- Mouse se oculta al escribir
- Cierre sin confirmacion
- Ventanas recuerdan estado
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
├── LICENSE                    <- MIT
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
- **macOS** — requiere Homebrew (se instala solo si no lo tenes). Instala tambien Ghostty y la fuente Maple Mono NF.
- **Linux** — detecta apt/dnf/pacman/zypper. Ghostty no se instala automaticamente: si lo tenes, la config se copia; si no, ese paso se saltea.
- **Windows** — usa Scoop y configura **PowerShell, no zsh** (no hay Ghostty ni plugins de zsh). Los aliases y el prompt son equivalentes.
- La fuente Maple Mono NF se instala en las tres plataformas. Despues de instalar hay que **seleccionarla en el terminal** (Ghostty ya viene configurado; en Windows Terminal se elige a mano en Settings > Appearance > Font face).
- El installer hace backup automatico de tus configs existentes antes de pisarlas (`archivo.bak.<timestamp>`).
- El `.zshrc` corre `valenfetch` al abrir cada terminal (limpia la pantalla y muestra el logo). Para desactivarlo, borra la ultima linea del archivo.

## Creditos
- [zsh-shift-select](https://github.com/jirutka/zsh-shift-select) — incluido en `plugins/` (licencia MIT, ver `plugins/zsh-shift-select/LICENSE`).

## Licencia
MIT — ver [LICENSE](LICENSE).
