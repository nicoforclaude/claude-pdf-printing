---
description: "Initialize printing plugin (one-time setup)"
allowed-tools: Bash(mkdir:*), Bash(Test-Path:*), Bash(where.exe:*), Bash(Invoke-WebRequest:*), Bash(Expand-Archive:*), Bash(npx:*), Bash(mv:*), Bash(cp:*), Write, Read, AskUserQuestion
---

# 🔧 Print Plugin Initialization

You are **print-init-claude**. Your job is to set up the printing plugin environment with proper directory structure and dependencies.

## Overview

Initialize the printing plugin with:
- Clean directory structure (`.localData/plugins/printing/`)
- SumatraPDF detection/installation (Windows)
- Migration from old structure (if exists)
- Configuration files
- Dependency validation

## Workflow

### 1. Create Directory Structure

```powershell
if not exist ".localData\plugins\printing\bin" mkdir ".localData\plugins\printing\bin"
if not exist ".localData\plugins\printing\output" mkdir ".localData\plugins\printing\output"
if not exist ".localData\plugins\printing\temp" mkdir ".localData\plugins\printing\temp"
if not exist ".localData\plugins\printing\data" mkdir ".localData\plugins\printing\data"
if not exist ".localData\plugins\printing\config" mkdir ".localData\plugins\printing\config"
```

### 2. Check Platform

Detect OS to determine if SumatraPDF setup is needed:
- Windows: Proceed with SumatraPDF check
- Linux/Mac: Skip (uses built-in `lp` command)

### 3. Check for SumatraPDF (Windows only)

```powershell
# Check system-wide installation
where.exe SumatraPDF 2>nul
```

**If found**: ✅ Report path and continue

**If not found**: Ask user via AskUserQuestion:

**Question**: "SumatraPDF not found in system PATH. How would you like to proceed?"

**Options**:
1. **Download portable version** - I'll download SumatraPDF portable to `.localData/plugins/printing/bin/`
2. **Install manually** - I'll give you the download link, you install it yourself
3. **Skip for now** - Set up printing without printer support (PDF generation only)

#### Option 1: Download Portable Version

```powershell
# Download SumatraPDF portable (64-bit)
Invoke-WebRequest -Uri "https://www.sumatrapdfreader.org/dl/rel/SumatraPDF-3.5.2-64.zip" -OutFile ".localData\plugins\printing\bin\sumatra.zip"

# Extract
Expand-Archive -Path ".localData\plugins\printing\bin\sumatra.zip" -DestinationPath ".localData\plugins\printing\bin\SumatraPDF" -Force

# Clean up zip
rm ".localData\plugins\printing\bin\sumatra.zip"
```

**Store path** in config: `.localData/plugins/printing/bin/SumatraPDF/SumatraPDF.exe`

#### Option 2: Manual Installation

Show user:
```
Please download and install SumatraPDF from:
https://www.sumatrapdfreader.org/download-free-pdf-viewer

After installation, run /print:init again to complete setup.
```

Exit gracefully.

#### Option 3: Skip

Continue without printer support. Store in config: `printerEnabled: false`

### 4. Test md-to-pdf

```bash
npx md-to-pdf --version
```

**If fails**: Warn user that `npx` might not be available, printing will fail.

### 5. Migrate Old Structure (if exists)

Check if `.localData/printing/` exists:

```powershell
Test-Path ".localData\printing"
```

**If exists**:

Ask user: "Found existing printing data at `.localData/printing/`. Migrate to new plugin structure?"

**If yes**:

```powershell
# Migrate user lists
if exist ".localData\printing\excludeFromPrinting.md" (
  cp ".localData\printing\excludeFromPrinting.md" ".localData\plugins\printing\data\"
)

if exist ".localData\printing\selectForPrinting.md" (
  cp ".localData\printing\selectForPrinting.md" ".localData\plugins\printing\data\"
)

# Migrate PDFs
if exist ".localData\printing\pdfsForPrint" (
  cp ".localData\printing\pdfsForPrint\*" ".localData\plugins\printing\output\" 2>nul
)

# Keep old folder for safety (don't delete)
```

Report: "✅ Migrated X files from old structure. Old folder kept at `.localData/printing/` for safety."

### 6. Initialize Configuration

Create `.localData/plugins/printing/config/settings.json`:

```json
{
  "version": "1.0.0",
  "printerEnabled": <true if SumatraPDF found, false otherwise>,
  "sumatraPath": "<path to SumatraPDF.exe or null>",
  "defaultPrinter": "auto",
  "outputDir": "output",
  "tempDir": "temp",
  "dataDir": "data",
  "keepTempFiles": false,
  "autoOpenPDF": false,
  "platform": "<win32|linux|darwin>"
}
```

### 7. Initialize Data Files

If not migrated, create empty `.localData/plugins/printing/data/excludeFromPrinting.md`:

```markdown
# Exclude From Printing

Files you've chosen not to print (auto-updated by /print_docs).
Sorted by line count (descending).

---

(No exclusions yet)
```

### 8. Report Setup Status

Show comprehensive report:

```
✅ Printing Plugin Initialized

Directory Structure:
  📁 .localData/plugins/printing/
     ├── bin/          <SumatraPDF portable or empty>
     ├── output/       <Final PDFs>
     ├── temp/         <Temporary files>
     ├── data/         <User lists>
     └── config/       <Plugin settings>

Dependencies:
  ✅ npx (md-to-pdf): Available
  <✅ or ⚠️> SumatraPDF: <Found at PATH | Portable installed | Not installed - PDF only>

Configuration:
  📄 settings.json created
  🖨️  Printer support: <Enabled | Disabled>

Migration:
  <✅ Migrated N files from old structure | ℹ️ No old data found>

Next Steps:
  • Use /print_docs to convert recent markdown files
  • Use /print <file> for quick single-file conversion
  • PDF outputs will be saved to .localData/plugins/printing/output/
```

## Error Handling

- If directory creation fails: Report error and exit
- If network fails during download: Suggest manual installation
- If md-to-pdf test fails: Warn but continue (might work later)
- If migration fails: Warn but continue with clean slate

## Guardrails

- **Never** delete `.localData/printing/` (old structure) - keep for safety
- **Never** commit `.localData/` (should be gitignored)
- **Never** install system-wide software without user permission
- Show clear progress for each step
