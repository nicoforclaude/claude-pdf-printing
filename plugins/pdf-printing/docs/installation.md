# PDF Printing Plugin - Installation & Setup

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
├── scripts/
│   └── convert.ps1      # conversion script (REQUIRED)
├── config/
│   └── settings.json    # plugin settings
└── temp/                # temporary conversion files

{cwd}/.printOutput/      # PDF output (current working directory when command runs)
```

**Source repository:** Scripts are maintained in `nicoforclaude/claude-pdf-printing/plugins/pdf-printing/scripts/`

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
Test-Path "$PLUGIN_ROOT\scripts"
Test-Path "$PLUGIN_ROOT\scripts\convert.ps1"
Test-Path "$PLUGIN_ROOT\config"
Test-Path "$PLUGIN_ROOT\temp"
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

If all exist, installation is complete.

**Critical check:** `scripts/convert.ps1` MUST exist. Without it, PDF conversion will fail.

### 3. Create Directories

```powershell
if (!(Test-Path "$PLUGIN_ROOT")) { mkdir "$PLUGIN_ROOT" }
if (!(Test-Path "$PLUGIN_ROOT\exe")) { mkdir "$PLUGIN_ROOT\exe" }
if (!(Test-Path "$PLUGIN_ROOT\scripts")) { mkdir "$PLUGIN_ROOT\scripts" }
if (!(Test-Path "$PLUGIN_ROOT\config")) { mkdir "$PLUGIN_ROOT\config" }
if (!(Test-Path "$PLUGIN_ROOT\temp")) { mkdir "$PLUGIN_ROOT\temp" }
```

### 3b. Copy Scripts from Source

**CRITICAL:** Scripts must be copied from the plugin source repository.

```powershell
$SOURCE_SCRIPTS = "${CLAUDE_MAIN_WORKSPACE_ROOT}\nicoforclaude\claude-pdf-printing\plugins\pdf-printing\scripts"

# Verify source exists
if (!(Test-Path "$SOURCE_SCRIPTS\convert.ps1")) {
    Write-Error "Source script not found. Check plugin source repository."
    exit 1
}

# Copy scripts
Copy-Item "$SOURCE_SCRIPTS\*" "$PLUGIN_ROOT\scripts\" -Force
```

**If source not found:** Clone/pull the plugin source repository first.

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

### 7. Verify Installation

Check all critical components:

```powershell
# Scripts (CRITICAL)
Test-Path "$PLUGIN_ROOT\scripts\convert.ps1"

# md-to-pdf
Test-Path "$PLUGIN_ROOT\exe\node_modules\md-to-pdf"
Test-Path "$PLUGIN_ROOT\exe\node_modules\.bin\md-to-pdf"

# Config
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

All should return `True`.

### 8. Completion Report

```
Plugin setup complete!

Root: ${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing

Directories:
  - exe/ (npm packages)
  - scripts/ (convert.ps1)
  - config/
  - temp/

Critical files:
  - scripts/convert.ps1
  - config/settings.json

Dependencies:
  - npm available
  - md-to-pdf installed

Output: {cwd}/.printOutput/

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
| **scripts/convert.ps1 missing** | Re-run step 3b (copy from source) |
| Source scripts not found | Check plugin source repo exists at expected path |

## Manual Installation

If auto-install fails:

1. Create directory: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`
2. Create subdirectories: `exe`, `scripts`, `config`, `temp`
3. Copy `scripts/convert.ps1` from plugin source repo
4. Create `exe\package.json` with md-to-pdf dependency
5. Run `npm install` in exe/ folder
6. Create `config\settings.json` with structure above
7. Test with: `/pdf-printing:print`

**Do not skip step 3** - the conversion script is required.
