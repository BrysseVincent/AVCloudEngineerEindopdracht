### ADR-003: VPN Gateway vs ExpressRoute

| | VPN Gateway | ExpressRoute |
|---|---|---|
| Bandbreedte | Tot 10 Gbps | 50 Mbps – 100 Gbps |
| Latency | Variabel (internet) | Laag (dedicated circuit) |
| Kost | Laag (€140–€700/mnd) | Hoog (€500–€5000+/mnd) |
| Gebruik | Dev/test, lagere eisen | Productie, hoge eisen |

**Vul in**: Welke kies jij voor Contoso? Motiveer.

Voor de hybride connectiviteit tussen de drie vestigingen van Contoso en Azure wordt gekozen voor Azure VPN Gateway met site-to-site VPN verbindingen.

**Waarom VPN Gateway:**
- Site-to-site VPN via versleutelde IPsec/IKE tunnel - voldoet aan NIS2-vereisten
- Voldoende bandbreedte voor het workloadprofiel (productieplanningsapplicatie, nachtelijke SAP-batch)
- Zone-redundant via VpnGw1AZ voor hoge beschikbaarheid
- Significant goedkoper dan ExpressRoute - in lijn met de TCO-reductiedoelstelling van 20%

**Waarom niet ExpressRoute:**
ExpressRoute biedt gegarandeerde bandbreedte en ultra-lage latency, maar is niet vereist 
voor Contoso. De SAP-integratie verloopt via nachtelijke batch zonder real-time vereisten, 
en de kostprijs (€500-€2000+/maand) is moeilijk te verantwoorden voor dit workloadprofiel.
