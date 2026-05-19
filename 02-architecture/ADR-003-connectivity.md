### ADR-003: VPN Gateway vs ExpressRoute

| | VPN Gateway | ExpressRoute |
|---|---|---|
| Bandbreedte | Tot 10 Gbps | 50 Mbps – 100 Gbps |
| Latency | Variabel (internet) | Laag (dedicated circuit) |
| Kost | Laag (€140–€700/mnd) | Hoog (€500–€5000+/mnd) |
| Gebruik | Dev/test, lagere eisen | Productie, hoge eisen |

**Vul in**: Welke kies jij voor Contoso? Motiveer.

Het workloadprofiel van Contoso vereist geen dedicated circuit. De enige datastromen over de hybride verbinding zijn nachtelijke SAP-batches (laag volume), Entra Connect sync en beheerverkeer — stuk voor stuk lichtgewicht en niet latency-kritisch. VPN Gateway over internet volstaat ruimschoots.
ExpressRoute is enkel te rechtvaardigen bij hoge bandbreedtevereisten (> 1 Gbps), strikte latency-eisen voor realtime workloads, of wanneer grote datahoeveelheden continu tussen on-prem en Azure stromen. Geen van deze gevallen is van toepassing.
