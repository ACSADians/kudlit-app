param(
  [string]$Url = 'http://127.0.0.1:5173/#/home',
  [string]$TestPath = 'test/features/scanner/presentation/widgets/scan_tab_responsive_matrix_test.dart',
  [string]$OutRoot = 'qa-artifact/scan-layout-strict-overlap'
)

$ErrorActionPreference = 'Stop'

function Write-Info {
  param([string]$Message)
  Write-Output "[scan-overlap-pass] $Message"
}

function Get-Viewports {
  return @(
    @{Name = '360x740'; Width = 360; Height = 740; Transition = $true; StrictTiny = $false},
    @{Name = '390x844'; Width = 390; Height = 844; Transition = $true; StrictTiny = $false},
    @{Name = '430x932'; Width = 430; Height = 932; Transition = $true; StrictTiny = $false},
    @{Name = '844x390'; Width = 844; Height = 390; Transition = $true; StrictTiny = $false},
    @{Name = '1024x768'; Width = 1024; Height = 768; Transition = $true; StrictTiny = $false},
    @{Name = '340x260'; Width = 340; Height = 260; Transition = $false; StrictTiny = $true},
    @{Name = '320x240'; Width = 320; Height = 240; Transition = $false; StrictTiny = $true}
  )
}

function Assert-Endpoint {
  param([string]$TargetUrl)

  $uri = [uri]$TargetUrl
  $hostName = $uri.Host
  $port = if ($uri.Port) { $uri.Port } else { 80 }
  if (-not (Test-NetConnection -ComputerName $hostName -Port $port -WarningAction SilentlyContinue).TcpTestSucceeded) {
    throw "Target is not reachable: $TargetUrl"
  }
  Write-Info "Endpoint reachable: $TargetUrl"
}

function Capture-Image {
  param(
    [Parameter(Mandatory = $true)] [string]$ViewportSpec,
    [Parameter(Mandatory = $true)] [string]$TargetUrl,
    [Parameter(Mandatory = $true)] [string]$OutputPath,
    [int]$WaitMs = 1200
  )

  & npx playwright screenshot --viewport-size=$ViewportSpec --wait-for-timeout=$WaitMs $TargetUrl $OutputPath
}

$root = Split-Path -Path $PSScriptRoot -Parent
$matrixDir = Join-Path $root "$OutRoot/matrix"
$transitionDir = Join-Path $root "$OutRoot/transitions"
$reportPath = Join-Path $root "$OutRoot/report.json"
$testOutputPath = Join-Path $root "$OutRoot/test-output.jsonl"

foreach ($dir in @($matrixDir, $transitionDir)) {
  if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
  }
}

Assert-Endpoint -TargetUrl $Url

Write-Info "Running strict overlap/geometry regression tests: $TestPath"
& flutter test --no-pub --reporter json $TestPath | Set-Content -Path $testOutputPath
if ($LASTEXITCODE -ne 0) {
  throw "Geometry test failed (exit code $LASTEXITCODE). Inspect $testOutputPath"
}
Write-Info 'Geometry regression test passed.'

$viewports = Get-Viewports
$results = @()

foreach ($vp in $viewports) {
  $size = "$($vp.Width),$($vp.Height)"
  $outPath = Join-Path $matrixDir "$($vp.Name).png"
  Write-Info "Capturing static matrix @ $($vp.Name)"
  Capture-Image -ViewportSpec $size -TargetUrl $Url -OutputPath $outPath
  if ($LASTEXITCODE -ne 0) {
    throw "Matrix capture failed for $($vp.Name)."
  }

  $transitions = @()
  if ($vp.Transition) {
    foreach ($phase in @(
      @{Name = 'early'; Delay = 300},
      @{Name = 'mid'; Delay = 1200},
      @{Name = 'late'; Delay = 2100}
    )) {
      $transPath = Join-Path $transitionDir "$($vp.Name)-$($phase.Name).png"
      Write-Info "Capturing transition $($phase.Name) @ $($vp.Name)"
      Capture-Image -ViewportSpec $size -TargetUrl "$($Url + '?qa_camera_status=unavail-ready')" -OutputPath $transPath -WaitMs $phase.Delay
      if ($LASTEXITCODE -ne 0) {
        throw "Transition capture failed for $($vp.Name) $($phase.Name)."
      }
      $transitions += [pscustomobject]@{
        phase = $phase.Name
        delayMs = $phase.Delay
        path = $transPath
      }
    }
  }

  $results += [pscustomobject]@{
    viewport = $vp.Name
    width = $vp.Width
    height = $vp.Height
    strictTiny = $vp.StrictTiny
    matrix = $outPath
    transitionCaptured = $vp.Transition
    transitions = $transitions
  }
}

$report = [pscustomobject]@{
  timestamp = (Get-Date).ToString('o')
  status = 'pass'
  script = $MyInvocation.MyCommand.Name
  matrixTest = $TestPath
  url = $Url
  results = $results
}

$report | ConvertTo-Json -Depth 6 | Set-Content -Path $reportPath
Write-Info "Saved overlap report: $reportPath"
Write-Info "Complete. Matrix artifacts in $matrixDir, transition artifacts in $transitionDir"
