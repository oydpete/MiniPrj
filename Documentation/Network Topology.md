# Network Documentation


## 🏷 IP Addressing Scheme
| Device | Interface | IP Address | Subnet Mask |
|--------|----------|------------|-------------|
| Admin    | eth0     | 192.168.1.13 | 255.255.255.0 |
| target    | eth0     | 192.168.1.14 | 255.255.255.0 |
| Spare    | eth0     | 192.168.1.15 | 255.255.255.0 |

## 🔥 Firewall Rules
| Rule ID | Source IP | Destination IP | Port | Protocol | Action | Description |
|---------|-----------|----------------|------|----------|--------|-------------|
| 1       | Any       | 192.168.1.13    | 22   | TCP      | Allow  | SSH access to Admin |
| 2       | Any       | 192.168.1.11    | 22   | TCP      | Allow  | SSH access to target |
| 3       | Any       | 192.168.1.15    | 22   | TCP      | Allow  | SSH access to Spare |
| 4       | Any       | 192.168.1.0/24  | Any  | Any      | Allow  | Internal network communication |
| 5       | Any       | Any             | Any  | Any      | Deny   | Block all other traffic |

## 🎯 Service Ports in Use
| Service  | Port  | Protocol |
|----------|-------|----------|
| SSH      | 22    | TCP      |
| HTTP     | 80    | TCP      |
| HTTPS    | 443   | TCP      |
| RabbitMQ | 5672  | TCP      |
| Celery   | 5555  | TCP      |



