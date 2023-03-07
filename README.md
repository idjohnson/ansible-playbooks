# ansible-playbooks
A home for my Ansible Playbooks

# K3s Reload

The Template should define variables for hosts (only the first used), k3s version and external ingress (for tlssan)
```yaml
---
k3sversion: v1.23.10%2Bk3s1
hosts:
  - name: 192.168.1.12
  - name: 192.168.1.206
  - name: 192.168.1.159
extingress:
  - ip: 73.242.50.46
  - port: 25460
```

# GlusterFS

Each node in the cluster should have an entry.  The first is considered master
```yaml
---
hosts:
  - name: 192.168.1.12
  - name: 192.168.1.206
  - name: 192.168.1.159
```

