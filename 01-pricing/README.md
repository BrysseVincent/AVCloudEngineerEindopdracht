# 01 — azure prijsinschatting

> **Deliverable**: Azure-kostenraming + 3-jaar TCO-vergelijking  
> **Gewicht**: 20% van de totale eindopdrachtscore

---

## opdracht

Maak een volledige **Azure-prijsinschatting** voor de gemigreerde Contoso Manufacturing-applicatie. Je inschatting moet zowel de **maandelijkse Azure-kost** als een **3-jaar TCO-vergelijking** bevatten.

---

## vereisten

### ✅ Verplicht op te nemen

- [ ] Alle Azure resources die je in de architectuur hebt gedefinieerd (zie `../02-architecture/`)
- [ ] Maandelijkse kostentabel per resource
- [ ] Subtotalen per categorie (compute, netwerk, opslag, monitoring, ...)
- [ ] 3-jaar TCO: on-premises (verlengingskosten) vs Azure
- [ ] Onderbouwing van elke SKU-keuze
- [ ] **Azure Hybrid Benefit** toegepast waar relevant
- [ ] **Reserved Instances (1 jaar)** berekening als alternatief voor Pay-as-you-go
- [ ] Dev/Test omgevingen meegenomen (lagere kost via Dev/Test subscriptions)
- [ ] Excel-bijlage (`pricing-estimate.xlsx`) als bronbestand

---

## richtlijnen & aannames

### regio
Gebruik **West Europe (Amsterdam)** als primaire regio en **North Europe (Dublin)** als secondary/DR-regio voor geo-redundante resources.

> 💡 Tip: West Europe is doorgaans 5–10% duurder dan North Europe. Overweeg welke resources echt in West Europe moeten staan.

### aannames te documenteren

Documenteer in je README **elke aanname** die je maakt, zoals:
- Aantal gebruikers (concurrent en totaal)
- Datatransfer volumes (in/uit)
- Backup retentie periode
- Verwachte database groei per jaar
- Peak vs. average CPU-gebruik

### Azure Hybrid Benefit (AHB)

De klant beschikt over:
- Windows Server Datacenter licenties (Software Assurance)
- SQL Server Enterprise licenties (Software Assurance)

Bereken de besparing die AHB oplevert op de Azure-resources.

---

## te schatten resources (minimaal)

Onderstaande tabel is een **startpunt** — je architectuurkeuzes kunnen afwijken. Onderbouw elke keuze.

### Compute

| Resource | SKU voorstel | Regio | Opmerkingen |
|---|---|---|---|
| App Service Plan (Web) | P2v3 of P3v3 | West Europe | Minimaal 2 instances voor HA |
| App Service Plan (API/Worker) | P1v3 | West Europe | Windows services refactored als WebJobs of Functions |
| Azure Functions (optioneel) | Consumption of Premium | West Europe | Voor batch jobs |

### Database

| Resource | SKU voorstel | Regio | Opmerkingen |
|---|---|---|---|
| Azure SQL Database | Business Critical of General Purpose | West Europe | 500 GB, onderbouw tier keuze |
| SQL Geo-replication | — | North Europe | Secondary read replica voor DR |

### Netwerk

| Resource | Regio | Opmerkingen |
|---|---|---|
| Azure Firewall | West Europe | Premium tier voor IDPS |
| Application Gateway + WAF | West Europe | WAF_v2 |
| VPN Gateway of ExpressRoute | West Europe | Keuze onderbouwen |
| Private DNS Zones | Global | Per PaaS-dienst |
| Bandwidth (egress) | — | Schat maandelijks dataverkeer |

### Security & Identity

| Resource | Opmerkingen |
|---|---|
| Microsoft Entra ID (P1 of P2) | Per gebruiker, onderbouw tier |
| Key Vault | Standard of Premium (HSM) |
| Defender for Cloud | Welke plans? Onderbouw per resource type |

### Monitoring

| Resource | Opmerkingen |
|---|---|
| Log Analytics Workspace | Schat GB/dag aan logs |
| Application Insights | Per applicatie |
| Azure Monitor (alerts, dashboards) | Inbegrepen / additief |

### Storage

| Resource | SKU | Opmerkingen |
|---|---|---|
| Storage Account (blobs, bestanden) | LRS of GRS, Hot tier | Rapporten, uploads |
| Azure Backup | — | Koppel aan RPO/RTO vereisten |

---

## 3-jaar TCO vergelijking

### on-premises verlengingskosten (referentiescenario)

Bereken wat het zou kosten om de huidige on-prem omgeving te renoveren. Gebruik onderstaande indicatieve bedragen als basis (pas aan en onderbouw):

| Component | Eenmalige kost (schatting) | Jaarlijkse kost (schatting) |
|---|---|---|
| Hardware vervanging (servers × 9) | € 180.000 | € 18.000 (onderhoud) |
| Windows Server 2022 licenties | € 25.000 | — |
| SQL Server 2022 licenties | € 60.000 | — |
| F5 vervanging (load balancer) | € 35.000 | € 5.000 |
| Netwerkapparatuur refresh | € 20.000 | € 3.000 |
| Datacenter hosting (co-lo of on-prem) | — | € 30.000/jaar |
| IT-beheer (FTE, deels) | — | € 40.000/jaar |
| **Totaal** | **≈ € 320.000** | **≈ € 96.000/jaar** |

> ⚠️ Dit zijn voorbeeldcijfers. Gebruik deze als startpunt en pas aan op basis van je eigen research.

### verwachte structuur TCO-tabel

```
                  Jaar 1      Jaar 2      Jaar 3      TOTAAL 3J
────────────────────────────────────────────────────────────────
ON-PREMISES
  Capex             €320.000        €0          €0     €320.000
  Opex/jaar          €96.000    €96.000     €96.000    €288.000
  Subtotaal         €416.000    €96.000     €96.000    €608.000

AZURE (Pay-as-you-go)
  Maandkost × 12     €X.XXX      €X.XXX      €X.XXX
  Subtotaal          €X.XXX      €X.XXX      €X.XXX    €XX.XXX

AZURE (Reserved 1J, AHB)
  Subtotaal          €X.XXX      €X.XXX      €X.XXX    €XX.XXX

BESPARING (Azure vs On-prem)                            €XX.XXX (XX%)
────────────────────────────────────────────────────────────────
```

---

## te gebruiken tools

| Tool | Link | Gebruik |
|---|---|---|
| Azure Pricing Calculator | https://azure.microsoft.com/pricing/calculator/ | Maandelijkse Azure-kost |
| Azure TCO Calculator | https://azure.microsoft.com/pricing/tco/calculator/ | On-prem vs Azure vergelijking |
| Azure Hybrid Benefit (rekentool) | https://azure.microsoft.com/pricing/hybrid-benefit/ | AHB besparing |

---

## wat je inlevert

```
01-pricing/
├── README.md              ← dit bestand, volledig ingevuld
└── pricing-estimate.xlsx  ← Excel met alle berekeningen
```

### inhoud README (volledig ingevuld)

1. **Aannames** — gedocumenteerde uitgangspunten
2. **Resource overzicht** — tabel met elke resource, SKU, prijs/maand
3. **Maandelijks kostenoverzicht** — gegroepeerd per categorie
4. **3-jaar TCO tabel** — vergelijking on-prem vs Azure
5. **Optimalisatieadvies** — Reserved Instances, AHB, Auto-scale
6. **Risico's** — onzekerheden in de inschatting
   
---
## beoordelingscriteria (20 punten)

| Criterium | Punten |
|---|---|
| Alle vereiste resources aanwezig en geraamd | 5 |
| Correcte SKU-keuzes met onderbouwing | 4 |
| 3-jaar TCO vergelijking correct uitgewerkt | 4 |
| Azure Hybrid Benefit correct toegepast | 3 |
| Aannames duidelijk gedocumenteerd | 2 |
| Optimalisatieadvies (Reserved Instances, ...) | 2 |

---

_Ga verder naar [`../02-architecture/README.md`](../02-architecture/README.md)_

---

## 1. Aannames - gedocumenteerde uitgangspunten

Onderstaande aannames zijn gedocumenteerd als uitgangspunt voor de prijsinschatting.
Alle bedragen zijn exclusief BTW en gebaseerd op West Europe als primaire regio.

### Gebruikers en gebruik

| Categorie | Aanname | Motivering |
|---|---|---|
| Totaal aantal gebruikers | 450 medewerkers | Opgegeven in opdracht |
| Applicatie gebruikers | 200 medewerkers | Schatting aantal gebruikers die applicatie zal gebruiken|
| Gelijktijdige gebruikers | ~50 concurrent users | Productieplanningsapplicatie - niet iedereen tegelijk actief |
| Piekgebruik | Werkdagen 7u–18u | Productieplanningsperiodes tijdens werkuren |
| Peak CPU gebruik | ~60% tijdens werkuren | Buiten werkuren minimale belasting |
| Beschikbaarheid | 99,9% tijdens werkuren | Productieplanning niet 24/7 kritiek |

### Database

| Categorie | Aanname | Motivering |
|---|---|---|
| Huidige database grootte | ~500 GB | Opgegeven in opdracht |
| Verwachte groei per jaar | ~10% (~50 GB/jaar) | Historische productiedata groeit geleidelijk |
| Database grootte jaar 3 | ~650 GB | 500 GB + 3 × 50 GB |

### Netwerk

| Categorie | Aanname | Motivering |
|---|---|---|
| Datatransfer egress | ~300 GB/maand | Webverkeer (~130 GB) + SAP batch (~20 GB) + rapporten (~50 GB) + geo-replicatie (~100 GB - Wijzigingsratio: 0.2% - 1% per dag) |
| VPN bandbreedte | ~15 Mbps gemiddeld | 3 vestigingen, interne applicatie |

### Opslag en backup

| Categorie | Aanname | Motivering |
|---|---|---|
| Backup retentie | 35 dagen | Conform RPO/RTO vereisten |
| Storage Account grootte | ~1 TB | Rapporten, uploads, file shares ter vervanging van NAS |
| Log Analytics | ~10 GB/dag | App Service, SQL, Firewall en NSG logs |

### Licenties en omgevingen

| Categorie | Aanname | Motivering |
|---|---|---|
| Azure Hybrid Benefit | Van toepassing | Klant beschikt over Windows Server Datacenter + SQL Server Enterprise met Software Assurance |
| Reserved Instances | 1 jaar | Voldoende zekerheid over workload voor 1-jarige reservering |
| Omgevingen | 3 (prd, tst, dev) | Dev/Test via Dev/Test subscription aan lagere tarieven |
| Dev/Test SKUs | tst op S2, dev op B1 | On-demand opgestart via Dev/Test subscription |

### Algemeen

| Categorie | Aanname | Motivering |
|---|---|---|
| Primaire regio | West Europe (Amsterdam) | Dichtstbij Belgische vestigingen |
| DR regio | North Europe (Dublin) | Geo-redundantie voor SQL backups |
| Prijspeil | Juni 2026 | Prijzen kunnen wijzigen - jaarlijkse herziening aanbevolen |
| Wisselkoers | € (EUR) | Alle prijzen in euro |

## 2-3. Resource overzicht met Maandelijks kostenoverzicht - tabel met elke resource, SKU, prijs/maan + gegroepeerd per categorie

### Compute

| Resource | SKU | Regio | Instances | Prijs/maand (PAYG) | Prijs/maand (1J RI) |
|---|---|---|---|---|---|
| App Service Plan (Web + API) | P2v3 Windows | West Europe | 2 | € 848,89 | € 633,04 |
| Azure Functions (Scheduler, Processor, Reporter) | Consumption (inbegrepen in ASP) | West Europe | - | € 0 | € 0 |
| Virtual Machine (Jump VM) | B2ms, Windows (AHB) | West Europe | 1 | € 65,30 | € 35,26 |
| **Subtotaal Compute** | | | | **€ 914,19** | **€ 668,30** |

### Database

| Resource | SKU | Regio | Prijs/maand (PAYG) | Prijs/maand (PAYG + AHB) | Prijs/maand (1J RI) | Prijs/maand (1J RI + AHB) |
|---|---|---|---|---|---|---|
| Azure SQL Database | General Purpose, 4 vCores, 500 GB | West Europe | € 1.077,09 | € 826,02 | € 766,16 | € 590,40 |
| SQL Geo-redundante backup (RA-GRS) | Inbegrepen | North Europe | € 0 | € 0 | € 0 | € 0 |
| **Subtotaal Database** | | | **€ 1.077,09** | **€ 826,02** |  **€ 766,16** | **€ 590,40** |

### Netwerk

| Resource | SKU | Regio | Prijs/maand |
|---|---|---|---|
| Azure Firewall | Premium (IDPS) | West Europe | € 1.102,91 |
| Application Gateway + WAF | WAF_v2 | West Europe | € 327,97 |
| VPN Gateway | VpnGw1AZ (zone-redundant) | West Europe | € 145,62 |
| Azure Bastion | Basic | West Europe | € 119,30 |
| Private DNS Zones + DNS Private Resolver | 5 zones + Inbound/Outbound Endpoint | Global | € 322,51 |
| Datatransfer egress | ~300 GB/maand | - | € 14,97 |
| **Subtotaal Netwerk** | | | **€ 2.033,28** |

### Security & Identity

| Resource | SKU | Prijs/maand |
|---|---|---|
| Microsoft Entra ID | P1 × 443 gebruikers + P2 × 7 gebruikers | € 2.591,49 |
| Key Vault | Standard | € 2,74 |
| Defender for SQL | € 15/server | € 15,00 |
| Defender for App Service | € 15/plan | € 15,00 |
| Defender for Storage | Per transactie | € 10,00 |
| Defender for Key Vault | € 0,02/10k operaties | € 1,00 |
| Defender for Resource Manager | € 4/subscription | € 4,00 |
| **Subtotaal Security** | | **€ 2.639,23** |

### Monitoring

| Resource | SKU | Prijs/maand |
|---|---|---|
| Log Analytics Workspace | 10 GB/dag, 90 dagen retentie | € 825,74 |
| Application Insights | Per request (workspace-based) | € 1,50 |
| **Subtotaal Monitoring** | | **€ 827,24** |

### Storage & Backup

| Resource | SKU | Prijs/maand |
|---|---|---|
| Storage Account | GRS, Hot tier, 1 TB | € 52,82 |
| Azure Backup (Jump VM) | Standaard policy, 35 dagen, LRS | € 12,72 |
| **Subtotaal Storage** | | **€ 65,54** |

---

### Totaaloverzicht

| Scenario | Prijs/maand | Prijs/jaar |
|---|---|---|
| **Pay-as-you-go** | **€ 7.556,57** | **€ 90.678,84** |
| **Pay-as-you-go + AHB** | **€ 7.305,50** | **€ 87.666,00** |
| **1 jaar Reserved + AHB** | **€ 6.823,99** | **€ 81.887,88** |


---

## SKU-keuze onderbouwing

### App Service Plan - P2v3 (Windows, 2 instances)

De bestaande web- en applicatie servers (WEB01/WEB02 + APP01/APP02) worden vervangen door één App Service Plan P2v3 met 2 instances. 
Omdat applicatie is vooral read-heavy is en de Windows services gemigreerd worden naar Azure functions is een afzonderlijk App Service Plan voor de API niet nodig.
Web en API delen dezelfde HA-vereisten en hebben vergelijkbare performance-karakteristieken.
P2v3 volstaat omdat Azure efficiënter omgaat met resources dan de dedicated on-premises servers. 
Door Auto-scale kan bij piekbelasting het app service plan automatisch opgeschaald worden tot 5 instances, waarna de capaciteit vergelijkbaar is met de huidige on-premises omgeving.

---

### Azure Functions - App Service Plan (inbegrepen)

De drie Windows Services (scheduler, processor, reporter) worden gemigreerd naar Azure Functions op het bestaande P2v3 App Service Plan. 
De keuze voor Azure Functions is ingebouwde integratie met Application Insights, Vnet-integratie en toekomstbestendigheid.
Azure Functions en Web/API zullen dezelfde CPU en geheugen delen van het App service plan.
Gezien de Azure functions enkel 's nachts zullen draaien, wanneer er minimale belasting is, zal dit geen probleem geven.
Op deze manier worden er ook kosten vermeden.

---

### Azure SQL Database - General Purpose, 4 vCores

De bestaande SQL Server 2014 Always On Availability Group (SQL01/SQL02) wordt vervangen door Azure SQL Database General Purpose. 
De applicatie is vooral read-heavy met een 50-tal gelijktijdige gebruikers tijdens werkuren (7u-18u) en een nachtelijke batch zonder gebruikers. 
Geschat piekverbruik bedraagt 500 tot 1.000 IOPS tijdens werkuren, wat ruim binnen de General Purpose limiet van 1.280 IOPS op 4 vCores. 
RA-GRS backup storage voorziet geo-redundante backups naar North Europe met een RPO van 1-5 minuten en een RTO van 20-30 minuten, wat binnen de migratiedoelstellingen valt (RPO ≤ 15 min, RTO ≤ 1 uur).

Business Critical werd overwogen maar niet gekozen omwille van de significant hogere kostprijs (~€ 3.000+/maand vs € 1.077/maand) zonder dat de RTO/RPO-vereisten dit vereisen.

---

### Azure Firewall - Premium

Azure Firewall Premium werd gekozen boven Standard omdat het twee belangrijke extra functies heeft, naamelijk IDPS en TLS-inspectie.
IDPS detecteert en blokkeert bekende aanvallen op het netwerk.
TLS-inspectie controleert versleuteld HTTPS-verkeer op malware. 
Beide maatregelen zijn relevant voor NIS2-compliance.

---

### Application Gateway - WAF_v2

WAF_v2 vervangt de verouderde F5 BIG-IP en biedt Layer 7 load balancing met ingebouwde WAF-bescherming (OWASP 3.2).
WAF_v2 werd gekozen over v1 omdat het automatisch schaalt, zone-redundant is.

---

### VPN Gateway - VpnGw1AZ

VPN Gateway wordt gekozen boven ExpressRoute (zie ADR-003). 
VpnGw1AZ is zone-redundant en bevat 10 S2S tunnels, wat meer dan voldoende is voor de 3 vestigingen van Contoso.

---

### Jump VM — B2ms (Windows, 1 jaar Reserved, AHB)

Een jump VM in management subnet biedt toegang tot Azure SQL Database via SSMS voor database administrators en developers. 
De Private Endpoint van SQL is niet bereikbaar vanuit het on-premises netwerk zonder een VM in het VNet. 
B2ms is voldoende voor het gebruik van SSMS. 
Auto-shutdown kan geconfigureerd wordem om kostoptimalisatie te realiseren buiten werkuren.

---

### Microsoft Entra ID — P1 (443 users) + P2 (7 users)

Entra ID P1 wordt toegewezen aan alle 450 medewerkers voor MFA en Conditional Access, wat verplicht is voor de NIS2-compliance. 
IT-beheerders en Security Analysts (±7 personen) krijgen Entra ID P2 voor Privileged Identity Management (PIM) en Identity Protection. 
Dit volgt het least privilege principe, ook op licentieniveau.

> Indien Contoso over Microsoft 365 Business Premium beschikt, is Entra ID P1 reeds inbegrepen en bedraagt de kost enkel de P2 add-on voor 7 gebruikers (€ 3,00/gebruiker/maand supplement).

---

### Storage Account — GRS, Hot tier, 1 TB

Azure Storage Account vervangt de on-premises NAS. 
GRS redundantie zorgt voor geo-redundante opslag naar North Europe. 
Hot tier is gekozen omdat rapporten en uploads regelmatig worden geraadpleegd. 
Lifecycle Management wordt geconfigureerd om oudere bestanden automatisch naar Cool of Cold tier te verplaatsen voor kostoptimalisatie. 
1 TB capaciteit biedt ruime groeimarges.

---

## 4. 3-jaar TCO tabel - vergelijking on-prem vs Azure

Component                          | Eenmalige kost (schatting) | Jaarlijkse kost (schatting)
---------------------------------- | --------------------------- | ---------------------------
Azure services (maandkost × 12)    | -                           | € 90.678,84 / jaar
IT‑beheer (FTE, deels)             | -                           | € 40.000 / jaar
Netwerkapparatuur refresh          | € 20.000                    | € 3.000 / jaar
Migratie & opzetkosten Azure       | € 60.000                    | -
Totaal                             | ≈ € 80.000                  | ≈ € 133.678,84 / jaar

---

### Vergelijking on prem met Azure

| Scenario / Kostensoort | Jaar 1           | Jaar 2           | Jaar 3           | TOTAAL 3J        |
|------------------------|------------------|------------------|------------------|------------------|
| **ON‑PREMISES**        |                  |                  |                  |                  |
| CapEx                  | € 320.000        | € 0              | € 0              | € 320.000        |
| OpEx                   | € 96.000         | € 96.000         | € 96.000         | € 288.000        |
| **Subtotaal On‑prem**  | **€ 416.000**    | **€ 96.000**     | **€ 96.000**     | **€ 608.000**    |
|                        |                  |                  |                  |                  |
| **AZURE (Pay‑as‑you‑go)** |               |                  |                  |                  |
| CapEx (netwerk + migratie) | € 80.000    | € 0              | € 0              | € 80.000         |
| OpEx (Azure + beheer)  | € 133.678,84     | € 133.678,84     | € 133.678,84     | € 401.036,52     |
| **Subtotaal Azure**    | **€ 213.678,84** | **€ 133.678,84** | **€ 133.678,84** | **€ 481.036,52** |
|                        |                  |                  |                  |                  |
| **AZURE (1J RI + AHB)** |               |                  |                  |                  |
| CapEx (netwerk + migratie) | € 80.000    | € 0              | € 0              | € 80.000         |
| OpEx (Azure + beheer)  | € 124.887,88    | € 124.887,88     | € 124.887,88     | € 374.663,64     |
| **Subtotaal Azure**    | **€ 204.887,88** | **€ 124.887,88** | **€ 124.887,88** | **€ 454.663,64** |
|                        |                  |                  |                  |                  |
| **BESPARING Azure vs On‑prem** |          |                  |                  | **€ 153.336,36 (≈ 25,2%)** |

> **Dev/Test omgevingen** zijn niet opgenomen in de TCO-berekening.
> Deze omgevingen worden on-demand opgestart via de Contoso-NonProd.
> Dev/Test subscription en hebben geen vaste maandelijkse kost.

---

## 5. Optimalisatieadvies — Reserved Instances, AHB, Auto-scale

### 1. Reserved Instances (RI)

Reserved instances zijn een overeenkomst waarbij je vastlegt dat je een bepaalde resouce zal afnemen voor 1 of 3 jaar.
Deze capaciteit kan maandelijks of vooraf betaald worden.
Voor workloads zoals de SQL‑database en app services die continu draaien, kan hierdoor jaarlijks en 20 tot 40% bespaard worden ten opzichte van Pay-as-you-go.


### 2. Azure Hybrid Benefit (AHB)

Azure Hybrid Benefit is een Microsoft kortingsregeling waarmee je bestaande on-premises Windows Server of SQL Server licenties met Software Assurance kan hergebruiken in Azure.
De klant beschikt over bestaande Windows Server Datacenter en SQL Server Enterprise licenties met Software Assurance via een Microsoft Enterprise Agreement. 
Hierdoor kunnen we gebruik maken van Azure Hybrid Benefit waarbij je geen licentie kosten meer moet betalen voor de resources.
Enkel compute wordt dan aangerekend.

De SA-contracten worden na afloop niet verlengd, omdat de jaarlijkse SA-kost de AHB besparing ruimschoots overstijgt.
Zolang de bestaande SA-periode loopt wordt AHB toegepast op de Azure SQL Database en Jump VM.
Na afloop van de SA-contracten wordt overgeschakeld naar een Azure Savings Plan als kostenefficiënter alternatief zonder licentieverplichting.


### 3. Auto‑scale

Auto‑scale maakt het mogelijk om compute‑capaciteit automatisch op en af te schalen op basis van belasting.
Voor het App Service plan zorgt auto‑scale ervoor dat er extra instances kunnen worden ingezet tijdens piekbelasting.
Dit voorkomt overprovisioning en verlaagt de compute‑kost zonder impact op de beschikbaarheid.

### 4. Dev/Test resources (on-demand)

| Resource | SKU (tst) | SKU (dev) | Opmerkingen |
|---|---|---|---|
| App Service Plan | S2 | B1 | On-demand opgestart |
| web-app + api-app | ✅ | ✅ | Zelfde apps als productie |
| Staging slots | ❌ | ❌ | Niet nodig in non-prod |
| Azure Functions | Op ASP (inbegrepen) | Op ASP (inbegrepen) | |
| Azure SQL Database | GP 2 vCores (Serverless) | GP 2 vCores (Serverless) | Pauzeert automatisch |
| Storage Account | LRS, 100 GB, Hot | LRS, 100 GB, Hot | Geen geo-redundantie |
| Key Vault | Standard | Standard | Aparte secrets per omgeving |
| Application Insights | Workspace-based | Workspace-based | Gedeelde Log Analytics |
| Application Gateway | ❌ | ❌ | Niet nodig in non-prod |
| Defender plans | ❌ | ❌ | Niet nodig in non-prod |
| Azure Firewall | Gedeeld via hub | Gedeeld via hub | Geen extra kost |
| VPN Gateway | Gedeeld via hub | Gedeeld via hub | Geen extra kost |
| Azure Bastion | Gedeeld via hub | Gedeeld via hub | Geen extra kost |
| DNS Private Resolver | Gedeeld via hub | Gedeeld via hub | Geen extra kost |

---

## 6. Risico's — onzekerheden in de inschatting

Bij het opstellen van de TCO zijn een aantal aannames gemaakt op basis van actuele prijzen en realistische verbruiksmodellen. Deze aannames brengen onzekerheden met zich mee die de uiteindelijke kost kunnen beïnvloeden. Hieronder worden de belangrijkste risico's toegelicht.

### 1. Prijswijzigingen in Azure‑diensten

Azure‑prijzen kunnen in de toekomst wijzigen. 
Tariefwijzigingen voor compute, storage of netwerkverkeer kunnen een impact hebben op de toekomstige totale kosten.


### 2. Onzekerheid in verbruiksprofielen

De berekeningen gaan uit van een stabiel verbruik van compute‑resources en SQL‑capaciteit. Indien de applicatie in de toekomst meer verkeer, meer transacties of zwaardere workloads verwerkt, kan dit leiden tot hogere kosten.
Vooral bij App Service auto‑scale kan een onverwacht hoge belasting tijdelijk extra instanties activeren.


### 3. Afhankelijkheid van Reserved Instances en Savings Plans

De TCO gaat uit van het gebruik van 1‑jaar Reserved Instances en 1‑jaar SQL Savings Plan. 
Indien de Reserved Instances niet worden toegepast, zal de kost automatisch stijgen naar Pay‑As‑You‑Go tarieven.
Daarnaast blijft er een risico dat de workload in de toekomst wijzigt, waardoor de gekozen RI‑configuratie minder optimaal wordt.


### 4. Geen gebruik van Azure Hybrid Benefit (AHB)

De huidige kostenberekening maakt gebruik van Azure Hybrid Benefit op basis van bestaande Windows Server Datacenter en SQL Server Enterprise licenties met Software Assurance. 
Na afloop van de SA-contracten vervalt het recht op AHB automatisch.
Indien na afloop geen Azure Savings Plan wordt afgesloten, stijgt de compute kost automatisch naar Pay-as-you-go tarieven.


### 5. Onzekerheden rond netwerkverkeer en egress‑kosten

Egress-kosten zijn afhankelijk van het effectieve uitgaande netwerkverkeer en zijn moeilijk om exact in te schatten. 
Bij nieuwe integraties, toenemend API-verkeer, externe partners of een groeiende gebruikersaantallen kunnen de datatransferkosten stijgen.
De huidige inschatting is conservatief maar biedt geen garantie bij significante groei.



