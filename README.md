# Get AKS cluster

az aks get-credentials -g oslo-aks-flux-rg -n oslo-dh-aks

# Install flux

fluxctl install --git-user=dahol --git-email=dahol@users.noreply.github.com --git-url=git@github.com:dahol/containerized-python.git --git-path=workloads --namespace=flux | kubectl apply -f -
