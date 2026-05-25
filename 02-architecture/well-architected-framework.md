# Azure Well-Architected Framework check

> **Contoso Manufacturing NV** | Fase 2 — PaaS Refactor architectuur

Documentatie van hoe het ontwerp scoort op de 5 pijlers van het Azure Well-Architected Framework.

---

## Overzichtstabel

| Pijler | Hoe wordt dit geadresseerd in het ontwerp? |
|---|---|
| **Reliability** | Zone-redundante App Service (P2v3), zone-redundante Application Gateway v2, Azure SQL General Purpose met zone-redundantie en geo-redundante backups, deployment slots met health check vóór swap, Azure Backup als vervanging van lokale Veeam-backup |
| **Security** | WAF v2 op Application Gateway, Private Endpoints voor SQL/Storage/Key Vault, Managed Identity, Key Vault voor secrets/keys/certificaten, Entra ID met MFA + Conditional Access, Azure Firewall in de hub, Defender for Cloud, NIS2-ready architectuur |
| **Cost Optimization** | Azure SQL General Purpose (i.p.v. Business Critical), App Service auto-scale, VPN Gateway (i.p.v. ExpressRoute), gedeelde hub-services, Reserved Instances optioneel voor verdere TCO-reductie |
| **Operational Excellence** | Volledige IaC via Bicep, Azure DevOps CI/CD pipelines (dev → tst → prd), approval gates voor productie, SAST-scan, slot swap rollback, Application Insights + Log Analytics, Azure Monitor (vervangt SCOM), tagging-policy |
| **Performance Efficiency** | App Service auto-scale (horizontaal), Application Gateway v2 load balancing, Azure SQL General Purpose voldoende voor ~500 GB, onafhankelijk schaalbare Azure Functions/WebJobs, Azure Files + Blob Storage vervangt NAS |

---

## Detailbeschrijving per pijler

### 1. Reliability

App Service is geconfigureerd op een **zone-redundant P2v3 App Service Plan**, wat een SLA van 99,95% garandeert. **Application Gateway v2** is eveneens zone-redundant en vervangt de single-point-of-failure F5 BIG-IP (EOL 2025).

**Azure SQL Database General Purpose** met zone-redundantie en automatische geo-redundante backups levert:
- **RPO**: ~1–5 minuten (ruim binnen de vereiste van ≤ 15 minuten)
- **RTO**: ~20–30 minuten (binnen de vereiste van ≤ 1 uur)

Deployment slots (staging ↔ production swap) met een geautomatiseerde health check vóór elke swap zorgen voor **zero-downtime deployments**. Bij een mislukte health check wordt de swap niet uitgevoerd en blijft productie onaangetast.

**Azure Backup** vervangt de lokale Veeam-backup zonder offsite kopie, wat het vroegere risico op dataverlies bij een lokale ramp elimineert.

---

### 2. Security

| Maatregel | Implementatie |
|---|---|
| **WAF** | Application Gateway v2 met WAF-policy (OWASP 3.2) beschermt de frontend |
| **Private Endpoints** | SQL Database, Storage Account en Key Vault zijn volledig onbereikbaar via het publieke internet |
| **Managed Identity** | App Service en Azure Functions gebruiken System Assigned Managed Identity — geen hardcoded wachtwoorden in code |
| **Key Vault** | Centrale opslag voor secrets (connection strings, API keys), keys (CMK voor TDE) en certificaten (TLS auto-renew) met 90-daagse rotatie |
| **Entra ID + MFA** | Vervangt Kerberos/on-prem AD; Conditional Access policies dwingen MFA af voor alle gebruikers |
| **Azure Firewall** | Hub-firewall filtert al het Noord-Zuid en Oost-West verkeer via FQDN- en netwerkregels |
| **Defender for Cloud** | Actief op SQL, App Service, Storage en Key Vault; Secure Score doelstelling ≥ 80% |
| **NIS2-compliance** | Encryptie in transit (TLS 1.2+), encryptie at rest (CMK), gedocumenteerd incidentmeldingsproces richting CCB (binnen 24u initiële melding, binnen 72u gedetailleerde melding) |

---

### 3. Cost Optimization

De kostoptimalisatiedoelstelling is een **TCO-reductie van minimaal 20% over 3 jaar** t.o.v. verlenging van de on-premises omgeving.

| Keuze | Motivering |
|---|---|
| **Azure SQL General Purpose** (i.p.v. Business Critical) | Significant lagere kost; RTO/RPO-vereisten worden gehaald |
| **App Service auto-scale** | Schaalt enkel op bij piekbelasting (productieplanningsperiodes) en daarna terug — geen overcapaciteit betalen |
| **VPN Gateway** (i.p.v. ExpressRoute) | Bespaart €500–€2000+/maand aan circuitkosten; workloadprofiel vereist geen dedicated verbinding |
| **Gedeelde hub-services** | Azure Firewall, VPN Gateway en Bastion worden gedeeld tussen subscriptions — geen duplicatie per omgeving |
| **Reserved Instances** (optioneel) | 1- of 3-jarige reserveringen op App Service Plan en SQL Database kunnen de kost verder reduceren met 30–55% bij voldoende workloadzekerheid |

---

### 4. Operational Excellence

De volledige infrastructuur is beschreven als **Infrastructure as Code via Bicep-templates**, gedeployed via een Azure DevOps CI/CD pipeline met drie omgevingen:

| Omgeving | Branch | Auto-deploy | Approval |
|---|---|---|---|
| `dev` | `feature/*`, `develop` | ✅ Ja | ❌ Nee |
| `tst` | `develop`, `release/*` | ✅ Ja | ❌ Nee |
| `prd` | `main` | ❌ Nee | ✅ Ja (min. 2 approvers) |

Aanvullende maatregelen:
- **SAST-scan** en dependency vulnerability check in elke pipeline-run
- **Slot swap rollback**: bij problemen na een productie-swap kan de vorige versie onmiddellijk teruggezet worden
- **Application Insights + Log Analytics Workspace**: end-to-end observability als vervanging van SCOM 2012
- **Azure Monitor alerts**: proactieve notificaties bij drempeloverschrijdingen
- **Tagging-policy** (Deny-effect): dwingt consistente tagging af op alle resources (`Environment`, `Application`, `Owner`, `CostCenter`, `DataClassification`)

---

### 5. Performance Efficiency

| Component | Schaalmechanisme |
|---|---|
| **App Service** | Horizontaal auto-scale op basis van CPU/geheugengebruik; P2v3 plan schaalt tot 5 instanties bij piekbelasting |
| **Application Gateway v2** | Automatische schaling van gateway-instanties; verdeelt verkeer over alle App Service-instanties |
| **Azure SQL General Purpose** | Voldoende vCores en I/O-doorvoer voor een database van ~500 GB; opschalen naar meer vCores mogelijk zonder downtime |
| **Azure Functions / WebJobs** | Vervangen .NET Windows Services; kunnen onafhankelijk van de web frontend schalen (scheduler, processor, reporter) |
| **Azure Files + Blob Storage** | Vervangen NAS-shares (UNC) met nagenoeg onbeperkte schaalbaarheid en geen capacity planning vereist |

---

*Onderdeel van de eindopdracht Cloud Engineer — Syntra, schooljaar 2025–2026*
