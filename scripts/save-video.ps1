<#
.SYNOPSIS
  Save a Meta AI-generated video into the project's output folder.

.USAGE
  save-video.ps1 -Url "https://...fbcdn.net/....mp4" -OutDir "./meta-ai-videos"
  save-video.ps1 -Url "<url>" -OutDir "./meta-ai-videos" -Name "scene1"

  Prints the absolute path of the saved file on success.
#>
param(
  [Parameter(Mandatory = $true)][string]$Url,
  [string]$OutDir = "./meta-ai-videos",
  [string]$Name
)

$ErrorActionPreference = "Stop"

# Resolve / create output dir relative to the current working directory
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Force -Path $OutDir | Out-Null }
$OutDir = (Resolve-Path $OutDir).Path

# Build the filename (timestamped if no -Name given)
$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
if ([string]::IsNullOrWhiteSpace($Name)) { $Name = "metaai-$stamp" }
$out = Join-Path $OutDir "$Name.mp4"

# fbcdn signed URLs download fine without cookies
Invoke-WebRequest -Uri $Url -OutFile $out -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }

$sizeMB = [math]::Round((Get-Item $out).Length / 1MB, 2)
Write-Output "$out ($sizeMB MB)"
