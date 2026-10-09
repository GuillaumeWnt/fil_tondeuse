# KiCAD Copilot Instructions

You are assisting with a KiCAD project. You must adhere to the following workflow guidelines and refer to the project's custom skills located in the `.agents/skills/` directory for detailed instructions on specific tasks.

## General Guidelines
- **Langue** : Toujours répondre et documenter en Français.
- **CAO Électronique** : Le projet utilise KiCad. Se référer aux standards de l'industrie pour les schémas et le PCB.
- **Composants** : Prioriser les composants traversants pour les prototypes, avant d'envisager une version CMS.
- **Documentation** : Expliquer clairement les calculs de dimensionnement (filtres, fréquences) pour faciliter la compréhension.
- **No Manual File Edits** : Never edit `.kicad_sch` or `.kicad_pcb` files manually as text. Always rely on KiCad tools or provided APIs.

## Available Workflows (See `.agents/skills/`)
If the user asks about the following tasks, consult the corresponding file for detailed MCP tool usage, rules, and best practices:
1. **KiCAD PCB Layout (`.agents/skills/kicad-pcb/SKILL.md`)**: Board outline, layer setup, trace routing, component placement, zones, and DRC.
2. **KiCAD Schematic (`.agents/skills/kicad-schematic/SKILL.md`)**: ERC, component insertion, net wiring, and schematic synchronization.
3. **KiCAD Library (`.agents/skills/kicad-library/SKILL.md`)**: Managing footprints and symbols.
4. **KiCAD Manufacture (`.agents/skills/kicad-manufacture/SKILL.md`)**: Exporting Gerbers, BOM, and positions for manufacturing.
5. **KiCAD Review (`.agents/skills/kicad-review/SKILL.md`)**: Hardware design review checklists and heuristics.
6. **Konnect (`.agents/skills/konnect/SKILL.md`)**: Core KiCad interaction guidelines.

## Quick Routing & Layout Reminders
- Draw the board outline (`Edge.Cuts`) before placement.
- Update from schematic and refresh libraries before routing.
- Group components by functional blocks. Place decoupling caps within 2mm of IC power pins.
- Run `run_drc()` frequently and `refill_zones` after any trace or footprint change.
- Use F.Cu and B.Cu for signals. Use zones for GND and power pours.
