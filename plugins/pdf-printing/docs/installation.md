# Print Demo - Installation & Setup

Installation steps for the pdf-printing plugin.

## Prerequisites

**Required:** `CLAUDE_PLUGINS_ROOT` quasi-variable defined in CLAUDE.md

Expected definition:
```
CLAUDE_PLUGINS_ROOT = CLAUDE_MAIN_WORKSPACE_ROOT + '\.localData\claude-plugins'
```

**If undefined:** Escalate to user and STOP - cannot proceed.

## Plugin Structure

Plugin root: `CLAUDE_PLUGINS_ROOT\nicoforclaude\pdf-printing`

For standard setup:
```
${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing
```

Directory layout:
```
{PLUGIN_ROOT}/
├── exe/
│   ├── package.json     # npm dependencies
│   └── node_modules/    # installed packages (md-to-pdf)
├── config/
│   └── settings.json
└── temp/                # temporary conversion files
```

**Note:** PDFs are output to `{cwd}/.printOutput/` (current working directory), not plugin root.

## Installation Steps

### 1. Set Plugin Root

```powershell
$PLUGIN_ROOT = "${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing"
```

### 2. Check Existing Installation

```powershell
Test-Path "$PLUGIN_ROOT"
Test-Path "$PLUGIN_ROOT\exe"
Test-Path "$PLUGIN_ROOT\exe\node_modules\md-to-pdf"
Test-Path "$PLUGIN_ROOT\config"
Test-Path "$PLUGIN_ROOT\temp"
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

If all exist, installation is complete.

### 3. Create Directories

```powershell
if (!(Test-Path "$PLUGIN_ROOT")) { mkdir "$PLUGIN_ROOT" }
if (!(Test-Path "$PLUGIN_ROOT\exe")) { mkdir "$PLUGIN_ROOT\exe" }
if (!(Test-Path "$PLUGIN_ROOT\config")) { mkdir "$PLUGIN_ROOT\config" }
if (!(Test-Path "$PLUGIN_ROOT\temp")) { mkdir "$PLUGIN_ROOT\temp" }
```

### 4. Create exe/package.json

```powershell
$packageJson = @"
{
  "name": "@nicoforclaude/pdf-printing-exe",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "md-to-pdf": "^6.0.0"
  }
}
"@

$packageJson | Out-File -FilePath "$PLUGIN_ROOT\exe\package.json" -Encoding utf8
```

### 5. Install npm Dependencies

```powershell
cd "$PLUGIN_ROOT\exe"
npm install
```

**If npm not found:**
- Install Node.js from https://nodejs.org/
- Restart terminal after installation
- Verify with `npm --version`

### 6. Create settings.json

```powershell
$settings = @"
{
  "version": "1.0.0",
  "exePath": "$PLUGIN_ROOT\\exe",
  "tempDir": "$PLUGIN_ROOT\\temp"
}
"@

$settings | Out-File -FilePath "$PLUGIN_ROOT\config\settings.json" -Encoding utf8
```

**Note:** Output directory is always `{cwd}/.printOutput/` where `{cwd}` is the current working directory when the command is run.

### 8. Verify Installation

Check md-to-pdf installation:

```powershell
Test-Path "$PLUGIN_ROOT\exe\node_modules\md-to-pdf"
Test-Path "$PLUGIN_ROOT\exe\node_modules\.bin\md-to-pdf"
```

Both should return `True`.

### 9. Completion Report

```
✓ Plugin setup complete!

Root: ${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing

Directories created:
  - exe/ (with npm packages)
  - config/
  - temp/

Configuration: config\settings.json

Dependencies:
  ✓ npm available
  ✓ md-to-pdf installed in exe/node_modules/

Output: PDFs will be saved to {cwd}/.printOutput/

Ready to convert markdown files to PDF.
```

## Settings File Structure

```json
{
  "version": "1.0.0",
  "exePath": "{PLUGIN_ROOT}\\exe",
  "tempDir": "{PLUGIN_ROOT}\\temp"
}
```

Fields:
- `version`: Plugin version (currently 1.0.0)
- `exePath`: Path to exe/ folder containing node_modules with md-to-pdf
- `tempDir`: Temporary files during conversion

**Note:** Output directory is not stored in settings - PDFs are always saved to `{cwd}/.printOutput/` where the command is run.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CLAUDE_PLUGINS_ROOT undefined | Add to workspace root CLAUDE.md |
| Permission denied creating dirs | Run with appropriate permissions |
| npm not found | Install Node.js, restart terminal |
| npm install fails | Check internet connection, verify package.json syntax |
| md-to-pdf not in node_modules | Re-run `npm install` in exe/ folder |
| settings.json creation fails | Check write permissions on config/ |

## Manual Installation

If auto-install fails:

1. Create directory: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`
2. Create subdirectories: `exe`, `config`, `temp`
3. Create `exe\package.json` with md-to-pdf dependency
4. Run `npm install` in exe/ folder
5. Create `config\settings.json` with structure above
6. Test with: `/print_demo`
