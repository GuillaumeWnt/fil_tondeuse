# Directives de simulation SPICE (ngspice)
- Analyse fréquentielle standard : `.ac dec 100 10Hz 1MegHz`
- Analyse temporelle : `.tran 1u 50m`
- Déclaration obligatoire d'une référence à la terre (nœud 0).
- Tolérance de convergence : `reltol=0.001`