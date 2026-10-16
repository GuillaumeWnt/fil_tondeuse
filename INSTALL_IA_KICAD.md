# Guide d'Installation et Configuration de l'IA pour KiCad (MCP Konnect & Seeed)

Ce document récapitule la configuration nécessaire pour que les assistants IA (Gemini/Antigravity, Claude, Copilot) puissent interagir directement avec vos projets KiCad via le protocole MCP (Model Context Protocol).

---

## 1. Configuration de KiCad et du Plugin Konnect

Pour que l'IA puisse "voir" et modifier votre PCB en temps réel, elle utilise un lien appelé **IPC** (Inter-Process Communication).

1. **Activer l'API de KiCad** :
   - Ouvrez KiCad.
   - Allez dans `Préférences` > `Préférences...`
   - Cherchez la section `Plugins` (ou `Serveur API` / `IPC`).
   - Cochez **Enable KiCad API** (Activer l'API KiCad).
   - KiCad va afficher une adresse locale (ex: `ipc://C:\Users\...\Temp\kicad\api.sock`). **Copiez cette adresse**.

2. **Configurer Konnect** :
   - Dans KiCad, allez dans `Outils` (Tools) > `External Plugins` > `Konnect Settings`.
   - Collez l'adresse copiée précédemment dans le champ **IPC Socket**.
   - Assurez-vous que le chemin vers `kicad-cli.exe` est correct.
   - Cliquez sur **Save**.
   - *Note : Vous n'avez PAS besoin de cliquer sur "Start Server" ici. L'IA lancera le serveur elle-même en arrière-plan via le mode `stdio`.*

---

## 2. Déclaration des serveurs MCP

La déclaration des serveurs indique à l'IA comment lancer les outils.

### Fichier principal (`.vscode/mcp.json`)
Ce fichier est utilisé par des extensions comme Claude (Roo Code). Il déclare les exécutables :
* **Konnect** : Utilise le chemin absolu vers son exécutable d'installation globale (ex: `C:\...\com_github_mixelpixx_konnect\bin\konnect.exe`).
* **Seeed** : Utilise un **chemin relatif** pointant vers un environnement virtuel local au projet (ex: `.venv-mcp-seeed\Scripts\python.exe`).

### Synchronisation pour Antigravity (`.agents/mcp_config.json`)
Antigravity utilise son propre fichier de configuration. Pour éviter de faire le travail en double, un script PowerShell est fourni dans le projet :
```powershell
.\.agents\sync-mcp.ps1
```
Il suffit de lancer ce script après chaque modification de `.vscode/mcp.json` pour mettre à jour Antigravity instantanément. **Pensez à recharger la fenêtre de l'éditeur** après l'opération.

### Création de l'environnement virtuel (Seeed)
Les dossiers `.venv` ne doivent **jamais** être copiés d'un PC à l'autre. Si vous déplacez le projet ou si un collègue le clone, il faut recréer l'environnement de Seeed à la racine :
```powershell
uv venv .venv-mcp-seeed --python 3.11.5
uv pip install --python .venv-mcp-seeed kicad_mcp_server
```

*(Note : Si Seeed renvoie une erreur `rich.traceback`, installez le paquet `rich` dans le Python interne de KiCad : `<Chemin_KiCad_10>\bin\python.exe -m pip install rich`).*

---

## 3. Directives et Architecture pour l'IA

Afin de donner le contexte métier et les bons réflexes aux IA, une arborescence précise est respectée dans le projet :

### `GEMINI.md` (Racine)
C'est le fichier des **règles absolues et globales** du projet (ex: toujours parler en Français, préférer les composants traversants, obligation de justifier les calculs). Antigravity le lit en priorité.

### Le dossier `.agents/` (Antigravity & Claude)
* **`.agents/skills/`** : Contient les "Compétences" (ex: `kicad-pcb/SKILL.md`). Ce sont des modes d'emploi détaillés qui expliquent à l'IA *comment* utiliser les outils MCP de KiCad (ne pas router avant de faire l'outline, comment gérer les zones de cuivre, etc.). L'IA les charge dynamiquement quand le sujet est abordé.
* **`.agents/agents/`** : Définit des "Subagents" spécialisés (ex: un auditeur qui fait exclusivement de la revue de conception schématique).

### Le dossier `.github/` (GitHub Copilot)
* **`.github/copilot-instructions.md`** : Fournit le contexte général spécifiquement pour l'extension GitHub Copilot Chat. Ce fichier force Copilot à respecter les mêmes règles générales et l'invite à aller lire les documents dans `.agents/skills/` s'il a besoin de détails sur les workflows KiCad, pour éviter de le surcharger d'informations inutiles en permanence.

