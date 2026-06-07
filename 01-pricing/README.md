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

## Aannames

Onderstaande aannames zijn gedocumenteerd als uitgangspunt voor de prijsinschatting.
Alle bedragen zijn exclusief BTW en gebaseerd op West Europe als primaire regio.

### Gebruikers en gebruik

| Categorie | Aanname | Motivering |
|---|---|---|
| Totaal aantal gebruikers | 450 medewerkers | Opgegeven in opdracht |
| Applicatie gebruikers | 200 medewerkers | schatting aantal gebruikers die applicatie zal gebruiken|
| Gelijktijdige gebruikers | ~50 concurrent users | Productieplanningsapplicatie — niet iedereen tegelijk actief |
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
| Datatransfer egress | ~50 GB/maand | Webverkeer (~11 GB) + SAP batch (~5 GB) + rapporten (~10 GB) + geo-replicatie (~20 GB) |
| SAP batch transfer | ~5 GB/maand | Nachtelijke batch, beperkt datavolume |
| VPN bandbreedte | ~10 Mbps gemiddeld | 3 vestigingen, interne applicatie |

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
| Dev/Test SKUs | 1 tier lager dan productie | tst op B2ms, dev op B1ms |

### Algemeen

| Categorie | Aanname | Motivering |
|---|---|---|
| Primaire regio | West Europe (Amsterdam) | Dichtstbij Belgische vestigingen |
| DR regio | North Europe (Dublin) | Geo-redundantie voor SQL backups |
| Prijspeil | Juni 2026 | Prijzen kunnen wijzigen — jaarlijkse herziening aanbevolen |
| Wisselkoers | € (EUR) | Alle prijzen in euro |

---

## SKU-keuze onderbouwing

### App Service Plan — P2v3 (Windows, 2 instances)

De bestaande web- en applicatietier (WEB01/WEB02 + APP01/APP02) wordt vervangen door
één App Service Plan P2v3 met 2 instances. Gezien de aard van de applicatie (read-heavy
planning en rapportage), het beperkte aantal gelijktijdige gebruikers (≈50), en het feit
dat de Windows Services worden gemigreerd naar Azure Functions, is een afzonderlijk App
Service Plan voor de API/Worker niet nodig. Web en API delen dezelfde HA-vereisten en
hebben vergelijkbare performance-karakteristieken. P2v3 volstaat omdat Azure efficiënter
omgaat met resources dan dedicated on-premises servers die nooit op volledige capaciteit
draaiden. Auto-scale laat toe om bij piekbelasting op te schalen tot 5 instances, waarna
de capaciteit vergelijkbaar is met de huidige on-premises omgeving.

**1 jaar Reserved Instance toegepast** — voldoende workloadzekerheid voor 1-jarige
reservering. Korting: ~25% t.o.v. pay-as-you-go.

---

### Azure Functions — App Service Plan (inbegrepen)

De drie Windows Services (scheduler, processor, reporter) worden gemigreerd naar Azure
Functions op het bestaande P2v3 App Service Plan. De keuze voor Azure Functions boven
WebJobs is gebaseerd op native Timer triggers (CRON-expressies) voor de nachtelijke batch
(23u–03u), ingebouwde integratie met Application Insights, en toekomstbestendigheid.
Door de Functions op het bestaande plan te hosten is VNet integratie beschikbaar zonder
extra kost — noodzakelijk voor toegang tot de Private Endpoints. Kost: **€ 0** (inbegrepen
in App Service Plan).

---

### Azure SQL Database — General Purpose, 4 vCores

De bestaande SQL Server 2014 Always On Availability Group (SQL01/SQL02) wordt vervangen
door Azure SQL Database General Purpose. De applicatie is read-heavy met ≈50 gelijktijdige
gebruikers tijdens werkuren (7u-18u) en een nachtelijke batch zonder gebruikers. Geschat
piekverbruik bedraagt ≈500-1.000 IOPS tijdens werkuren — ruim binnen de General Purpose
limiet van 1.280 IOPS op 4 vCores. RA-GRS backup storage voorziet geo-redundante backups
naar North Europe met RPO ≈1-5 minuten en RTO ≈20-30 minuten — beide binnen de
migratiedoelstellingen (RPO ≤ 15 min, RTO ≤ 1 uur).

Business Critical werd overwogen maar niet gekozen omwille van de significant hogere
kostprijs (~€ 3.000+/maand vs ~€ 1.077/maand) zonder dat de RTO/RPO-vereisten dit
vereisen.

---

### Azure Firewall — Premium

Azure Firewall Premium werd gekozen boven Standard omwille van de ingebouwde **IDPS
(Intrusion Detection and Prevention System)**. IDPS detecteert en blokkeert bekende
aanvalspatronen op netwerkniveau — een relevante maatregel voor NIS2-compliance. De
meerkost t.o.v. Standard is verdedigbaar vanuit het security perspectief van de opdracht.

---

### Application Gateway — WAF_v2

WAF_v2 vervangt de F5 BIG-IP (EOL 2025) en biedt Layer 7 load balancing met WAF
(OWASP 3.2) bescherming. WAF_v2 schaalt automatisch op basis van Capacity Units — voor
Contoso met ≈50 gelijktijdige gebruikers zijn 2 CU voldoende. Zone-redundant voor HA.

---

### VPN Gateway — VpnGw1AZ

VPN Gateway wordt gekozen boven ExpressRoute (zie ADR-003). VpnGw1AZ is zone-redundant
en bevat 10 S2S tunnels — ruim voldoende voor de 3 vestigingen (Gent, Luik, Hasselt).
Alle 3 vestigingen zijn verbonden via het bestaande MPLS netwerk van Proximus, waardoor
bij keuze voor ExpressRoute slechts 1 circuit nodig zou zijn. Desondanks bespaart VPN
Gateway €500-2.000+/maand aan circuitkosten.

---

### DNS Private Resolver

Inbound en Outbound Endpoint voor bidirectionele DNS-resolutie tussen on-premises en
Azure. Het Outbound Endpoint is vereist voor het resolven van interne FQDNs zoals
`sap-api.contoso.local` via DC01. Azure Firewall is geconfigureerd met DNS Proxy enabled
naar `10.0.3.4` (Inbound Endpoint).

---

### Jump VM — B2ms (Windows, 1 jaar Reserved, AHB)

Een jump VM in `snet-spoke-mgmt` biedt toegang tot Azure SQL Database via SSMS voor
database administrators en developers. De Private Endpoint van SQL is niet bereikbaar
vanuit on-premises zonder een VM in het VNet. B2ms (2 vCPU, 8 GB RAM) is voldoende
voor SSMS gebruik. Azure Hybrid Benefit toegepast — Windows Server licentie inbegrepen
via bestaande SA. Auto-shutdown geconfigureerd om kostoptimalisatie te realiseren buiten
werkuren.

---

### Microsoft Entra ID — P1 (443 users) + P2 (7 users)

Entra ID P1 wordt toegewezen aan alle 450 medewerkers voor MFA en Conditional Access —
verplicht voor NIS2-compliance. IT-beheerders en Security Analysts (±7 personen) krijgen
Entra ID P2 voor Privileged Identity Management (PIM) en Identity Protection. Dit volgt
het least privilege principe ook op licentieniveau.

> **Aanname**: Indien Contoso over Microsoft 365 Business Premium beschikt, is Entra ID
> P1 reeds inbegrepen en bedraagt de kost enkel de P2 add-on voor 7 gebruikers
> (€ 3,00/gebruiker/maand supplement).

---

### Azure Firewall — Premium vs Standard

Azure Firewall Premium werd bewust gekozen omwille van IDPS. De meerkost t.o.v. Standard
(~€ 450/maand) wordt gerechtvaardigd door de betere bescherming tegen bekende
aanvalspatronen, consistent met de NIS2-vereisten en Zero Trust architectuur.

---

### Storage Account — GRS, Hot tier, 1 TB

Azure Storage Account vervangt de on-premises NAS shares (UNC). GRS redundantie zorgt
voor geo-redundante opslag naar North Europe. Hot tier is gekozen omdat rapporten en
uploads regelmatig worden geraadpleegd. Lifecycle Management wordt geconfigureerd om
oudere bestanden automatisch naar Cool of Cold tier te verplaatsen voor
kostoptimalisatie. 1 TB capaciteit biedt ruime groeimarges.
