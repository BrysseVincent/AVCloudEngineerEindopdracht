
### ADR-002: Azure SQL DB tier keuze

| Tier | vCores | Beschikbaarheid | Prijs |
|---|---|---|---|
| General Purpose | 4–80 | 99.99% (zone redundant) | € |
| Business Critical | 4–80 | 99.995% + read replica inbegrepen | €€€ |
| Hyperscale | 1–80 | Hoog, andere architectuur | €€ |

**Vul in**: Welke tier kies jij? Onderbouw met de RTO/RPO-vereisten.

Voor de databank kiezen we voor Azure SQL Database in de General Purpose tier met zone-redundantie ingeschakeld.
De bestaande omgeving draait op SQL Server 2014 met Always On (2 nodes, ~500 GB). De migratiedoelstellingen vereisen een RTO ≤ 1 uur en RPO ≤ 15 minuten, samen met een TCO-reductie van minimaal 20% over 3 jaar.

General Purpose biedt:
RPO van ~1-5 minuten via automatische geo-redundante backups — ruim binnen de vereiste van 15 minuten
RTO van ~20-30 minuten bij failover — dit valt binnen de vereiste van 1 uur, maar zit aan de ondergrens
Zone-redundantie voor hoge beschikbaarheid binnen één regio
Automatische backups met point-in-time restore tot 35 dagen
Ingebouwde HA zonder extra configuratie, ter vervanging van de huidige Always On setup

Waarom niet Business Critical:
Business Critical biedt een RTO van ~30 seconden en een RPO van quasi nul via in-memory replica's. Dit overtreft de projectvereisten ruimschoots, maar komt met een significant hogere kostprijs. Gezien de doelstelling van TCO-reductie van minimaal 20% is deze meerprijs moeilijk te verantwoorden wanneer General Purpose de gestelde RTO/RPO-vereisten haalt.

Waarom niet Hyperscale:
Hyperscale is ontworpen voor zeer grote databases (meerdere TB) of workloads die extreem snelle schaalbaarheid vereisen. Met een database van ~500 GB biedt Hyperscale geen relevante meerwaarde en voegt het onnodige complexiteit en kost toe.

Risico-aanvaarding:
De RTO van General Purpose (~20-30 min) haalt de vereiste van ≤ 1 uur, maar biedt geen ruime marge. Dit risico wordt bewust aanvaard op basis van de kostoptimalisatiedoelstelling. Mocht de applicatie in de toekomst strengere beschikbaarheidsvereisten krijgen, dan vormt een upgrade naar Business Critical een logische volgende stap.
