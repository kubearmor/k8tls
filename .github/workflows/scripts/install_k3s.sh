curl -sfL https://get.k3s.io | K3S_KUBECONFIG_MODE="644" INSTALL_K3S_EXEC="--disable=traefik" sh -
[[ $? != 0 ]] && echo "Failed to install k3s" && exit 1
mkdir -p ~/.kube && cp /etc/rancher/k3s/k3s.yaml ~/.kube/config

until kubectl wait --for=condition=ready --timeout=15m -n kube-system pod -l k8s-app=metrics-server
do
 [[ $? != 0 ]] && echo "Checking for metrics-server"
 sleep 10
done