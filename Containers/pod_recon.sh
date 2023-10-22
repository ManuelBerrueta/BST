#!/bin/bash

# Initialize an empty array to store the output
output=()

# Loop through all namespaces
for namespace in $(kubectl get namespaces -o jsonpath='{.items[*].metadata.name}'); do

  # Initialize an empty array to store pods and services
  pods=()
  services=()

  # Loop through all pods in the namespace
  for pod in $(kubectl get pods -n $namespace -o jsonpath='{.items[*].metadata.name}'); do

    # Get the list of containers in the pod
    containers=$(kubectl get pods $pod -n $namespace -o jsonpath='{.spec.containers[*].name}' | sed 's/ /","/g')

    # Add pod information to the array
    pods+=('{
        "podname": "'$pod'",
        "containers": ["'$containers'"]
    }')
  done

  # Loop through all services in the namespace
  for service in $(kubectl get services -n $namespace -o jsonpath='{.items[*].metadata.name}'); do

    # Get detailed information about the service and extract relevant fields
    service_info=$(kubectl get service $service -n $namespace -o json | jq -r '{"NAME": .metadata.name, "TYPE": .spec.type, "CLUSTER-IP": .spec.clusterIP, "EXTERNAL-IP": .status.loadBalancer.ingress[0].ip, "PORT(S)": .spec.ports[].port, "AGE": .metadata.creationTimestamp}')

    # Add service information to the array
    services+=("$service_info")
  done

  # Add namespace information with pods and services to the output
  output+=('{
      "'$namespace'": [
          {
              "pods": ['"$(IFS=,; echo "${pods[*]}")"'],
              "services": ['"$(IFS=,; echo "${services[*]}")"']
          }
      ]
  }')
done

# Print the output in JSON format
echo '['"$(IFS=,; echo "${output[*]}")"']'
