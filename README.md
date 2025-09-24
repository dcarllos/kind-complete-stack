# Kind + NGINX Ingress (hostPort) + Spring PetClinic
_Local Kubernetes on an Ubuntu physical host, reachable from your LAN_

This project boots a **Kind** Kubernetes cluster (3 nodes), installs **NGINX Ingress** with **hostPort 80/443** on the **control-plane**, and exposes **Spring PetClinic** behind a **ClusterIP Service + Ingress**.  
It works **without MetalLB** and is reachable from other machines on the same network.

---

## Prerequisites

- **Docker** 20+
- **Kind** 0.20+
- **kubectl** 1.27+
- **Helm** 3.x
- **Ports 80 and 443 free** on the host (stop `nginx`, `apache2`, etc.)

Check ports:
```bash
sudo lsof -i :80 -i :443
```

---

## Files

```
.
├─ kind-cluster.yaml              # Kind cluster (3 nodes) with 80/443 port-mapping
├─ ingress-nginx-values.yaml      # Ingress values (hostPort + nodeSelector + toleration)
├─ petclinic.yaml                 # Deployment + Service + Ingress
├─ Makefile                       # targets: up / build-app / app / destroy / rebuild
└─ README.en.md
```

---

## Bring-up (idempotent)

```bash
make up
make build-app     # docker build + kind load
make app           # apply manifests and wait for rollout
```

### Access
- **By hostname (recommended):** on your laptop add to `/etc/hosts` (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows):
  ```
  YOUR-HOST-IP  petclinic.local
  ```
  Open `http://petclinic.local/`.

- **By IP (no hosts editing):** remove `host:` from the Ingress in `petclinic.yaml` (catch-all), then open `http://YOUR-HOST-IP/`.

---

## Troubleshooting

- **404 when using IP** → Ingress matches by host. Use `petclinic.local` (hosts file) or make it catch-all (remove `host:`).  
- **Connection reset / cannot connect** → ensure:
  1) Ingress pod on **control-plane** (nodeSelector/toleration);
  2) `hostPort: 80/443` on the pod;
  3) `docker-proxy` listening on `*:80` and `*:443` on the host.
- **Local image not updating** → run `make build-app` and `kubectl rollout restart deploy/petclinic`.

