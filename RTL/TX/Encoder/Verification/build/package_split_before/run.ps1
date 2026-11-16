[CmdletBinding()]
param(
    [string]$Test = 'encoder_regression_test',
    [int]$Seed = 1,
    [int]$RandomCount = 3000,
    [switch]$Suite,
    [switch]$SkipCompile,
    [string]$QuestaBin = '',
    [string]$Python = 'python',
    [string]$LutPath = ''
)
$ErrorActionPreference = 'Stop'
if ($Seed -lt 1 -or $RandomCount -lt 1) { throw 'Seed and RandomCount must be positive.' }
if ($Test -notmatch '^encoder_[a-z0-9_]+_test$') { throw 'Invalid UVM test name.' }
$verificationRoot = $PSScriptRoot
$buildDir = Join-Path $verificationRoot 'build'
$logsDir = Join-Path $buildDir 'logs'
New-Item -ItemType Directory -Force -Path $buildDir, $logsDir | Out-Null
if (!$QuestaBin) {
    $vsimCmd = Get-Command vsim -ErrorAction Stop
    $QuestaBin = Split-Path $vsimCmd.Source
}
$uvmInclude = Join-Path (Split-Path $QuestaBin) 'verilog_src/uvm-1.1d/src'
if (!(Test-Path -LiteralPath (Join-Path $uvmInclude 'uvm_macros.svh'))) {
    throw "Cannot find UVM 1.1d source headers at $uvmInclude"
}
function Invoke-Questa([string]$Tool, [string[]]$ToolArgs) {
    & (Join-Path $QuestaBin "$Tool.exe") @ToolArgs
    if ($LASTEXITCODE -ne 0) { throw "$Tool failed with exit code $LASTEXITCODE" }
}
Push-Location $verificationRoot
try {
    & $Python scripts/generate_reference.py --check
    if ($LASTEXITCODE -ne 0) { throw 'Reference ROM validation failed.' }
    if (!$SkipCompile) {
        & $Python scripts/test_reference.py
        if ($LASTEXITCODE -ne 0) { throw 'Python reference tests failed.' }
        Push-Location $buildDir
        try {
            if (!(Test-Path -LiteralPath 'modelsim.ini')) { Invoke-Questa 'vmap' @('-c') }
            if (!(Test-Path -LiteralPath 'work')) { Invoke-Questa 'vlib' @('work') }
        } finally { Pop-Location }
        $iniPath = 'build/modelsim.ini'
        Invoke-Questa 'vmap' @('-modelsimini', $iniPath, 'work', (Join-Path $buildDir 'work'))
        $sources = @(Get-Content -LiteralPath 'files.f' | ForEach-Object { $_.Trim() } |
            Where-Object { $_ -and !$_.StartsWith('#') })
        $rtlSources = @($sources | Where-Object { $_.StartsWith('../RTL/') })
        $tbSources = @($sources | Where-Object { !$_.StartsWith('../RTL/') })
        $compileArgs = @('-modelsimini', $iniPath, '-work', 'work', '-sv',
            '-timescale', '1ns/1ps', '-L', 'mtiUvm', "+incdir=$uvmInclude", '+incdir=.')
        # Functional/SVA coverage is collected automatically. Instrument code
        # coverage only in RTL, not in testbench error paths and UVM macros.
        Invoke-Questa 'vlog' ($compileArgs + @('+cover=bcesft', '-l',
            (Join-Path $logsDir 'compile.log')) + $rtlSources)
        Invoke-Questa 'vlog' ($compileArgs + @('-l',
            (Join-Path $logsDir 'compile_tb.log')) + $tbSources)
    }
    $iniPath = 'build/modelsim.ini'
    $tests = @($Test)
    if ($Suite) {
        $tests = @('encoder_smoke_test', 'encoder_exhaustive_test',
            'encoder_alternate7_test', 'encoder_disparity_test',
            'encoder_invalid_k_test', 'encoder_idle_test', 'encoder_reset_test',
            'encoder_random_test', 'encoder_regression_test')
    }
    $summary = @()
    $coverageFiles = @()
    foreach ($testName in $tests) {
        $runName = "${testName}_seed${Seed}"
        $logPath = Join-Path $logsDir "$runName.log"
        $ucdbPath = (Join-Path $buildDir "$runName.ucdb").Replace('\','/')
        # Questa breaks on normal UVM $finish; require a successful report summary below.
        $doPath = Join-Path $buildDir "$runName.do"
        @"
onerror {quit -f -code 2}
onbreak {quit -f -code 0}
coverage save -onexit {$ucdbPath}
run -all
quit -f -code 0
"@ |
            Set-Content -LiteralPath $doPath
        $runArgs = @('-c', '-modelsimini', $iniPath, '-coverage', '-assertdebug',
            '-voptargs=+acc', '-onfinish', 'stop', '-L', 'mtiUvm',
            '-sv_seed', "$Seed", 'work.encoder_top', "+UVM_TESTNAME=$testName",
            "+RANDOM_COUNT=$RandomCount", '+UVM_MAX_QUIT_COUNT=20',
            '-l', $logPath, '-do', "do {$($doPath.Replace('\','/'))}")
        if ($LutPath) {
            $resolvedLut = (Resolve-Path -LiteralPath $LutPath).Path.Replace('\','/')
            $runArgs += "+ENCODER_LUT=$resolvedLut"
        }
        Invoke-Questa 'vsim' $runArgs
        $logText = Get-Content -LiteralPath $logPath -Raw
        if ($logText -notmatch 'UVM_ERROR\s*:\s*0\b' -or
            $logText -notmatch 'UVM_FATAL\s*:\s*0\b' -or
            $logText -match '\*\* (Error|Fatal):' -or
            $logText -notmatch '\[ENC_SCOREBOARD\]') {
            throw "Test $testName failed or did not reach the scoreboard summary; inspect $logPath"
        }
        $coverageFiles += $ucdbPath
        $summary += [pscustomobject]@{ test=$testName; seed=$Seed; status='PASS'; log=$logPath; coverage=$ucdbPath }
    }
    $summary | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $buildDir "results_seed$Seed.json")
    if ($coverageFiles.Count -gt 1) {
        Invoke-Questa 'vcover' (@('merge', (Join-Path $buildDir 'merged.ucdb')) + $coverageFiles)
        $reportDb = Join-Path $buildDir 'merged.ucdb'
    } else { $reportDb = $coverageFiles[0] }
    Invoke-Questa 'vcover' @('report', '-details', '-codeAll', '-cvg', '-assert', '-directive', '-output',
        (Join-Path $buildDir 'coverage.txt'), $reportDb)
    Write-Output "PASS: $($tests.Count) test(s); results in $buildDir"
} finally { Pop-Location }