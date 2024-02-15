#!/bin/bash

# Get all namespaces
namespaces=$(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}')

# Loop through each namespace
for namespace in $namespaces; do
  printf '=%.0s' {1..50}
  echo -e "\nNamespace: $namespace"

  # Get all services in the namespace
  services=$(kubectl get services -n $namespace -o jsonpath='{.items[*].metadata.name}')
  # Loop through each service
  echo -e "\tSERVICES in this namespace:"
  for service in $services; do
    echo -e "\t\t  Service: $service"
  done
  echo -e "\n"

  # Get all pods in the namespace
  pods=$(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}')
  # Loop through each pod
  echo -e "\tPODS in this namespace:"
  for pod in $pods; do
    echo -e "\t\tPod: $pod"
  done

  echo -e "\n"
done
