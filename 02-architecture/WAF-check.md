| Pijler | Hoe wordt dit geadresseerd in het ontwerp? |
|---|---|
| **Reliability** | Zone-redundante App Service (P2v3), zone-redundante Application Gateway v2, Azure SQL General Purpose met zone-redundantie en geo-redundante backups, deployment slots met health check vóór swap, Azure Backup als vervanging van lokale Veeam-backup |
| **Security** | WAF v2 op Application Gateway, Private Endpoints voor SQL/Storage/Key Vault, Managed Identity, Key Vault voor secrets/keys/certificaten, Entra ID met MFA + Conditional Access, Azure Firewall in de hub, Defender for Cloud, NIS2-ready architectuur |
| **Cost Optimization** | Azure SQL General Purpose (i.p.v. Business Critical), App Service auto-scale, VPN Gateway (i.p.v. ExpressRoute), gedeelde hub-services, Reserved Instances optioneel voor verdere TCO-reductie |
| **Operational Excellence** | Volledige IaC via Bicep, Azure DevOps CI/CD pipelines (dev → tst → prd), approval gates voor productie, SAST-scan, slot swap rollback, Application Insights + Log Analytics, Azure Monitor (vervangt SCOM), tagging-policy |
| **Performance Efficiency** | App Service auto-scale (horizontaal), Application Gateway v2 load balancing, Azure SQL General Purpose voldoende voor ~500 GB, onafhankelijk schaalbare Azure Functions/WebJobs, Azure Files + Blob Storage vervangt NAS |
