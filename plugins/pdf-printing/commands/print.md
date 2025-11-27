---
description: "Convert markdown documents to PDF"
allowed-tools: Bash(mkdir:*), Bash(Test-Path:*), Bash(where.exe:*), Bash(npx:*), Bash(powershell:*), Bash(ls:*), Write, Read, Glob
---

# PDF Printing - Markdown to PDF Conversion

Convert markdown files to PDF.

## Platform Setup

**On Windows:** Activate `windows-shell:windows-shell` skill FIRST before executing any commands.

This ensures proper handling of:
- Path quoting and backslashes
- PowerShell special character escaping (use `-not` instead of exclamation mark)
- Variable interpolation in inline commands

## Arguments

- **No args**: Display plugin state
- **Single file**: `/pdf-printing:print path/to/file.md`

## Paths

- **Plugin root**: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`
- **Output directory**: `{cwd}/.printOutput/` (current working directory when command runs)

## Workflow

### Step 1: Check Installation (FAIL FAST)

```powershell
$PLUGIN_ROOT = "${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing"

# Check critical paths
Test-Path "$PLUGIN_ROOT\config\settings.json"
Test-Path "$PLUGIN_ROOT\scripts\convert.ps1"
```

**STOP CONDITIONS - If any check fails:**

| Missing | Error Message | Action |
|---------|---------------|--------|
| `settings.json` | "Plugin not installed" | STOP, run installation |
| `scripts/convert.ps1` | "Conversion script missing" | STOP, run installation |

**Error output format:**
```
ERROR: PDF Printing plugin incomplete installation

Missing: scripts/convert.ps1

To fix: Run installation from plugin source
  Source: nicoforclaude/claude-pdf-printing/plugins/pdf-printing/docs/installation.md

STOPPING - Do not attempt workarounds.
```

**CRITICAL:** Do NOT attempt manual npx calls or workarounds. Fail cleanly and direct user to fix installation.

### Step 2: No Arguments - Display State

```powershell
# Read settings
Get-Content "$PLUGIN_ROOT\config\settings.json"

# List outputs
ls "$PLUGIN_ROOT\output"
```

Report:

```
PDF Printing Plugin - Status

Root: ${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing
Output: {cwd}/.printOutput/

Configuration:
{
  "version": "1.0.0",
  "exePath": "...",
  "tempDir": "..."
}

Recent PDFs: {count} files
  - file1.pdf (123 KB) - 2025-11-20 14:30

Dependencies:
  ✓ npx available

Usage:
  /pdf-printing:print              → Show status
  /pdf-printing:print file.md      → Convert to PDF
```

### Step 3: Single File - Convert to PDF

Validate:

```powershell
# File exists
if (!(Test-Path $args[0])) {
    Write-Error "File not found: $args[0]"
    exit 1
}

# Extension check
$ext = [System.IO.Path]::GetExtension($args[0])
if ($ext -ne ".md") {
    Write-Error "Only .md files supported"
    exit 1
}
```

Check npx:

```powershell
where.exe npx
if ($LASTEXITCODE -ne 0) {
    Write-Error "npx not found. Install Node.js: https://nodejs.org/"
    exit 1
}
```

Convert:

```powershell
$sourceFile = $args[0]
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
$outputDir = Join-Path $PWD ".printOutput"
$outputPath = Join-Path $outputDir "$baseName.pdf"
$script = "$PLUGIN_ROOT\scripts\convert.ps1"

# Verify script exists
if (!(Test-Path $script)) {
    Write-Error "Conversion script not found: $script"
    exit 1
}

# Create output directory
if (!(Test-Path "$outputDir")) { mkdir "$outputDir" }

# Convert using script (in-place generation + move)
$result = powershell -ExecutionPolicy Bypass -File $script -Source $sourceFile -Output $outputPath 2>&1

# Report
if ($LASTEXITCODE -eq 0) {
    $pdf = Get-Item $outputPath
    $sizeKB = [math]::Round($pdf.Length / 1KB, 1)
    $fullPath = (Resolve-Path $outputPath).Path

    Write-Output "PDF generated successfully!"
    Write-Output ""
    Write-Output "Output: $fullPath ($sizeKB KB)"
} else {
    Write-Error "Conversion failed: $result"
}
```

Output:

```
Converting: README.md

✓ PDF generated successfully!

Output: C:\...\{cwd}\.printOutput\README.pdf (87.3 KB)
Opened in Chrome: C:\...\{cwd}\.printOutput\README.pdf
```

## Error Handling

**FAIL FAST POLICY:** Stop immediately on installation issues. Do not attempt workarounds.

| Error | Action | Workarounds? |
|-------|--------|--------------|
| `settings.json` missing | STOP, run installation | NO |
| `scripts/convert.ps1` missing | STOP, run installation | NO |
| npx unavailable | STOP, install Node.js | NO |
| Source file not found | Clear error, exit | NO |
| Non-.md file | Error message, exit | NO |
| Conversion fails | Report error with details | NO |

**Why no workarounds?**
- Manual npx calls have different syntax/behavior
- Workarounds mask installation problems
- Better UX: clear error → fix → success

## Usage

```bash
/pdf-printing:print                # Status
/pdf-printing:print README.md      # Convert file
/pdf-printing:print docs/setup.md  # Convert with path
```

## Notes

- Markdown only (.md files)
- Output: `{cwd}/.printOutput/` (current working directory)
- Uses `scripts/convert.ps1` for conversion (in-place generation + move)
- **Automatically opens generated PDFs in Chrome browser** (will be customizable in future)
- Physical printing NOT implemented
