# Network Documentation

## 📌 Network Topology Diagram
*(Include a visual representation of your network. You can use tools like Draw.io, Lucidchart, or ASCII art if preferred.)*

```
[ VM1 ] ----- [ Switch/Router ] ----- [ VM2 ]
                     |
                     |
                  [ VM3 ]
```

## 🏷 IP Addressing Scheme
| Device | Interface | IP Address | Subnet Mask |
|--------|----------|------------|-------------|
| VM1    | eth0     | 192.168.1.10 | 255.255.255.0 |
| VM2    | eth0     | 192.168.1.11 | 255.255.255.0 |
| VM3    | eth0     | 192.168.1.12 | 255.255.255.0 |
| Router | eth0     | 192.168.1.1  | 255.255.255.0 |

## 🔥 Firewall Rules
| Rule ID | Source IP | Destination IP | Port | Protocol | Action | Description |
|---------|-----------|----------------|------|----------|--------|-------------|
| 1       | Any       | 192.168.1.10    | 22   | TCP      | Allow  | SSH access to VM1 |
| 2       | Any       | 192.168.1.11    | 22   | TCP      | Allow  | SSH access to VM2 |
| 3       | Any       | 192.168.1.12    | 22   | TCP      | Allow  | SSH access to VM3 |
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

---
### Notes:
- Ensure that firewall rules are properly configured to prevent unauthorized access.
- SSH key-based authentication is recommended for enhanced security.
- The IP addressing scheme should be updated based on your actual network configuration.
- The topology diagram can be enhanced using a drawing tool for better clarity.

---
✅ *Last Updated: $(date)*

