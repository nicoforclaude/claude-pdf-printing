# PDF Printing Plugin - Installation & Setup

## Prerequisites

- **`CLAUDE_PLUGINS_ROOT`** quasi-variable defined in CLAUDE.md:
  ```
  CLAUDE_PLUGINS_ROOT = CLAUDE_MAIN_WORKSPACE_ROOT + '\.localData\claude-plugins'
  ```
- **`md-to-pdf` globally installed** (see step 1 below)

## Why global, not project devDependency

`md-to-pdf` bundles Chrome via puppeteer. Adding it to a project's `devDependencies` forces every `yarn install` in CI to download a ~150MB Chrome binary — even when CI never prints PDFs. Install it globally on developer machines only.

## Installation Steps

### 1. Install md-to-pdf globally

```bash
npm install -g md-to-pdf
```

Verify:
```bash
md-to-pdf --version
```

### 2. Check Existing Plugin Installation

```powershell
$PLUGIN_ROOT = "${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing"

Test-Path "$PLUGIN_ROOT\scripts\convert.ps1"   # CRITICAL
Test-Path "$PLUGIN_ROOT\config\settings.json"
Test-Path "$PLUGIN_ROOT\temp"
```

If all return `True`, installation is complete.

### 3. Create Directories

```powershell
$PLUGIN_ROOT = "${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing"

foreach ($dir in @("", "\scripts", "\config", "\temp")) {
    if (-not (Test-Path "$PLUGIN_ROOT$dir")) { mkdir "$PLUGIN_ROOT$dir" }
}
```

### 4. Copy Scripts from Source

```powershell
$SOURCE = "${CLAUDE_MAIN_WORKSPACE_ROOT}\nicoforclaude\claude-pdf-printing\plugins\pdf-printing\scripts"

if (-not (Test-Path "$SOURCE\convert.ps1")) {
    Write-Error "Source not found. Clone the plugin source repo first."
    exit 1
}

Copy-Item "$SOURCE\*" "$PLUGIN_ROOT\scripts\" -Force
```

**Source repository:** `nicoforclaude/claude-pdf-printing` → `plugins/pdf-printing/scripts/`

### 5. Create settings.json

```powershell
@"
{
  "version": "1.0.0",
  "tempDir": "$PLUGIN_ROOT\\temp"
}
"@ | Out-File -FilePath "$PLUGIN_ROOT\config\settings.json" -Encoding utf8
```

### 6. Verify

```powershell
Test-Path "$PLUGIN_ROOT\scripts\convert.ps1"   # must be True
Test-Path "$PLUGIN_ROOT\config\settings.json"  # must be True
md-to-pdf --version                            # must print version
```

Output directory: `{cwd}/.printOutput/` (relative to where the command runs).

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `CLAUDE_PLUGINS_ROOT` undefined | Add to workspace root CLAUDE.md |
| `md-to-pdf` not found | Run `npm install -g md-to-pdf` |
| `convert.ps1` missing | Re-run step 4 |
| Source scripts not found | Clone plugin source repo |
| Permission denied | Run with appropriate permissions |
