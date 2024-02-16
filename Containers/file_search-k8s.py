import argparse
import subprocess
import sys

def get_keywords_from_file(keyword_file):
    with open(keyword_file, "r") as file:
        return [line.strip() for line in file]

def search_files_in_pods(namespaces, keywords):
    for namespace in namespaces:
        # List pods in the namespace
        pods_cmd = ["kubectl", "get", "pods", "-n", namespace]
        pods_output = subprocess.run(pods_cmd, capture_output=True, text=True)
        if pods_output.returncode != 0:
            print(f"Error listing pods in namespace {namespace}: {pods_output.stderr}")
            continue

        # Extract pod names
        pod_lines = pods_output.stdout.split("\n")[1:]  # Skip header
        for line in pod_lines:
            if line:
                pod_name = line.split()[0]

                # Get list of containers in the pod
                containers_cmd = ["kubectl", "get", "pod", pod_name, "-n", namespace, "-o", "jsonpath={.spec.containers[*].name}"]
                containers_output = subprocess.run(containers_cmd, capture_output=True, text=True)
                if containers_output.returncode != 0:
                    print(f"Error getting containers in pod {pod_name}: {containers_output.stderr}")
                    continue

                # Extract container names
                container_names = containers_output.stdout.split()

                # Iterate over containers in the pod
                for container in container_names:
                    # Run kubectl exec command to list files in the container
                    exec_cmd = ["kubectl", "exec", "-n", namespace, pod_name, "-c", container, "--", "find", "/"]
                    exec_output = subprocess.run(exec_cmd, capture_output=True, text=True)
                    if exec_output.returncode != 0:
                        print(f"Error executing command in pod {pod_name} container {container}: {exec_output.stderr}")
                        continue

                    # Extract files from the exec command output
                    files = exec_output.stdout.split()

                    # Search for keywords within files
                    for file in files:
                        for keyword in keywords:
                            if keyword in file or file.endswith(keyword):
                                print(f"Keyword '{keyword}' found in pod '{pod_name}' container '{container}' file '{file}'")

def main():
    parser = argparse.ArgumentParser(description="Search for keywords within files in Kubernetes pods.")
    parser.add_argument("-n", "--namespaces", nargs="+", required=True, help="Namespaces to search within.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-k", "--keywords", nargs="+", help="Keywords to search for.")
    group.add_argument("-f", "--keyword-file", help="File containing keywords, one per line.")
    args = parser.parse_args()

    if args.keyword_file:
        keywords = get_keywords_from_file(args.keyword_file)
    else:
        keywords = args.keywords

    search_files_in_pods(args.namespaces, keywords)

if __name__ == "__main__":
    main()
