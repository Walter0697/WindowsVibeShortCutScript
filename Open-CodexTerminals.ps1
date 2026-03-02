<#
.SYNOPSIS
    Opens 4 Windows Terminal panes in a 2x2 grid (WSL), each in your configured path running codex.
.DESCRIPTION
    Run this script (or trigger via shortcut) to instantly spawn a quad-terminal setup.
    Path is read from .codex-terminals.json - use Set-CodexTerminalsPath.ps1 to change it.
    Requires: Windows Terminal, PowerToys (for shortcut binding)
#>

$WslProfile = "Ubuntu"

# Load config
$configPath = Join-Path $PSScriptRoot ".codex-terminals.json"
$path = "/home"
$command = "codex"
$monitor = 0
if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    if ($config.path) { $path = $config.path }
    if ($config.codexCommand) { $command = $config.codexCommand }
    if ($null -ne $config.monitor) { $monitor = [int]$config.monitor }
}

# zsh -i loads .zshrc first. cd to path, run command, exec zsh keeps shell open
# \; escapes semicolon for wt
$wslCmd = "wsl.exe ~ -e zsh -i -c `"cd \`"$path\`" && $command\; exec zsh`""

# Single wt invocation - ^; escapes semicolon for cmd so all splits happen in one window
# -M = maximized (like drag to top), -F = true fullscreen (hides taskbar)
$wtBase = if ($monitor -eq 0) { "wt -M" } else {
    Add-Type -AssemblyName System.Windows.Forms
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $idx = [Math]::Min($monitor, $screens.Length - 1)
    $bounds = $screens[$idx].WorkingArea
    $cols = [Math]::Max(80, [Math]::Floor($bounds.Width / 10))
    $rows = [Math]::Max(25, [Math]::Floor($bounds.Height / 20))
    "wt -M --pos $($bounds.X),$($bounds.Y) --size $cols,$rows"
}

$wtCmd = "$wtBase -p `"$WslProfile`" $wslCmd ^; split-pane -V -p `"$WslProfile`" $wslCmd ^; move-focus left ^; split-pane -H -p `"$WslProfile`" $wslCmd ^; move-focus right ^; split-pane -H -p `"$WslProfile`" $wslCmd"
Start-Process cmd -ArgumentList '/c', $wtCmd -WindowStyle Hidden
