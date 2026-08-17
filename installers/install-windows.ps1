# =============================================================================
#  ValenOrdu Terminal Setup — Installer Windows (PowerShell)
#  Instala herramientas via Scoop y copia las configs
#  Ejecutar como administrador: powershell -ExecutionPolicy Bypass -File installers\install-windows.ps1
# =============================================================================
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigsDir = Join-Path $ScriptDir "..\configs"

# ponytail: backup automático antes de pisar configs existentes
function Backup-IfExists($path) {
    if (Test-Path $path) {
        $bak = "$path.bak.$([math]::Floor((Get-Date -UFormat %s)))"
        Copy-Item $path $bak -Force
        Write-Host "  Backup: $bak"
    }
}

Write-Host ""
Write-Host "  ==========================================="
Write-Host "   ValenOrdu Terminal Setup — Windows"
Write-Host "  ==========================================="
Write-Host ""

# -----------------------------------------------------------------------------
# [1/5] Instalar Scoop (gestor de paquetes para terminal)
# -----------------------------------------------------------------------------
Write-Host "  [1/5] Verificando Scoop..."
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "  Instalando Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# -----------------------------------------------------------------------------
# [2/5] Instalar herramientas
# -----------------------------------------------------------------------------
Write-Host "  [2/5] Instalando herramientas..."

# lazygit vive en el bucket "extras" y la fuente en "nerd-fonts"
scoop bucket add extras 2>$null | Out-Null
scoop bucket add nerd-fonts 2>$null | Out-Null

$scoopPackages = @(
    "git",           # Git
    "starship",      # Prompt con rama git
    "zoxide",        # cd inteligente
    "fzf",           # Busqueda difusa
    "lazygit",       # TUI para git
    "eza",           # ls con colores e iconos
    "bat",           # cat con syntax highlighting
    "delta",         # diffs con colores
    "gh",            # GitHub CLI
    "jq",            # Procesar JSON
    "fastfetch",     # System info
    "figlet"         # Arte ASCII
)

foreach ($pkg in $scoopPackages) {
    Write-Host "    Instalando $pkg..."
    try { scoop install $pkg 2>$null | Out-Null }
    catch { Write-Host "    $pkg fallo o ya estaba instalado, continuando..." }
}

# Fuente Maple Mono NF — necesaria para los iconos de eza y starship
Write-Host "    Instalando fuente Maple Mono NF..."
try { scoop install Maple-Mono-NF 2>$null | Out-Null }
catch { Write-Host "    Fuente no instalada, bajala de https://github.com/subframe7536/Maple-font/releases" }

# -----------------------------------------------------------------------------
# [3/5] Configurar PowerShell (PSReadLine para autocompletado)
# -----------------------------------------------------------------------------
Write-Host "  [3/5] Configurando PowerShell..."

if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module -Name PSReadLine -Force -SkipPublisherCheck
}

# -----------------------------------------------------------------------------
# [4/5] Copiar configuraciones
# -----------------------------------------------------------------------------
Write-Host "  [4/5] Copiando configuraciones..."

$HomeDir = $env:USERPROFILE
$ConfigDir = Join-Path $HomeDir ".config"
New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $ConfigDir "fastfetch") | Out-Null


# Fastfetch
Backup-IfExists (Join-Path $ConfigDir "fastfetch\config.jsonc")
Copy-Item (Join-Path $ConfigsDir "fastfetch\config.jsonc") (Join-Path $ConfigDir "fastfetch\config.jsonc") -Force
Backup-IfExists (Join-Path $ConfigDir "fastfetch\logo.txt")
Copy-Item (Join-Path $ConfigsDir "fastfetch\logo.txt") (Join-Path $ConfigDir "fastfetch\logo.txt") -Force

# Starship — lee ~/.config/starship.toml (no una subcarpeta starship/)
Backup-IfExists (Join-Path $ConfigDir "starship.toml")
Copy-Item (Join-Path $ConfigsDir "starship\starship.toml") (Join-Path $ConfigDir "starship.toml") -Force

# Git config
Backup-IfExists (Join-Path $HomeDir ".gitconfig")
Copy-Item (Join-Path $ConfigsDir "git\gitconfig") (Join-Path $HomeDir ".gitconfig") -Force

# -----------------------------------------------------------------------------
# [5/5] Crear perfil de PowerShell
# -----------------------------------------------------------------------------
Write-Host "  [5/5] Creando perfil de PowerShell..."

$ProfileDir = Split-Path -Parent $PROFILE
New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null

# Here-string literal (@' '@): sin interpolacion, asi $args y $env:PATH
# quedan en el perfil en vez de expandirse al escribirlo.
$PwshProfile = @'
# =============================================================================
#  ValenOrdu Terminal Setup — PowerShell Profile
# =============================================================================

# Inicializar herramientas
Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
Invoke-Expression (& starship init powershell | Out-String)

# Autocompletado con flechas (como zsh)
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# PowerShell resuelve alias antes que funciones: hay que sacar los built-in
# (ls, cat, gc, gp, gl, gcm...) para que nuestras funciones tomen su lugar.
foreach ($a in 'ls','cat','gc','gp','gl','gcb') {
    Remove-Item "Alias:$a" -Force -ErrorAction SilentlyContinue
}

# eza — reemplazo de ls con iconos y estado de git
function ls { eza --icons --git --group-directories-first @args }
function ll { eza -lh --icons --git --group-directories-first @args }
function la { eza -lah --icons --git --group-directories-first @args }
function lt { eza --tree --level=2 --icons --git @args }

# bat — reemplazo de cat con syntax highlighting
function cat { bat --paging=never @args }

# Git
function gs { git status @args }
function gc { git commit @args }
function gp { git push @args }
function gd { git diff @args }
function gco { git checkout @args }
function gb { git branch @args }
function gl { git log --oneline --graph --decorate -20 @args }
function lg { lazygit @args }

# Navegacion
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function mkcd { param($d) New-Item -ItemType Directory -Force -Path $d | Out-Null; Set-Location $d }

# Utilidades
function ports { netstat -ano | Select-String "LISTENING" }
function path { $env:PATH -split ';' }
function myip { (Invoke-WebRequest -Uri "https://ifconfig.me" -UseBasicParsing).Content }

# ValenOrdu fetch
function valenfetch {
    Clear-Host
    figlet -f larry3d -w 300 "ValenOrdu" | ForEach-Object { Write-Host -ForegroundColor Magenta $_ }
    Write-Host ""
    fastfetch --logo none
}
valenfetch
'@

Backup-IfExists $PROFILE
Set-Content -Path $PROFILE -Value $PwshProfile -Force

Write-Host ""
Write-Host "  Listo! Reinicia PowerShell para ver los cambios."
Write-Host ""
