param(
  [string]$BaseUrl = 'http://127.0.0.1:5173',
  [string]$OutRoot = 'qa-artifact/prod-smoke',
  [string]$Viewport = '390,844',
  [int]$WaitMs = 12000
)

$ErrorActionPreference = 'Stop'

function Write-Info {
  param([string]$Message)
  Write-Output "[prod-smoke] $Message"
}

function Get-SafeRouteName {
  param([string]$Route)
  return ($Route -replace '[^a-zA-Z0-9]+', '-').Trim('-').ToLowerInvariant()
}

$root = Split-Path -Path $PSScriptRoot -Parent
$outDir = Join-Path $root $OutRoot
$reportPath = Join-Path $outDir 'report.json'

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$base = $BaseUrl.TrimEnd('/')
$routes = @('/#/login', '/#/home', '/#/settings')
$results = @()

foreach ($route in $routes) {
  $target = "$base$route"
  $name = Get-SafeRouteName -Route $route
  $screenshotPath = Join-Path $outDir "$name.png"

  Write-Info "Checking $target"
  $response = Invoke-WebRequest -UseBasicParsing -Uri $target -TimeoutSec 20
  if ($response.StatusCode -ne 200) {
    throw "Expected HTTP 200 for $target, got $($response.StatusCode)."
  }

  Write-Info "Capturing $route @ $Viewport"
  & npx playwright screenshot --browser=chromium --viewport-size=$Viewport --wait-for-timeout=$WaitMs $target $screenshotPath
  if ($LASTEXITCODE -ne 0) {
    throw "Playwright screenshot failed for $target (exit code $LASTEXITCODE)."
  }

  $results += [pscustomobject]@{
    route = $route
    url = $target
    statusCode = $response.StatusCode
    contentLength = $response.RawContentLength
    screenshot = $screenshotPath
  }
}

$report = [pscustomobject]@{
  timestamp = (Get-Date).ToString('o')
  status = 'pass'
  baseUrl = $base
  viewport = $Viewport
  routes = $results
}

$report | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath
Write-Info "Saved smoke report: $reportPath"
Write-Info 'Complete.'
