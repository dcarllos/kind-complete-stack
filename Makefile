CLUSTER=dev-cluster

up:
	kind create cluster --name $(CLUSTER) --config kind-cluster.yaml
	helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
	helm repo update
	helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace -f ingress-nginx-values.yaml

destroy:
	kind delete cluster --name $(CLUSTER)

app:
	kubectl apply -f petclinic-deployment.yaml

rebuild: destroy up app

