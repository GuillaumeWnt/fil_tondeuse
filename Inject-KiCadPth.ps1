[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$VenvPath = ".venv"
)

$ErrorActionPreference = "Stop"

function Find-KiCadBin {
    # 1. Variable d'environnement explicite
    if ($env:KICAD_BIN -and (Test-Path (Join-Path $env:KICAD_BIN "kicad.exe"))) {
        return $env:KICAD_BIN
    }

    # 2. Registre Windows (installeur machine ou utilisateur)
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $installed = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -like "KiCad *" -and $_.InstallLocation } |
        Sort-Object DisplayName -Descending |
        Select-Object -First 1

    if ($installed) {
        $bin = Join-Path $installed.InstallLocation "bin"
        if (Test-Path (Join-Path $bin "kicad.exe")) { return $bin }
    }

    # 3. Dossiers standards (Program Files & LocalAppData)
    $candidates = @(
        "$env:ProgramFiles\KiCad",
        "${env:ProgramFiles(x86)}\KiCad",
        "$env:LOCALAPPDATA\Programs\KiCad"
    )

    foreach ($base in $candidates) {
        if (-not (Test-Path $base)) { continue }

        # Installation a la racine du dossier
        if (Test-Path (Join-Path $base "bin\kicad.exe")) {
            return (Join-Path $base "bin")
        }

        # Sous-dossiers de versions (ex: 8.0, 7.0)
        $bin = Get-ChildItem -Path$base -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^\d+(\.\d+)*$' } |
            Sort-Object { [version]$_.Name } -Descending |
            ForEach-Object { Join-Path $_.FullName "bin" } |
            Where-Object { Test-Path (Join-Path $_ "kicad.exe") } |
            Select-Object -First 1

        if ($bin) { return$bin }
    }

    throw "Impossible de localiser KiCad sur cette machine. Definissez la variable `$env:KICAD_BIN."
}

# --- 1. Verification du venv cible ---
$resolvedVenv = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($VenvPath)
$sitePackages = Join-Path $resolvedVenv "Lib\site-packages"
$pythonExe = Join-Path $resolvedVenv "Scripts\python.exe"

if (-not (Test-Path $pythonExe)) {
    Write-Error "Environnement virtuel introuvable dans '$resolvedVenv'. Verifiez le chemin fourni."
    exit 1
}

if (-not (Test-Path $sitePackages)) {
    New-Item -ItemType Directory -Path $sitePackages -Force | Out-Null
}

# --- 2. Detection de KiCad ---
$kicadBin = Find-KiCadBin
$kicadSitePackages = Join-Path $kicadBin "Lib\site-packages"
Write-Host "KiCad localise : $kicadBin" -ForegroundColor Gray

# --- 3. Generation du kicad.pth (UTF-8 sans BOM) ---
$pthLines = @(
    $kicadBin,
    $kicadSitePackages,
    "import os; hasattr(os, 'add_dll_directory') and os.add_dll_directory(r'$kicadBin')"
)
$pthContent = $pthLines -join [Environment]::NewLine

$targetPth = Join-Path $sitePackages "kicad.pth"
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($targetPth, $pthContent, $utf8NoBom)

Write-Host "Fichier injecte : $targetPth" -ForegroundColor Gray

# --- 4. Validation immediate et test fonctionnel ---
$testCmd = @'
import pcbnew
version = pcbnew.GetBuildVersion()
b = pcbnew.BOARD()
print(f"[OK] KiCad {version} charge et operationnel")
'@

$prevNativePref = $PSNativeCommandUseErrorActionPreference
$PSNativeCommandUseErrorActionPreference = $false
try {
    $output = & $pythonExe -c $testCmd 2>&1
    $exitCode = $LASTEXITCODE
} finally {
    $PSNativeCommandUseErrorActionPreference = $prevNativePref
}

if ($exitCode -eq 0) {
    Write-Host "$output dans $VenvPath !" -ForegroundColor Green
} else {
    Write-Host "[ERREUR] Echec du test pcbnew dans $VenvPath :" -ForegroundColor Red
    Write-Host ($output -join "`n") -ForegroundColor Red
    exit 1
}