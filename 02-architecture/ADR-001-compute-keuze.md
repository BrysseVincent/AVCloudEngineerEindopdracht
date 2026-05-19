### ADR-001: App Service vs AKS vs Azure Container Apps

| | App Service | AKS | Container Apps |
|---|---|---|---|
| Complexiteit | Laag | Hoog | Middel |
| Beheer overhead | Minimaal | Hoog | Laag |
| Kost | Middel | Hoog | Laag-Middel |
| Geschikt voor WebForms migratie | ✅ | ⚠️ | ⚠️ |

**Vul in**: Welke kies jij en waarom?

Voor de ASP.NET WebForms frontend is App Service de keuze. WebForms draait enkel op Windows, en containeriseren van een monolithische WebForms-app voor AKS of Container Apps vereist een grondige refactor die buiten scope valt van Fase 2. App Service biedt managed hosting met deployment slots (staging ↔ production swap), auto-scale, en minimale beheeroverhead.
