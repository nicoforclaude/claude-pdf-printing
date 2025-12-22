# convert.ps1
# Converts markdown to PDF using md-to-pdf (in-place generation, then move)
# Usage: .\convert.ps1 -Source "C:\docs\file.md" -Output "C:\out\file.pdf"

param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Output,

    [Parameter(Mandatory=$false)]
    [bool]$OpenInChrome = $true  # Default to true, will be customizable later
)

$ErrorActionPreference = "Stop"

# --- Helper Functions ---

function Get-TruncatedPath {
    param(
        [string]$FullPath,
        [int]$MaxLength = 80
    )

    # Normalize to forward slashes
    $normalizedPath = $FullPath.Replace('\', '/')

    if ($normalizedPath.Length -le $MaxLength) {
        return $normalizedPath
    }

    # Split into segments
    $segments = $normalizedPath.Split('/')

    # Start from the end, keep adding segments until we exceed MaxLength
    $result = @()
    $currentLength = 3  # Account for "..." prefix

    for ($i = $segments.Length - 1; $i -ge 0; $i--) {
        $segment = $segments[$i]
        $segmentLength = $segment.Length + 1  # +1 for the slash

        if ($currentLength + $segmentLength -le $MaxLength) {
            $result = @($segment) + $result
            $currentLength += $segmentLength
        } else {
            break
        }
    }

    # If we couldn't fit any segments, just return filename
    if ($result.Length -eq 0) {
        return $segments[-1]
    }

    # If we kept all segments, return as-is
    if ($result.Length -eq $segments.Length) {
        return $normalizedPath
    }

    return ".../" + ($result -join '/')
}

function New-PdfConfig {
    param(
        [string]$DisplayPath,
        [string]$TempDir
    )

    $configPath = Join-Path $TempDir "md-to-pdf-config-$([guid]::NewGuid().ToString('N').Substring(0,8)).js"

    $configContent = @"
module.exports = {
  pdf_options: {
    format: 'A4',
    margin: { top: '25mm', bottom: '20mm', left: '15mm', right: '15mm' },
    displayHeaderFooter: true,
    headerTemplate: ``
      <style>
        section { width: 100%; margin: 0 15mm; font-family: system-ui, -apple-system, sans-serif; font-size: 9px; color: #666; }
      </style>
      <section><div>$DisplayPath</div></section>
    ``,
    footerTemplate: ``
      <style>
        section { width: 100%; margin: 0 15mm; font-family: system-ui, -apple-system, sans-serif; font-size: 9px; color: #666; text-align: center; }
      </style>
      <section>Page <span class="pageNumber"></span> of <span class="totalPages"></span></section>
    ``
  }
};
"@

    $configContent | Out-File -FilePath $configPath -Encoding utf8 -NoNewline
    return $configPath
}

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

# Prepare header/footer config
$displayPath = Get-TruncatedPath -FullPath $Source -MaxLength 80
$tempDir = [System.IO.Path]::GetTempPath()
$tempConfigPath = $null

try {
    # Create temporary config file for header/footer
    $tempConfigPath = New-PdfConfig -DisplayPath $displayPath -TempDir $tempDir

    # Convert with config (PDF appears next to source file)
    $npxOutput = npx md-to-pdf --config-file $tempConfigPath $Source 2>&1

    # Check if PDF was created
    if (Test-Path $tempPdf) {
        # Move to target location
        Move-Item $tempPdf $Output -Force

        # Verify move succeeded
        if (Test-Path $Output) {
            # Get absolute path for output
            $absoluteOutput = (Resolve-Path $Output).Path
            Write-Output $absoluteOutput

            # Open in Chrome if requested
            if ($OpenInChrome) {
                try {
                    Start-Process chrome $absoluteOutput
                    Write-Output "Opened in Chrome: $absoluteOutput"
                } catch {
                    Write-Warning "Could not open in Chrome: $_"
                    # Continue anyway - PDF was still generated successfully
                }
            }

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
} finally {
    # Always cleanup temp config file
    if ($tempConfigPath -and (Test-Path $tempConfigPath)) {
        Remove-Item $tempConfigPath -Force -ErrorAction SilentlyContinue
    }
}
