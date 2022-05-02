# Set vars:
rgName = input

aksName = input

gitUser = input

# Get AKS cluster

az aks get-credentials -g ${rgName} -n ${aksName}

# Install flux

fluxctl install --git-user=${gitUser} --git-email=${gitUser}@users.noreply.github.com --git-url=git@github.com:${gitUser}/containerized-python.git --git-path=workloads --namespace=flux | kubectl apply -f -
