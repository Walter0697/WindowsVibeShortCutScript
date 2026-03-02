<#
.SYNOPSIS
    Opens 2 Windows Terminal panes (left/right), frontend runs in left, backend in right.
.DESCRIPTION
    Left: cd frontendDir, run devCommand. Right: cd backendDir, run devCommand.
    Config from .codex-terminals.json - use Set-CodexTerminalsPath.ps1 to change.
#>

$WslProfile = "Ubuntu"

# Load config
$configPath = Join-Path $PSScriptRoot ".codex-terminals.json"
$path = "/home"
$frontendDir = "frontend"
$backendDir = "backend"
$devCommand = "lg"
$monitor = 0
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.path) { $path = $config.path }
    if ($config.frontendDir) { $frontendDir = $config.frontendDir }
    if ($config.backendDir) { $backendDir = $config.backendDir }
    if ($config.devCommand) { $devCommand = $config.devCommand }
    if ($null -ne $config.monitor) { $monitor = [int]$config.monitor }
}

$basePath = $path.TrimEnd('/')

# Left: cd root, cd frontend, run devCommand. Right: cd root, cd backend, run devCommand
# \; escapes semicolon for wt
$leftCmd = "wsl.exe ~ -e zsh -i -c `"cd \`"$basePath\`" && cd \`"$frontendDir\`" && $devCommand\; exec zsh`""
$rightCmd = "wsl.exe ~ -e zsh -i -c `"cd \`"$basePath\`" && cd \`"$backendDir\`" && $devCommand\; exec zsh`""
$splitCmd = "split-pane -V -p `"$WslProfile`" $rightCmd"

if ($monitor -eq 0) {
    $wtCmd = "wt -M -p `"$WslProfile`" $leftCmd ; $splitCmd"
} else {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $idx = [Math]::Min($monitor, $screens.Length - 1)
    $screen = $screens[$idx]
    $bounds = $screen.WorkingArea
    $cols = [Math]::Max(80, [Math]::Floor($bounds.Width / 10))
    $rows = [Math]::Max(25, [Math]::Floor($bounds.Height / 20))
    $wtCmd = "wt --pos $($bounds.X),$($bounds.Y) --size $cols,$rows -p `"$WslProfile`" $leftCmd ; $splitCmd"
}
Start-Process cmd -ArgumentList '/c', $wtCmd -WindowStyle Hidden
