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
├── config/
│   └── settings.json
├── temp/          # temporary conversion files
└── output/        # generated PDFs
```

## Installation Steps

### 1. Set Plugin Root

```powershell
$PLUGIN_ROOT = "$env:CLAUDE_MAIN_WORKSPACE_ROOT\.localData\claude-plugins\nicoforclaude\pdf-printing"
```

### 2. Check Existing Installation

```powershell
Test-Path "$PLUGIN_ROOT"
Test-Path "$PLUGIN_ROOT\config"
Test-Path "$PLUGIN_ROOT\temp"
Test-Path "$PLUGIN_ROOT\output"
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

If all exist, installation is complete.

### 3. Create Directories

```powershell
if (!(Test-Path "$PLUGIN_ROOT")) { mkdir "$PLUGIN_ROOT" }
if (!(Test-Path "$PLUGIN_ROOT\config")) { mkdir "$PLUGIN_ROOT\config" }
if (!(Test-Path "$PLUGIN_ROOT\temp")) { mkdir "$PLUGIN_ROOT\temp" }
if (!(Test-Path "$PLUGIN_ROOT\output")) { mkdir "$PLUGIN_ROOT\output" }
```

### 4. Create settings.json

```powershell
$settings = @"
{
  "version": "1.0.0",
  "outputDir": "$PLUGIN_ROOT\\output",
  "tempDir": "$PLUGIN_ROOT\\temp"
}
"@

$settings | Out-File -FilePath "$PLUGIN_ROOT\config\settings.json" -Encoding utf8
```

### 5. Verify Dependencies

Check npx availability:

```powershell
where.exe npx
```

**If not found:**
- Install Node.js from https://nodejs.org/
- Restart terminal after installation
- Verify with `npx --version`

### 6. Completion Report

```
✓ Plugin setup complete!

Root: ${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing

Directories created:
  - config/
  - temp/
  - output/

Configuration: config\settings.json

Dependencies:
  ✓ npx available
  ✓ md-to-pdf (via npx, no installation needed)

Ready to convert markdown files to PDF.
```

## Settings File Structure

```json
{
  "version": "1.0.0",
  "outputDir": "{PLUGIN_ROOT}\\output",
  "tempDir": "{PLUGIN_ROOT}\\temp"
}
```

Fields:
- `version`: Plugin version (currently 1.0.0)
- `outputDir`: Where PDFs are saved
- `tempDir`: Temporary files during conversion

## Troubleshooting

| Issue | Solution |
|-------|----------|
| CLAUDE_PLUGINS_ROOT undefined | Add to workspace root CLAUDE.md |
| Permission denied creating dirs | Run with appropriate permissions |
| npx not found | Install Node.js, restart terminal |
| settings.json creation fails | Check write permissions on config/ |

## Manual Installation

If auto-install fails:

1. Create directory: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`
2. Create subdirectories: `config`, `temp`, `output`
3. Create `config\settings.json` with structure above
4. Install Node.js if needed
5. Test with: `/print_demo`
