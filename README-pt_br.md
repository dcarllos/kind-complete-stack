# Kind + NGINX Ingress (hostPort) + Spring PetClinic
_Ambiente local no Ubuntu (host físico), acessível pela rede_

Este projeto sobe um cluster Kubernetes com **Kind** (3 nós), instala o **NGINX Ingress** usando **hostPort 80/443** no **control-plane**, e publica a aplicação **Spring PetClinic** atrás de um **Service ClusterIP + Ingress**.  
Funciona **sem MetalLB** e pode ser acessado de outros computadores na mesma rede.

---

## Pré-requisitos

- **Docker** 20+
- **Kind** 0.20+
- **kubectl** 1.27+
- **Helm** 3.x
- **Portas 80 e 443 livres no host** (pare `nginx`, `apache2`, etc.)

Verifique portas:
```bash
sudo lsof -i :80 -i :443
```

---

## Arquivos

```
.
├─ kind-cluster.yaml              # cluster Kind (3 nós) com port-mapping 80/443
├─ ingress-nginx-values.yaml      # values do ingress (hostPort + nodeSelector + toleration)
├─ petclinic.yaml                 # Deployment + Service + Ingress da aplicação
├─ Makefile                       # alvos: up / build-app / app / destroy / rebuild
└─ README.pt-BR.md
```

---

## Subir do zero (idempotente)

```bash
make up
make build-app     # docker build + kind load
make app           # aplica manifests e aguarda rollout
```

### Acesso
- **Por hostname (recomendado)**: no notebook adicione em `/etc/hosts` (Linux/macOS) ou `C:\Windows\System32\drivers\etc\hosts` (Windows):
  ```
  192.168.15.10  petclinic.local
  ```
  Abra `http://petclinic.local/`.

- **Por IP (sem editar hosts)**: remova `host:` do Ingress em `petclinic.yaml` (vira catch-all) e acesse `http://192.168.15.10/`.

---

## Troubleshooting

- **404 ao acessar por IP** → o Ingress casa por host. Use `petclinic.local` (arquivo hosts) ou torne o Ingress catch-all (remova `host:`).  
- **Connection reset / não conecta** → garanta:
  1) Pod do ingress no **control-plane** (nodeSelector/toleration);
  2) `hostPort: 80/443` no pod;
  3) `docker-proxy` ouvindo `*:80` e `*:443` no host.
- **Imagem local não atualiza** → rode `make build-app` e `kubectl rollout restart deploy/petclinic`.
