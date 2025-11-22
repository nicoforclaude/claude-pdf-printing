# convert.ps1
# Converts markdown to PDF using md-to-pdf (in-place generation, then move)
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

# Get absolute path for source
$Source = (Resolve-Path $Source).Path

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
    # Convert (PDF appears next to source file)
    $npxOutput = npx md-to-pdf $Source 2>&1

    # Check if PDF was created
    if (Test-Path $tempPdf) {
        # Move to target location
        Move-Item $tempPdf $Output -Force

        # Verify move succeeded
        if (Test-Path $Output) {
            Write-Output $Output
            exit 0
        } else {
            Write-Error "Failed to move PDF to output location"
            exit 1
        }
    } else {
        Write-Error "Conversion failed - no PDF generated. npx output: $npxOutput"
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
