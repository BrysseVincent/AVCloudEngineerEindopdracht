# Azure Well-Architected Framework — Contoso Manufacturing NV

---

## 1. Reliability

| Component | Maatregel |
|---|---|
| App Service | Zone-redundant App Service Plan (Premium P2v3), minimum 2 instanties |
| App Service | Deployment slots (staging ↔ production swap) voor zero-downtime releases |
| Azure SQL Database | Zone-redundant General Purpose + active geo-replication naar North Europe |
| Azure SQL Database | Failover group met automatische failover policy (drempel: 1 uur) |
| VPN Gateway | Active-Active topologie (VpnGw2AZ) — geen single point of failure |
| Application Gateway | Zone-redundant WAF v2 met meerdere instanties |
| Backup | Azure Backup + SQL point-in-time restore (35 dagen) + long-term retention (12 maanden) |

**SLA-aantoonbaarheid**: gecombineerde SLA van App Service (99,95%) + SQL Database (99,99%) + Application Gateway (99,95%) voldoet aan de projectvereiste van ≥ 99,9%.

**RTO/RPO**: RTO ≤ 1 uur en RPO ≤ 15 minuten worden gehaald via failover group en geo-replication (zie ADR-002).

---

## 2. Security

| Component | Maatregel |
|---|---|
| Application Gateway WAF v2 | OWASP ruleset beschermt tegen SQL injection, XSS en andere OWASP Top 10 aanvallen |
| Private Endpoints | SQL Database, Storage Account en Key Vault zijn enkel bereikbaar via private IP — geen publieke blootstelling |
| Key Vault | Alle secrets, connection strings en certificaten opgeslagen in Key Vault; geen secrets in applicatiecode of config files |
| Managed Identity | App Service en WebJobs authenticeren via System-assigned Managed Identity — geen credentials in code |
| Entra ID | Vervangt Kerberos/Windows Integrated Auth; moderne authenticatie via OAuth2/OIDC |
| Conditional Access | MFA verplicht voor beheerders en externe toegang |
| Defender for Cloud | Continu security posture management en threat detection op alle resources |
| Azure Firewall | Hub VNet filtert al het oost-west en noord-zuid verkeer tussen spoke en on-prem |
| RBAC | Minimale rechten per resource via Azure role-based access control; geen Owner-rechten op workload subscription |
| NIS2 | Geo-replication, audit logging via Log Analytics en Defender for Cloud dekken de NIS2-vereisten voor beschikbaarheid en incidentdetectie |

---

## 3. Cost Optimization

| Maatregel | Besparing |
|---|---|
| Azure Hybrid Benefit (SQL Server licenties) | ≈ 30% korting op SQL Database |
| Azure Hybrid Benefit (Windows Server licenties) | ≈ 40% korting op App Service Windows runtime |
| Reserved Instances (1 jaar) op App Service Plan | ≈ 20–30% korting t.o.v. pay-as-you-go |
| VPN Gateway i.p.v. ExpressRoute | ≈ €270–€520/maand besparing (zie ADR-003) |
| General Purpose i.p.v. Business Critical | ≈ €510/maand besparing (zie ADR-002) |
| Auto-scale App Service | Schalen naar beneden buiten piekperiodes — geen vaste overcapaciteit |
| Dev/Test subscription | Lagere tarieven voor non-productie omgevingen |

**TCO-doelstelling**: combinatie van Hybrid Benefit, Reserved Instances en juiste tier-keuzes levert een geschatte TCO-reductie van > 20% over 3 jaar t.o.v. verlenging van de on-premises omgeving.

---

## 4. Operational Excellence

| Component | Maatregel |
|---|---|
| Infrastructure as Code | Volledige infrastructuur gedefinieerd in Bicep (zie `05-bicep/`) |
| CI/CD | Azure DevOps pipelines voor automatische build, test en deployment naar staging slot |
| Deployment slots | Staging ↔ production swap na validatie — rollback in seconden mogelijk |
| Azure Monitor + Log Analytics | Centrale logging van alle resources; retentie 90 dagen |
| Application Insights | End-to-end telemetrie op App Service en WebJobs (requests, dependencies, exceptions, performance) |
| Alerting | Azure Monitor alerts op kritieke drempels: CPU > 80%, replication lag > 5 min, failover events |
| Tagging | Alle resources getagd met `environment`, `owner`, `costcenter` voor beheer en kostentoewijzing |
| DR-test | Jaarlijkse geplande failover naar geo-replica om RTO in de praktijk te valideren |

---

## 5. Performance Efficiency

| Component | Maatregel |
|---|---|
| App Service auto-scale | Horizontaal schalen op basis van CPU en HTTP queue length — opvangen van piekbelasting tijdens productieplanningsperiodes |
| App Service Plan P2v3 | 2 vCores / 8 GB RAM per instantie — voldoende voor ASP.NET WebForms workload |
| SQL Database 4 vCores | Schaalbaar naar 8 vCores zonder downtime indien query-load stijgt |
| Azure Storage | Blob Storage voor rapporten en uploads vervangt trage UNC shares op NAS — lagere latency, hogere throughput |
| Application Gateway | Layer 7 load balancing distribueert verkeer optimaal over App Service instanties |
| WebJobs Always On | Voorkomt cold starts bij nachtelijke batchverwerking |
| Application Insights | Performance monitoring identificeert bottlenecks proactief (slow queries, slow requests) |
