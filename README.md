# Terminal Shortcuts

PowerShell scripts to open Windows Terminal with pre-configured pane layouts (WSL). Bind them to keyboard shortcuts via PowerToys.

## Scripts

| Script | What it does |
|--------|--------------|
| **Open-CodexTerminals** | 4 panes (2×2 grid), maximized. Each runs `codex` in your configured path. |
| **Open-DevTerminals** | 2 panes (left/right). Left: `cd frontend` + `lg`. Right: `cd backend` + `lg`. |
| **Set-CodexTerminalsPath** | GUI to edit all settings (path, monitor, commands). |

## Requirements

- **Windows Terminal** (Store or `winget install Microsoft.WindowsTerminal`)
- **PowerToys** (for keyboard shortcuts)
- **WSL** with zsh (Ubuntu or similar)

## Quick Setup

### 1. Configure settings

Double-click `Set-CodexTerminalsPath.bat` or run:

```powershell
.\Set-CodexTerminalsPath.ps1
```

Set your base path, monitor, and commands in the GUI.

### 2. PowerToys Keyboard Manager

1. Open **PowerToys** → **Keyboard Manager**
2. Turn on **Enable Keyboard Manager**
3. Click **Remap a shortcut** → **Add shortcut remapping**
4. Pick your shortcut (e.g. `Ctrl+Shift+4`)
5. **Action:** **Run program**
6. **Program:** `%USERPROFILE%\Documents\Script\Open-CodexTerminals.bat`
7. Leave **Arguments** empty
8. Save

Repeat for `Open-DevTerminals.bat` with another shortcut (e.g. `Ctrl+Shift+5`).

### 3. Suggested shortcuts

| Shortcut | Script |
|----------|--------|
| `Ctrl+Shift+4` | Open-CodexTerminals (4 panes) |
| `Ctrl+Shift+5` | Open-DevTerminals (2 panes) |

Use chord shortcuts (e.g. `Ctrl+Shift+V` then `4`) if simple combos conflict with apps.

## Config file

Settings are stored in `.codex-terminals.json`:

```json
{
  "path": "/home/<user>/projects",
  "monitor": 0,
  "codexCommand": "codex",
  "frontendDir": "frontend",
  "backendDir": "backend",
  "devCommand": "lg"
}
```

- **path** – Base WSL path for all scripts
- **monitor** – 0 = primary, 1 = second display, etc.
- **codexCommand** – Command for the 4-pane script
- **frontendDir** / **backendDir** – Subdirs for the 2-pane script
- **devCommand** – Command for the 2-pane script (e.g. `lg`)

## Troubleshooting

- **Shortcut does nothing** – Use a different combo (e.g. `Ctrl+Shift+V`) instead of `Alt+V`; some apps grab it.
- **Script runs but wrong layout** – Check `.codex-terminals.json` and your WSL profile name (default: `Ubuntu`).
- **Command not found** – Ensure the command is in your PATH inside WSL (e.g. via `.zshrc`).
