### ADR-003: VPN Gateway vs ExpressRoute

| | VPN Gateway | ExpressRoute |
|---|---|---|
| Bandbreedte | Tot 10 Gbps | 50 Mbps – 100 Gbps |
| Latency | Variabel (internet) | Laag (dedicated circuit) |
| Kost | Laag (€140–€700/mnd) | Hoog (€500–€5000+/mnd) |
| Gebruik | Dev/test, lagere eisen | Productie, hoge eisen |

**Vul in**: Welke kies jij voor Contoso? Motiveer.

Voor de hybride connectiviteit tussen de on-premises vestigingen en Azure kiezen we voor Azure VPN Gateway met site-to-site VPN verbindingen voor elk van de drie vestigingen (Gent, Luik, Hasselt).
De bestaande omgeving maakt gebruik van MPLS-verbindingen via Proximus tussen de drie vestigingen. Bij de migratie naar Azure is een hybride connectiviteitsoplossing nodig voor toegang tot Azure-resources vanuit de vestigingen, en voor de integratie met het on-premises SAP-systeem.

VPN Gateway biedt:
Site-to-site VPN voor alle drie vestigingen via een versleutelde IPsec/IKE tunnel over het publieke internet
Voldoende bandbreedte voor het huidige workloadprofiel (productieplanningsapplicatie, nachtelijke SAP-batch)
Eenvoudige implementatie en beheer via Azure Portal of Bicep
Zone-redundante gateway (VpnGw1AZ of hoger) voor hoge beschikbaarheid
Kostenefficiënte vervanging van de bestaande MPLS-verbindingen, in lijn met de TCO-reductiedoelstelling van 20%

Waarom niet ExpressRoute:
ExpressRoute biedt een dedicated, private verbinding met gegarandeerde bandbreedte en ultra-lage latency. Dit is ideaal voor grote enterprises met zware, latency-gevoelige workloads. 

Voor Contoso Manufacturing is dit echter niet vereist:
De SAP-integratie verloopt via nachtelijke batch — geen real-time of latency-kritische communicatie
De applicatie is een interne productieplannings- en rapportageapplicatie zonder extreem hoge bandbreedtevereisten
De kostprijs van ExpressRoute (€500–€2000+/maand enkel voor het circuit) is moeilijk te verantwoorden en staat haaks op de TCO-reductiedoelstelling

Risico-aanvaarding:
VPN Gateway maakt gebruik van het publieke internet, wat theoretisch een hogere latency en minder gegarandeerde bandbreedte geeft dan ExpressRoute. Dit risico wordt bewust aanvaard gezien het workloadprofiel. De verbinding wordt beveiligd via IPsec/IKE encryptie, wat voldoet aan de NIS2-vereisten rond databeveiliging in transit.
