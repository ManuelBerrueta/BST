#!/bin/bash

# Get list of services
echo "Services in the Kubernetes cluster:"
kubectl get services
echo -e "\n"

# Prompt user to select a service for more details
read -p "Enter the name of the service you want to describe: " service_name

# Describe the selected service
echo -e "\n"
printf '=%.0s' {1..50}
echo -e "\nDetails of service $service_name:"
kubectl describe service $service_name

# Get list of ingresses
echo "Ingresses in the Kubernetes cluster:"
kubectl get ingress
