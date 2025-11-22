# PDF Printing Plugin - Solution: Hybrid Approach

**Created:** 2025-11-22
**Related:** `problems.md` (Critical Error #1)

---

## Problem Summary

`md-to-pdf` doesn't accept output path as second argument. It generates PDF in the same directory as the input file. Current workflow in `print.md` fails because it passes output path as argument.

---

## Solution: In-place Generation + Dedicated Script (Hybrid)

Combine the simplicity of in-place PDF generation with the robustness of a dedicated PowerShell script.

### Architecture

```
plugins/pdf-printing/
├── commands/
│   └── print.md          # Orchestration, UI, argument handling
└── scripts/
    └── convert.ps1       # Pure conversion logic
```

### Division of Responsibilities

| Component | Handles |
|-----------|---------|
| **print.md** | Argument parsing, file selection UI, status display, user messaging |
| **convert.ps1** | Conversion only: `input.md` → `output.pdf` at specified location |

---

## Why Hybrid?

### Options Considered

| Approach | Description |
|----------|-------------|
| **Option 1** | In-place generation, all logic in print.md |
| **Option 2** | Script with temp folder workflow |
| **Option 3 (Hybrid)** | In-place generation + dedicated script |

### Comparison Matrix

```
                     Option1      Option2       Option3
                    (in-place)   (script+temp)  (hybrid)
────────────────────────────────────────────────────────
Simplicity            ★★★          ★☆☆          ★★☆
Testability           ★☆☆          ★★★          ★★★
Maintainability       ★★☆          ★★☆          ★★★
Separation of concerns ★☆☆         ★★☆          ★★★
File count            1            2            2
Error handling        Basic        Full         Full
Reusability           None         High         High
```

### Why Not Pure In-place (Option 1)?

- All logic embedded in markdown command file
- Hard to test conversion independently
- No reusability for future commands

### Why Not Temp Folder (Option 2)?

- 4 file operations vs 2 (copy + convert + move + cleanup)
- Unnecessary complexity
- Temp folder management overhead

### Why Hybrid Wins

1. **Testable** - Run `convert.ps1` directly to verify conversion works
2. **Readable** - `print.md` stays focused on user interaction
3. **Reusable** - Future commands (`/pdf-printing:batch`) can use same script
4. **Maintainable** - Clear responsibility boundaries
5. **Simple core** - In-place generation is the simplest conversion approach

---

## Implementation

### convert.ps1

```powershell
# convert.ps1
# Converts markdown to PDF using md-to-pdf
# Usage: .\convert.ps1 -Source "C:\docs\file.md" -Output "C:\out\file.pdf"

param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Output
)

$ErrorActionPreference = "Stop"

# Validate source exists
if (!(Test-Path $Source)) {
    Write-Error "Source file not found: $Source"
    exit 1
}

# Extract paths
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($Source)
$sourceDir = [System.IO.Path]::GetDirectoryName($Source)
$tempPdf = Join-Path $sourceDir "$baseName.pdf"

# Ensure output directory exists
$outputDir = [System.IO.Path]::GetDirectoryName($Output)
if ($outputDir -and !(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

try {
    # Convert (PDF appears next to source)
    $result = npx md-to-pdf $Source 2>&1

    # Check if PDF was created
    if (Test-Path $tempPdf) {
        # Move to target location
        Move-Item $tempPdf $Output -Force

        # Return success info
        $pdf = Get-Item $Output
        $sizeKB = [math]::Round($pdf.Length / 1KB, 1)
        Write-Output $Output
        exit 0
    } else {
        Write-Error "Conversion failed - no PDF generated"
        exit 1
    }
} catch {
    # Cleanup on failure
    if (Test-Path $tempPdf) {
        Remove-Item $tempPdf -Force -ErrorAction SilentlyContinue
    }
    Write-Error "Conversion error: $_"
    exit 1
}
```

### print.md Changes

The command file simplifies to orchestration:

```powershell
# Conversion section in print.md becomes:
$script = "$PLUGIN_ROOT\scripts\convert.ps1"
$outputPath = "$outputDir\$baseName.pdf"

$result = & $script -Source $selectedFile -Output $outputPath 2>&1

if ($LASTEXITCODE -eq 0) {
    $pdf = Get-Item $outputPath
    $sizeKB = [math]::Round($pdf.Length / 1KB, 1)
    Write-Output ""
    Write-Output "Output: $outputPath ($sizeKB KB)"
} else {
    Write-Error "Conversion failed: $result"
}
```

---

## File Operations Comparison

### Before (temp folder approach from problems.md)

1. Copy source → temp folder
2. Change directory to temp
3. Run conversion
4. Move PDF → output folder
5. Delete temp source file

**Total: 5 operations**

### After (hybrid in-place)

1. Run conversion (PDF appears next to source)
2. Move PDF → output folder

**Total: 2 operations**

---

## Script Location Decision

**Chosen:** `$PLUGIN_ROOT/scripts/convert.ps1`

| Location | Pros | Cons |
|----------|------|------|
| `scripts/` | Clear purpose, standard convention | New folder |
| `exe/` | Near node_modules | Conceptually wrong (not an executable) |
| Root | Simple | Clutters plugin root |

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Execution policy blocks script | Document in installation.md, provide bypass instructions |
| Source folder not writable | Check permissions before conversion, clear error message |
| Orphan PDF on move failure | Try/catch with cleanup in script |
| Script not found | Validate script exists at start of print.md |

---

## Testing Plan

### Script Direct Test

```powershell
cd C:\KolyaRepositories\nicoforclaude\claude-pdf-printing\plugins\pdf-printing
.\scripts\convert.ps1 -Source "..\..\README.md" -Output ".\test-output.pdf"
```

### Integration Test

```
/pdf-printing:print README.md
```

### Edge Cases

1. Source in read-only location
2. Output directory doesn't exist
3. PDF already exists at output location
4. Very large markdown file
5. Markdown with special characters in filename

---

## Implementation Checklist

- [ ] Create `plugins/pdf-printing/scripts/` directory
- [ ] Create `convert.ps1` with full implementation
- [ ] Update `print.md` to call script instead of direct npx
- [ ] Update `allowed-tools` in print.md frontmatter
- [ ] Test basic conversion
- [ ] Test error scenarios
- [ ] Update installation.md if needed

---

## Next Steps

1. Implement `convert.ps1`
2. Refactor `print.md` to use script
3. Test all scenarios from problems.md
4. Address remaining medium/low priority issues
