
### ADR-002: Azure SQL DB tier keuze

| Tier | vCores | Beschikbaarheid | Prijs |
|---|---|---|---|
| General Purpose | 4–80 | 99.99% (zone redundant) | € |
| Business Critical | 4–80 | 99.995% + read replica inbegrepen | €€€ |
| Hyperscale | 1–80 | Hoog, andere architectuur | €€ |

**Vul in**: Welke tier kies jij? Onderbouw met de RTO/RPO-vereisten.

Voor de applicatie is Azure SQL Database General Purpose de meest geschikte keuze, omdat deze met een Auto-Failover Group voor geo-replicatie binnen Europa al ruimschoots voldoet aan de gestelde beschikbaarheidsvereisten (RTO ≤ 1 uur, RPO ≤ 15 minuten). Deze tier biedt volledig beheerde hoge beschikbaarheid, automatische failover en regionale disaster recovery zonder de extra complexiteit en hogere kosten van zwaardere tiers. Business Critical is vooral bedoeld voor workloads met extreem lage latency en vrijwel onmiddellijke failover via meerdere synchrone replicas, wat volgens mij niet nodig is voor een planning applicatie. Hyperscale is juist geoptimaliseerd voor zeer grote databases en snelle opslag-schaalbaarheid, niet voor het verbeteren van RTO/RPO in typische OLTP-planningssystemen, en brengt extra architecturale complexiteit met zich mee die hier niet nodig is. Kortom, General Purpose levert de vereiste betrouwbaarheid en geo-redundantie op een eenvoudigere en kostenefficiëntere manier, terwijl het jullie DR-doelen nog steeds ruimschoots haalt.
