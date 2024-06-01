# FutureTech
Trabalho prático de Administração de Sistemas em Rede.

## Running
```sh
nix run .#run
```

## Requirements
- [x] A empresa quer três páginas web:
  - [x] Página de administração: **admin.futuretech.pt** – Apenas acedida na rede Interna.
  - [x] Página para comunicação interna: **gestao.futuretech.pt** – Apenas acedida na rede interna.
  - [x] Página para clientes: **clientes.futuretech.pt** – Apenas acedida na rede externa.
- [x] A empresa quer serviço de Email e querem usar um cliente de email, como por exemplo o Thunderbird.
- [x] WiFi:
  - [x] Workspace aberto com capacidade para um máximo de 40 colaboradores
  - [x] Duas salas de reuniões com rede dedicada, com capacidade para 10 colaboradores.
- [ ] Gestão de backups e logs:
  - [ ] Os backups devem ser realizados todos os dias e armazenar sempre e apenas a última semana.
  - [ ] Devem ser guardados apenas logs da última semana.

## Entregas

Neste contexto o trabalho prático divide-se em 3 partes (3 entregas):
1. Planeamento da rede e serviços (5% da nota do TP)
   - Prazo: 19/05/2024, 23.59.
2. Implementação dos serviços (15% da nota do TP)
   - Prazo: 26/05/2024, 23.59.
3. Implementação do sistema de backups e logs (10% da nota do TP)
   - Prazo: 02/05/2024, 23.59.

## Testar o DHCP

```bash
[guest@guest:~]$ sudo nmap --script broadcast-dhcp-discover
Starting Nmap 7.94 ( https://nmap.org ) at 2024-05-31 17:45 UTC
Pre-scan script results:
| broadcast-dhcp-discover:
|   Response 1 of 3:
|     Interface: eth0
|     IP Offered: 10.0.2.15
|     DHCP Message Type: DHCPOFFER
|     Server Identifier: 10.0.2.2
|     Subnet Mask: 255.255.255.0
|     Router: 10.0.2.2
|     Domain Name Server: 10.0.2.3
|     IP Address Lease Time: 1d00h00m00s
|   Response 2 of 3:
|     Interface: eth0
|     IP Offered: 10.0.1.2
|     DHCP Message Type: DHCPOFFER
|     Subnet Mask: 255.255.255.192
|     IP Address Lease Time: 1s
|     Server Identifier: 10.0.1.1
|   Response 3 of 3:
|     Interface: eth0
|     IP Offered: 10.0.3.2
|     DHCP Message Type: DHCPOFFER
|     Subnet Mask: 255.255.255.192
|     IP Address Lease Time: 1s
|_    Server Identifier: 10.0.3.1
WARNING: No targets were specified, so 0 hosts scanned.
Nmap done: 0 IP addresses (0 hosts up) scanned in 10.19 seconds
```
