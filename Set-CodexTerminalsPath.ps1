<#
.SYNOPSIS
    Set or view the initial cd path for Open-CodexTerminals.ps1
.DESCRIPTION
    Updates .codex-terminals.json. Use a WSL path (e.g. /home/walte/projects or /mnt/c/Users/walte/...)
    Run without args to open the GUI.
.EXAMPLE
    .\Set-CodexTerminalsPath.ps1
    .\Set-CodexTerminalsPath.ps1 /home/walte/projects
#>

param(
    [Parameter(Position = 0)]
    [string]$Path,
    [switch]$Gui
)

$configPath = Join-Path $PSScriptRoot ".codex-terminals.json"

function Get-Config {
    $default = @{
        path = "/home"; monitor = 0; codexCommand = "codex"
        frontendDir = "frontend"; backendDir = "backend"; devCommand = "lg"
    }
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        if ($config.path) { $default.path = $config.path }
        if ($null -ne $config.monitor) { $default.monitor = [int]$config.monitor }
        if ($config.codexCommand) { $default.codexCommand = $config.codexCommand }
        if ($config.frontendDir) { $default.frontendDir = $config.frontendDir }
        if ($config.backendDir) { $default.backendDir = $config.backendDir }
        if ($config.devCommand) { $default.devCommand = $config.devCommand }
    }
    return $default
}

function Set-Config {
    param([string]$Path, [int]$Monitor, [string]$CodexCommand, [string]$FrontendDir, [string]$BackendDir, [string]$DevCommand)
    $obj = @{
        path = $Path; monitor = $Monitor; codexCommand = $CodexCommand
        frontendDir = $FrontendDir; backendDir = $BackendDir; devCommand = $DevCommand
    }
    $obj | ConvertTo-Json | Set-Content $configPath -Encoding UTF8
}

# CLI mode
if ($Path) {
    $config = Get-Config
    Set-Config -Path $Path -Monitor $config.monitor -CodexCommand $config.codexCommand -FrontendDir $config.frontendDir -BackendDir $config.backendDir -DevCommand $config.devCommand
    Write-Host "Path set to: $Path" -ForegroundColor Green
    exit
}

# GUI mode
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$config = Get-Config

$form = New-Object System.Windows.Forms.Form
$form.Text = "Codex Terminals - Config"
$form.Size = New-Object System.Drawing.Size(450, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$pathLabel = New-Object System.Windows.Forms.Label
$pathLabel.Location = New-Object System.Drawing.Point(15, 15)
$pathLabel.Size = New-Object System.Drawing.Size(410, 20)
$pathLabel.Text = "Base path (WSL):"
$form.Controls.Add($pathLabel)
$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.Location = New-Object System.Drawing.Point(15, 40)
$pathBox.Size = New-Object System.Drawing.Size(405, 23)
$pathBox.Text = $config.path
$form.Controls.Add($pathBox)

$monitorLabel = New-Object System.Windows.Forms.Label
$monitorLabel.Location = New-Object System.Drawing.Point(15, 70)
$monitorLabel.Size = New-Object System.Drawing.Size(200, 20)
$monitorLabel.Text = "Monitor:"
$form.Controls.Add($monitorLabel)
$monitorBox = New-Object System.Windows.Forms.ComboBox
$monitorBox.Location = New-Object System.Drawing.Point(15, 90)
$monitorBox.Size = New-Object System.Drawing.Size(250, 23)
$monitorBox.DropDownStyle = "DropDownList"
$screens = [System.Windows.Forms.Screen]::AllScreens
for ($i = 0; $i -lt $screens.Length; $i++) {
    $s = $screens[$i]
    $res = "$($s.Bounds.Width)x$($s.Bounds.Height)"
    $name = if ($s.Primary) { "Primary ($res)" } else { "Display $($i + 1) ($res)" }
    [void]$monitorBox.Items.Add($name)
}
$monitorBox.SelectedIndex = [Math]::Min($config.monitor, $screens.Length - 1)
$form.Controls.Add($monitorBox)

$codexLabel = New-Object System.Windows.Forms.Label
$codexLabel.Location = New-Object System.Drawing.Point(15, 125)
$codexLabel.Size = New-Object System.Drawing.Size(200, 20)
$codexLabel.Text = "4-pane command (codex):"
$form.Controls.Add($codexLabel)
$codexBox = New-Object System.Windows.Forms.TextBox
$codexBox.Location = New-Object System.Drawing.Point(15, 145)
$codexBox.Size = New-Object System.Drawing.Size(150, 23)
$codexBox.Text = $config.codexCommand
$form.Controls.Add($codexBox)

$devLabel = New-Object System.Windows.Forms.Label
$devLabel.Location = New-Object System.Drawing.Point(15, 175)
$devLabel.Size = New-Object System.Drawing.Size(300, 20)
$devLabel.Text = "2-pane (left/right): frontend dir, backend dir, command:"
$form.Controls.Add($devLabel)
$frontendBox = New-Object System.Windows.Forms.TextBox
$frontendBox.Location = New-Object System.Drawing.Point(15, 195)
$frontendBox.Size = New-Object System.Drawing.Size(100, 23)
$frontendBox.Text = $config.frontendDir
$form.Controls.Add($frontendBox)
$backendBox = New-Object System.Windows.Forms.TextBox
$backendBox.Location = New-Object System.Drawing.Point(125, 195)
$backendBox.Size = New-Object System.Drawing.Size(100, 23)
$backendBox.Text = $config.backendDir
$form.Controls.Add($backendBox)
$devCmdBox = New-Object System.Windows.Forms.TextBox
$devCmdBox.Location = New-Object System.Drawing.Point(235, 195)
$devCmdBox.Size = New-Object System.Drawing.Size(80, 23)
$devCmdBox.Text = $config.devCommand
$form.Controls.Add($devCmdBox)

$saveBtn = New-Object System.Windows.Forms.Button
$saveBtn.Location = New-Object System.Drawing.Point(15, 235)
$saveBtn.Size = New-Object System.Drawing.Size(90, 28)
$saveBtn.Text = "Save"
$saveBtn.Add_Click({
    $newPath = $pathBox.Text.Trim()
    if ($newPath) {
        $fe = $frontendBox.Text.Trim(); if (-not $fe) { $fe = "frontend" }
        $be = $backendBox.Text.Trim(); if (-not $be) { $be = "backend" }
        $dc = $devCmdBox.Text.Trim(); if (-not $dc) { $dc = "lg" }
        Set-Config -Path $newPath -Monitor $monitorBox.SelectedIndex -CodexCommand $codexBox.Text.Trim() -FrontendDir $fe -BackendDir $be -DevCommand $dc
        [System.Windows.Forms.MessageBox]::Show("Saved.", "Done")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please enter a path.", "Error")
    }
})
$form.Controls.Add($saveBtn)

$form.AcceptButton = $saveBtn
$form.ShowDialog()
