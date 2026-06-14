
### ADR-002: Azure SQL DB tier keuze

| Tier | vCores | Beschikbaarheid | Prijs |
|---|---|---|---|
| General Purpose | 4–80 | 99.99% (zone redundant) | € |
| Business Critical | 4–80 | 99.995% + read replica inbegrepen | €€€ |
| Hyperscale | 1–80 | Hoog, andere architectuur | €€ |

**Vul in**: Welke tier kies jij? Onderbouw met de RTO/RPO-vereisten.

Voor de database wordt gekozen voor Azure SQL Database General Purpose ter vervanging van de bestaande SQL Server 2014 Always On Availability Group.

**Waarom General Purpose:**
- RPO ~1-5 minuten via geo-redundante backups, wat ruim binnen de vereiste van ≤ 15 minuten valt
- RTO ~20-30 minuten bij failover, wat binnen de vereiste van ≤ 1 uur valt
- Zone-redundantie voor hoge beschikbaarheid binnen één regio
- Point-in-time restore tot 35 dagen
- Significant goedkoper dan Business Critical, wat in lijn ligt met de TCO-reductiedoelstelling van 20%

**Waarom niet Business Critical:**
Business Critical biedt een RTO van ~30 seconden en een RPO van quasi nul, maar kost ~€3.000+/maand tegenover €1.077/maand voor General Purpose. 
Gezien General Purpose de RTO/RPO-vereisten haalt, is deze meerprijs niet te verantwoorden.

**Waarom niet Hyperscale:**
Hyperscale is ontworpen voor databases van meerdere TB. 
Met een database van 500 GB biedt dit geen meerwaarde en voegt het onnodige complexiteit en kosten toe.

**Risico-aanvaarding:**
De RTO van ~20-30 minuten haalt de vereiste van ≤ 1 uur maar biedt geen ruime marge. 
Dit risico wordt bewust aanvaard op basis van de kostoptimalisatiedoelstelling. 
Bij strengere beschikbaarheidsvereisten in de toekomst is een upgrade naar Business Critical altijd een mogelijkheid.
