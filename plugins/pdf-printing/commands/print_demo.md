---
description: "Print documents to PDF (demo version - simplified)"
allowed-tools: Bash(mkdir:*), Bash(Test-Path:*), Bash(where.exe:*), Bash(npx:*), Bash(cp:*), Bash(rm:*), Bash(ls:*), Write, Read, Glob
---

# Print Demo - Simple PDF Conversion

Convert markdown files to PDF.

## Arguments

- **No args**: Display plugin state
- **Single file**: `/print_demo path/to/file.md`

## Plugin Root

`CLAUDE_PLUGINS_ROOT\nicoforclaude\pdf-printing`

Standard path: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`

## Workflow

### Step 1: Check Installation

```powershell
$PLUGIN_ROOT = "$env:CLAUDE_MAIN_WORKSPACE_ROOT\.localData\claude-plugins\nicoforclaude\pdf-printing"

# Check if installed
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

**If settings.json missing:** Run installation (see `print_demo_install.md` for details).

**Installation summary:**
1. Create directories: `config/`, `temp/`, `output/`
2. Create `config/settings.json`
3. Verify npx available

**If installed:** Proceed to Step 2.

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

Configuration:
{
  "version": "1.0.0",
  "outputDir": "...",
  "tempDir": "..."
}

Output: {count} PDFs
  - file1.pdf (123 KB) - 2025-11-20 14:30

Dependencies:
  ✓ npx available

Usage:
  /print_demo              → Show status
  /print_demo file.md      → Convert to PDF
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
if ($ext -ne ".md" -and $ext -ne ".markdown") {
    Write-Error "Only markdown files supported"
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
$filename = [System.IO.Path]::GetFileName($sourceFile)
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)

# Copy to temp
cp "$sourceFile" "$PLUGIN_ROOT\temp\$filename"

# Convert
npx md-to-pdf "$PLUGIN_ROOT\temp\$filename" --output "$PLUGIN_ROOT\output\$baseName.pdf"

# Report
if ($LASTEXITCODE -eq 0) {
    $pdf = Get-Item "$PLUGIN_ROOT\output\$baseName.pdf"
    $sizeKB = [math]::Round($pdf.Length / 1KB, 1)

    Write-Output "✓ PDF generated successfully!"
    Write-Output ""
    Write-Output "Output: $PLUGIN_ROOT\output\$baseName.pdf ($sizeKB KB)"
} else {
    Write-Error "✗ Conversion failed"
}

# Cleanup
rm "$PLUGIN_ROOT\temp\$filename"
```

Output:

```
Converting: README.md

✓ PDF generated successfully!

Output: C:\...\output\README.pdf (87.3 KB)

Temp files cleaned up.
```

## Error Handling

| Error | Action |
|-------|--------|
| Settings missing | Run installation (see print_demo_install.md) |
| npx unavailable | Install Node.js |
| File not found | Clear error, exit |
| Non-.md file | Error message |
| Conversion fails | Report error, keep temp for debug |

## Usage

```bash
/print_demo                # Status
/print_demo README.md      # Convert file
/print_demo docs/setup.md  # Convert with path
```

## Notes

- Markdown only (.md, .markdown)
- Output: `{PLUGIN_ROOT}\output\`
- Temp auto-cleaned
- Physical printing NOT implemented
