### ADR-001: App Service vs AKS vs Azure Container Apps

| | App Service | AKS | Container Apps |
|---|---|---|---|
| Complexiteit | Laag | Hoog | Middel |
| Beheer overhead | Minimaal | Hoog | Laag |
| Kost | Middel | Hoog | Laag-Middel |
| Geschikt voor WebForms migratie | ✅ | ⚠️ | ⚠️ |

**Vul in**: Welke kies jij en waarom?

ASP.NET WebForms 4.7 is een Windows-gebonden framework dat sterk leunt op IIS, session state en het klassieke .NET Framework.
App Service biedt native ondersteuning voor Windows en IIS, waardoor de bestaande applicatie met minimale aanpassingen kan worden gedeployed. Dit sluit perfect aan bij de Rehost -> Refactor migratiestrategie waarbij we kunne herplatformen zonder de app te moeten herschrijven.

Daarnaast voldoet App Service aan de projectvereisten:
- SLA van 99,9% via ingebouwde redundantie en availability zones
- Automatisch schalen bij piekbelasting (productieplanningsperiodes)
- Eenvoudige integratie met Azure SQL, Key Vault, Application Insights en Entra ID
- App Service biedt managed hosting met deployment slots (staging ↔ production swap), auto-scale, en minimale beheeroverhead.
