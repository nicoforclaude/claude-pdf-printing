---
description: "Convert markdown documents to PDF"
allowed-tools: Bash(mkdir:*), Bash(Test-Path:*), Bash(where.exe:*), Bash(npx:*), Bash(cp:*), Bash(rm:*), Bash(ls:*), Write, Read, Glob
---

# PDF Printing - Markdown to PDF Conversion

Convert markdown files to PDF.

## Arguments

- **No args**: Display plugin state
- **Single file**: `/pdf-printing:print path/to/file.md`

## Paths

- **Plugin root**: `${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing`
- **Output directory**: `{cwd}/.printOutput/` (current working directory when command runs)

## Workflow

### Step 1: Check Installation

```powershell
$PLUGIN_ROOT = "${CLAUDE_MAIN_WORKSPACE_ROOT}\.localData\claude-plugins\nicoforclaude\pdf-printing"

# Check if installed
Test-Path "$PLUGIN_ROOT\config\settings.json"
```

**If settings.json missing:** Run installation (see `../docs/installation.md`).

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
$filename = [System.IO.Path]::GetFileName($sourceFile)
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
$outputDir = ".printOutput"

# Create output directory
if (!(Test-Path "$outputDir")) { mkdir "$outputDir" }

# Copy to temp
cp "$sourceFile" "$PLUGIN_ROOT\temp\$filename"

# Convert
npx md-to-pdf "$PLUGIN_ROOT\temp\$filename" --output "$outputDir\$baseName.pdf"

# Report
if ($LASTEXITCODE -eq 0) {
    $pdf = Get-Item "$outputDir\$baseName.pdf"
    $sizeKB = [math]::Round($pdf.Length / 1KB, 1)
    $fullPath = (Resolve-Path "$outputDir\$baseName.pdf").Path

    Write-Output "✓ PDF generated successfully!"
    Write-Output ""
    Write-Output "Output: $fullPath ($sizeKB KB)"
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

Output: C:\...\{cwd}\.printOutput\README.pdf (87.3 KB)
```

## Error Handling

| Error | Action |
|-------|--------|
| Settings missing | Run installation (see ../docs/installation.md) |
| npx unavailable | Install Node.js |
| File not found | Clear error, exit |
| Non-.md file | Error message |
| Conversion fails | Report error, keep temp for debug |

## Usage

```bash
/pdf-printing:print                # Status
/pdf-printing:print README.md      # Convert file
/pdf-printing:print docs/setup.md  # Convert with path
```

## Notes

- Markdown only (.md files)
- Output: `{cwd}/.printOutput/` (current working directory)
- Temp files auto-cleaned
- Physical printing NOT implemented
