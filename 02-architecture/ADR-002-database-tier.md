
### ADR-002: Azure SQL DB tier keuze

| Tier | vCores | Beschikbaarheid | Prijs |
|---|---|---|---|
| General Purpose | 4–80 | 99.99% (zone redundant) | € |
| Business Critical | 4–80 | 99.995% + read replica inbegrepen | €€€ |
| Hyperscale | 1–80 | Hoog, andere architectuur | €€ |

**Vul in**: Welke tier kies jij? Onderbouw met de RTO/RPO-vereisten.

Voor de applicatie is Azure SQL Database General Purpose de meest geschikte keuze, omdat deze met een Auto-Failover Group voor geo-replicatie binnen Europa al ruimschoots voldoet aan de gestelde beschikbaarheidsvereisten (RTO ≤ 1 uur, RPO ≤ 15 minuten). Deze tier biedt volledig beheerde hoge beschikbaarheid, automatische failover en regionale disaster recovery zonder de extra complexiteit en hogere kosten van zwaardere tiers. Business Critical is vooral bedoeld voor workloads met extreem lage latency en vrijwel onmiddellijke failover via meerdere synchrone replicas, wat volgens mij niet nodig is voor een planning applicatie. Hyperscale is juist geoptimaliseerd voor zeer grote databases en snelle opslag-schaalbaarheid, niet voor het verbeteren van RTO/RPO in typische OLTP-planningssystemen, en brengt extra architecturale complexiteit met zich mee die hier niet nodig is. Kortom, General Purpose levert de vereiste betrouwbaarheid en geo-redundantie op een eenvoudigere en kostenefficiëntere manier, terwijl het jullie DR-doelen nog steeds ruimschoots haalt.

RTO ≤ 1 uur — General Purpose volstaat
Met een failover group haalt General Purpose officieel een RTO van 1 uur — exact de projectvereiste. Business Critical haalt RTO van 30 seconden, maar dat niveau is niet vereist en rechtvaardigt de ~3× hogere kostprijs niet.

Bron: Understanding business continuity solutions for Azure SQL PaaS services — sqlshack.com
https://www.sqlshack.com/understanding-business-continuity-solutions-for-azure-sql-paas-services/
"Failover groups support 1 hour as RTO and 5 seconds as RPO."

RPO ≤ 15 minuten — gegarandeerd via active geo-replication
https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql
Azure SQL Database neemt automatisch transaction log backups approximately every 10 minutes. Met active geo-replication worden transactielogboeken continu gerepliceerd naar de secundaire regio, met een officiële RPO van 5 seconden.

Bron: Automated backups — Azure SQL Database | Microsoft Learn
"Transaction log backups approximately every 10 minutes. The exact frequency of transaction log backups is based on the compute size and the amount of database activity."

Beide mechanismen — log backups en geo-replication — vallen ruim binnen de vereiste RPO van 15 minuten.
Business Critical is overkill
Business Critical levert RTO ~30 seconden en RPO ~0 seconden — een factor 100 beter dan vereist op RTO-vlak. De enige situatie waarin Business Critical te rechtvaardigen is, is wanneer RTO < 5 minuten vereist is of wanneer een ingebouwde read replica noodzakelijk is voor rapportagedoeleinden. Beide zijn niet van toepassing voor Contoso in Fase 2.

Bron: Understanding and leveraging Azure SQL Database's SLA | Microsoft Azure Blog
"We provide SLAs of five seconds for RPO and 30 seconds for RTO [for Business Critical with geo-replication]."

Hyperscale is niet van toepassing
Hyperscale is ontworpen voor databases die moeten schalen tot 100 TB. De Contoso-database bedraagt 500 GB zonder verwachte snelle groei. Bovendien is terugkeer naar een andere tier na migratie naar Hyperscale niet mogelijk zonder volledige export/import — een onomkeerbare architectuurkeuze die niet te verantwoorden is voor dit scenario.
