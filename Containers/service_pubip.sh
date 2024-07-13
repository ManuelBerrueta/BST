#!/bin/bash

# Get the external IP address of a service
get_external_ip() {
    local service_name=$1
    local external_ip=""

    # Get service type
    local service_type=$(kubectl get service $service_name -o jsonpath='{.spec.type}')

    if [ "$service_type" == "LoadBalancer" ]; then
        # Get external IP address assigned by the cloud provider's load balancer
        external_ip=$(kubectl get service $service_name -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        if [ -z "$external_ip" ]; then
            # If external IP is not available yet, wait and check again
            echo "Waiting for external IP to be assigned..."
            sleep 10
            external_ip=$(kubectl get service $service_name -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
        fi
    fi

    echo "External IP address of service $service_name: $external_ip"
}

# Prompt user to enter service name
read -p "Enter the name of the service you want to get the external IP address for: " service_name

# Get external IP address of the service
get_external_ip $service_name
