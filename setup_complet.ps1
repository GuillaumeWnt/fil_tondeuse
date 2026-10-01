# Chemins d'accès aux composants natifs KiCad
$kicadBin = "C:\Users\guill\AppData\Local\Programs\KiCad\10.0\bin"
$kicadSitePackages = "$kicadBin\Lib\site-packages"

$pthContent = @"
$kicadSitePackages
import os; os.add_dll_directory(r'$kicadBin')
"@

# 1. ENVIRONNEMENT PRINCIPAL (Calculs, KiKit, KiBot, Outillage)
Write-Host "=== 1/3 Configuration du .venv principal ===" -ForegroundColor Cyan
if (-not (Test-Path ".venv")) {
    py -3.11 -m venv .venv
}
$pthContent | Set-Content -Path ".venv\Lib\site-packages\kicad.pth" -Encoding utf8
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

# 2. SERVEUR MCP SEEED STUDIO (Audit ERC/DRC)
Write-Host "=== 2/3 Configuration de .venv-mcp-seeed ===" -ForegroundColor Cyan
if (-not (Test-Path ".venv-mcp-seeed")) {
    py -3.11 -m venv .venv-mcp-seeed
}
$pthContent | Set-Content -Path ".venv-mcp-seeed\Lib\site-packages\kicad.pth" -Encoding utf8
.\.venv-mcp-seeed\Scripts\python.exe -m pip install --upgrade pip
.\.venv-mcp-seeed\Scripts\python.exe -m pip install "git+https://github.com/Seeed-Studio/kicad-mcp-server.git"

# 3. SERVEUR MCP MIXELPIXX (Édition PCB, Freerouting)
Write-Host "=== 3/3 Configuration de .venv-mcp-mixel ===" -ForegroundColor Cyan
if (-not (Test-Path ".venv-mcp-mixel")) {
    py -3.11 -m venv .venv-mcp-mixel
}
$pthContent | Set-Content -Path ".venv-mcp-mixel\Lib\site-packages\kicad.pth" -Encoding utf8
.\.venv-mcp-mixel\Scripts\python.exe -m pip install --upgrade pip
.\.venv-mcp-mixel\Scripts\python.exe -m pip install "git+https://github.com/mixelpixx/KiCAD-MCP-Server.git"

# 4. CONTRÔLE DE VALIDITÉ
Write-Host "=== Validation des liaisons pcbnew ===" -ForegroundColor Cyan
.\.venv\Scripts\python.exe -c "import pcbnew; print('[OK] .venv principal : pcbnew connecté')"
.\.venv-mcp-seeed\Scripts\python.exe -c "import pcbnew; print('[OK] .venv Seeed : pcbnew connecté')"
.\.venv-mcp-mixel\Scripts\python.exe -c "import pcbnew; print('[OK] .venv Mixel : pcbnew connecté')"

Write-Host "`nEnvironnement complet initialisé et prêt à l'emploi !" -ForegroundColor Green