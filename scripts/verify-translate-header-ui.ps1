#Requires -Version 7.0

param(
  [string]$Url = 'http://127.0.0.1:5173',
  [int[]]$Widths = @(768, 1024, 1366),
  [int]$Height = 900,
  [string]$OutputDir = 'test-results/ui-verify'
)

$ErrorActionPreference = 'Stop'

function Write-Info {
  param([string]$Message)
  Write-Output "[ui-verify] $Message"
}

$root = Resolve-Path $PSScriptRoot/..
$logPrefix = "translate-header"

if (!(Test-Path $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

Write-Info "Starting Dart verification for translate header density tests"
& flutter test --no-pub test/features/home/presentation/widgets/translate_density_test.dart
if ($LASTEXITCODE -ne 0) {
  throw "flutter test failed (exit code $LASTEXITCODE)."
}

Write-Info "Dart tests passed"

$serverWasStarted = $false
$pythonProc = $null
$uriBase = $Url.TrimEnd('/')
$hostName = $uriBase -replace 'https?://', '' -split '/' | Select-Object -First 1
$previewHost = $hostName -replace ':\d+$', ''
$port = 5173
if ($hostName -match ':(\d+)') {
  $port = [int]$Matches[1]
}

Write-Info "Ensuring preview URL is reachable: $uriBase"
$isReachable = (Test-NetConnection -ComputerName $previewHost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded
if (-not $isReachable) {
  $webBuild = Join-Path $root 'build/web'
  if (-not (Test-Path $webBuild)) {
    Write-Info "build/web not found. Running flutter build web --release."
    & flutter build web --release
    if ($LASTEXITCODE -ne 0) {
      throw "flutter build web --release failed (exit code $LASTEXITCODE)."
    }
  }

  Write-Info "Starting local static preview on port $port"
  $pythonProc = Start-Process -FilePath python -WindowStyle Hidden -ArgumentList @(
    '-m', 'http.server', $port.ToString(), '--directory', (Join-Path $root 'build/web')
  ) -PassThru
  $serverWasStarted = $true
  Start-Sleep -Milliseconds 1200

  $attempt = 0
  while (-not (Test-NetConnection -ComputerName $previewHost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded -and $attempt -lt 40) {
    Start-Sleep -Milliseconds 500
    $attempt++
  }

  if (-not (Test-NetConnection -ComputerName $previewHost -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded) {
    if ($pythonProc) {
      Stop-Process -Id $pythonProc.Id -ErrorAction SilentlyContinue
    }
    throw "Preview server did not become reachable on port $port."
  }
}

try {
  foreach ($w in $Widths) {
    $outFile = Join-Path $root "$OutputDir/$logPrefix-$($w).png"
    $viewport = "$w,$Height"
    Write-Info "Capturing translate header @ ${w}x$Height -> $outFile"
    & npx playwright screenshot --viewport-size=$viewport "$($uriBase + '/?tab=translate')" $outFile --wait-for-timeout=8000
    if ($LASTEXITCODE -ne 0) {
      throw "Playwright screenshot failed for width $w (exit code $LASTEXITCODE)."
    }
  }
} finally {
  if ($serverWasStarted -and $pythonProc -and -not $pythonProc.HasExited) {
    Stop-Process -Id $pythonProc.Id -ErrorAction SilentlyContinue
    Write-Info "Stopped temporary static preview server."
  }
}

Write-Info "Verification complete. Screenshots in $OutputDir"
